Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CONFIGURACION AUTOMATICA MYSQL       " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "1. Verificando Docker..." -ForegroundColor Yellow
docker --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker no funciona" -ForegroundColor Red
    exit 1
}
Write-Host "OK: Docker funcionando" -ForegroundColor Green

Write-Host "2. Iniciando servicios..." -ForegroundColor Yellow
docker-compose down 2>$null
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudieron iniciar contenedores" -ForegroundColor Red
    exit 1
}
Write-Host "OK: Servicios iniciados" -ForegroundColor Green

Write-Host "3. Esperando MySQL Master..." -ForegroundColor Yellow
$count = 0
$maxAttempts = 30  # 2.5 minutos para MySQL 5.7
do {
    Start-Sleep 5
    # Verificar que el contenedor esté corriendo primero
    $containerRunning = docker inspect proyectodistribuidas-db-1 --format="{{.State.Running}}" 2>$null
    if ($containerRunning -eq "true") {
        $result = docker exec proyectodistribuidas-db-1 mysqladmin ping -u root -proot --silent 2>$null
        if ($LASTEXITCODE -eq 0) {
            # MySQL responde, verificar que pueda conectarse completamente
            $testConnection = docker exec proyectodistribuidas-db-1 mysql -u root -proot -e "SELECT 1;" 2>$null
        }
    }
    $count++
    if ($count % 6 -eq 0) {
        Write-Host "  Master - Intento $count de $maxAttempts (MySQL 5.7)..." -ForegroundColor Gray
    }
} while ($LASTEXITCODE -ne 0 -and $count -lt $maxAttempts)

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: MySQL Master no responde después de $($maxAttempts * 5 / 60) minutos" -ForegroundColor Red
    Write-Host "Revisando logs del contenedor..." -ForegroundColor Yellow
    docker logs proyectodistribuidas-db-1 --tail 20
    exit 1
}
Write-Host "OK: MySQL Master listo" -ForegroundColor Green

Write-Host "4. Esperando MySQL Slave..." -ForegroundColor Yellow
$count = 0
$maxAttempts = 30  # 2.5 minutos para MySQL 5.7
do {
    Start-Sleep 5
    # Verificar que el contenedor esté corriendo primero
    $containerRunning = docker inspect proyectodistribuidas-db-slave-1 --format="{{.State.Running}}" 2>$null
    if ($containerRunning -eq "true") {
        $result = docker exec proyectodistribuidas-db-slave-1 mysqladmin ping -u root -proot --silent 2>$null
        if ($LASTEXITCODE -eq 0) {
            # MySQL responde, verificar que pueda conectarse completamente
            $testConnection = docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e "SELECT 1;" 2>$null
        }
    }
    $count++
    if ($count % 6 -eq 0) {
        Write-Host "  Slave - Intento $count de $maxAttempts (MySQL 5.7)..." -ForegroundColor Gray
    }
} while ($LASTEXITCODE -ne 0 -and $count -lt $maxAttempts)

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: MySQL Slave no responde después de $($maxAttempts * 5 / 60) minutos" -ForegroundColor Red
    Write-Host "Revisando logs del contenedor..." -ForegroundColor Yellow
    docker logs proyectodistribuidas-db-slave-1 --tail 20
    exit 1
}
Write-Host "OK: MySQL Slave listo" -ForegroundColor Green

Write-Host "5. Verificando tablas en Master..." -ForegroundColor Yellow
$cmdCheckMaster = "USE inventario; SHOW TABLES;"
$masterTables = docker exec proyectodistribuidas-db-1 mysql -u root -proot -e $cmdCheckMaster -s --skip-column-names 2>$null
if ($masterTables -like "*user*" -and $masterTables -like "*product*") {
    Write-Host "OK: Tablas existentes en Master" -ForegroundColor Green
} else {
    Write-Host "AVISO: Creando tablas en Master..." -ForegroundColor Yellow
    # Ejecutar init_db.py si las tablas no existen
    docker exec proyectodistribuidas-web1-1 python init_db.py 2>$null
    Start-Sleep 3
}

Write-Host "6. Verificando tablas en Slave..." -ForegroundColor Yellow
$cmdCheckSlave = "USE inventario; SHOW TABLES;"
$slaveTables = docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e $cmdCheckSlave -s --skip-column-names 2>$null
if ($slaveTables -like "*user*" -and $slaveTables -like "*product*") {
    Write-Host "OK: Tablas existentes en Slave" -ForegroundColor Green
} else {
    Write-Host "ERROR: Tablas no encontradas en Slave - reinicie sin -v" -ForegroundColor Red
    exit 1
}

