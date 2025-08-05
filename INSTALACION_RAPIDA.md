# 🚀 INSTALACIÓN RÁPIDA - PARA COMPAÑEROS

## ⚡ Opción 1: Instalación Súper Fácil (RECOMENDADA)

### 1. Abrir PowerShell como Administrador
- Presiona `Win + X` → Selecciona "Windows PowerShell (Administrador)"

### 2. Navegar al directorio del proyecto
```powershell
cd "C:\ruta\donde\descargaste\ProyectoDistribuidas"
```

### 3. Permitir ejecución de scripts (solo primera vez)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4. Ejecutar instalación automática
```powershell
.\setup-facil.ps1
```

## ⚡ Opción 2: Si la Opción 1 no funciona

### Instalación Manual Paso a Paso:

#### 1. Verificar Docker
```powershell
docker --version
```
Si no funciona: Instala Docker Desktop desde https://docker.com

#### 2. Iniciar servicios
```powershell
docker-compose up -d
```

#### 3. Esperar 2-3 minutos y verificar
```powershell
docker-compose ps
```

#### 4. Configurar replicación manualmente
```powershell
# Crear usuario de replicación
docker exec proyectodistribuidas-db-1 mysql -u root -proot -e "CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'replicator_password'; GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%'; FLUSH PRIVILEGES;"

# Obtener posición del master
docker exec proyectodistribuidas-db-1 mysql -u root -proot -e "SHOW MASTER STATUS;"

# Configurar slave (ajustar los valores según el output anterior)
docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e "STOP SLAVE; RESET SLAVE; CHANGE MASTER TO MASTER_HOST='db', MASTER_USER='replicator', MASTER_PASSWORD='replicator_password', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=157; START SLAVE;"
```

#### 5. Verificar que funcione
```powershell
docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e "SHOW SLAVE STATUS\G"
```
Debe mostrar: `Slave_IO_Running: Yes` y `Slave_SQL_Running: Yes`

## 🌐 Acceder a la Aplicación

Una vez configurado:
- **Aplicación Web:** http://localhost
- **phpMyAdmin:** http://localhost:8080
  - Master: Servidor `db`, Usuario: `root`, Contraseña: `root`
  - Slave: Servidor `db-slave`, Usuario: `root`, Contraseña: `root`

## 🔧 Solución de Problemas Comunes

### Error: "Los puertos están ocupados"
```powershell
# Detener servicios que puedan estar usando los puertos
docker-compose down
# Reiniciar Docker Desktop
```

### Error: "Docker no funciona"
1. Abrir Docker Desktop
2. Esperar que aparezca el ícono en la bandeja del sistema
3. Verificar con: `docker --version`

### Error: "No se puede ejecutar scripts"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "Contenedores no inician"
```powershell
# Ver logs de errores
docker-compose logs

# Limpiar todo y reiniciar
docker-compose down
docker system prune -f
docker-compose up -d
```

## 📞 Si Nada Funciona

1. Verifica que tengas Docker Desktop instalado y funcionando
2. Verifica que los puertos 80, 3306, 3307, 8080 no estén ocupados
3. Ejecuta como Administrador
4. Si persisten problemas, usa el archivo `MANUAL_REPLICACION.md` para configuración manual completa