Write-Host "7. Configurando replicacion..." -ForegroundColor Yellow

# Crear usuario replicacion en master
$cmd1 = "CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'replicator_password'; GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%'; FLUSH PRIVILEGES;"
docker exec proyectodistribuidas-db-1 mysql -u root -proot -e $cmd1 2>$null

# Hacer flush y lock en master para snapshot limpio
$cmdFlush = "FLUSH TABLES WITH READ LOCK;"
docker exec proyectodistribuidas-db-1 mysql -u root -proot -e $cmdFlush 2>$null

# Obtener estado master mientras esta locked
$cmd2 = "SHOW MASTER STATUS;"
$masterStatus = docker exec proyectodistribuidas-db-1 mysql -u root -proot -e $cmd2 -s --skip-column-names 2>$null
$parts = $masterStatus -split "`t"
$logFile = $parts[0]
$logPos = $parts[1]

Write-Host "  Master Log: $logFile, Position: $logPos" -ForegroundColor Gray

# Hacer dump de la base de datos con estructura y datos
Write-Host "  Creando snapshot completo de datos..." -ForegroundColor Gray
$dumpCmd = "mysqldump -u root -proot --single-transaction --routines --triggers --add-drop-table --create-options inventario"
$dumpData = docker exec proyectodistribuidas-db-1 $dumpCmd 2>$null

# Unlock tables en master
$cmdUnlock = "UNLOCK TABLES;"
docker exec proyectodistribuidas-db-1 mysql -u root -proot -e $cmdUnlock 2>$null

# Aplicar dump completo al slave (esto sobrescribe las tablas existentes)
Write-Host "  Aplicando snapshot completo al slave..." -ForegroundColor Gray
$dumpData | docker exec -i proyectodistribuidas-db-slave-1 mysql -u root -proot 2>$null

# Configurar slave con la posicion correcta
$cmd3 = "STOP SLAVE; RESET SLAVE; CHANGE MASTER TO MASTER_HOST='db', MASTER_USER='replicator', MASTER_PASSWORD='replicator_password', MASTER_LOG_FILE='$logFile', MASTER_LOG_POS=$logPos; START SLAVE;"
docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e $cmd3 2>$null

Write-Host "OK: Replicacion configurada" -ForegroundColor Green

Write-Host "8. Verificando replicacion..." -ForegroundColor Yellow
Start-Sleep 5
$cmd4 = "SHOW SLAVE STATUS\G"
$slaveStatus = docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e $cmd4 2>$null

if ($slaveStatus -like "*Slave_IO_Running: Yes*" -and $slaveStatus -like "*Slave_SQL_Running: Yes*") {
    Write-Host "OK: Replicacion funcionando!" -ForegroundColor Green
} else {
    Write-Host "AVISO: Verificar replicacion manualmente" -ForegroundColor Yellow
    Write-Host "Estado del slave:" -ForegroundColor Gray
    Write-Host $slaveStatus -ForegroundColor Gray
}

Write-Host "9. Prueba final de sincronizacion..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$cmd5 = "USE inventario; INSERT INTO product (name, code, description, unit, category) VALUES ('Test Final $timestamp', 'TF$timestamp', 'Prueba automatica', 1, 'Test');"
docker exec proyectodistribuidas-db-1 mysql -u root -proot -e $cmd5 2>$null
Start-Sleep 3
$cmd6 = "USE inventario; SELECT COUNT(*) FROM product WHERE code='TF$timestamp';"
$test = docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e $cmd6 -s --skip-column-names 2>$null

if ($test -eq "1") {
    Write-Host "OK: Prueba de sincronizacion exitosa!" -ForegroundColor Green
    # Limpiar datos de prueba
    $cmdClean = "USE inventario; DELETE FROM product WHERE code='TF$timestamp';"
    docker exec proyectodistribuidas-db-1 mysql -u root -proot -e $cmdClean 2>$null
} else {
    Write-Host "AVISO: Revisar sincronizacion manualmente" -ForegroundColor Yellow
    Write-Host "Valor obtenido: '$test'" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "           CONFIGURACION COMPLETA      " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Aplicacion: http://localhost         " -ForegroundColor Green
Write-Host "  phpMyAdmin: http://localhost:8080    " -ForegroundColor Green
Write-Host "  MySQL Master: localhost:3306         " -ForegroundColor Green
Write-Host "  MySQL Slave: localhost:3307          " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
