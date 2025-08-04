# 🔄 Configuración Manual de Replicación MySQL

## Paso 1: Levantar los contenedores

```bash
docker-compose up -d
```

## Paso 2: Esperar a que MySQL esté listo

```bash
# Verificar que MySQL master esté funcionando
docker exec proyectodistribuidas-db-1 mysqladmin ping -u root -proot --silent

# Verificar que MySQL slave esté funcionando
docker exec proyectodistribuidas-db-slave-1 mysqladmin ping -u root -proot --silent
```

## Paso 3: Crear la tabla en el master

```bash
# Conectar al master y crear la tabla
docker exec -it proyectodistribuidas-db-1 mysql -u root -proot -e "
USE inventario;
CREATE TABLE IF NOT EXISTS product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    unit INT DEFAULT 0,
    category VARCHAR(100) DEFAULT 'General',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);"
```

## Paso 4: Crear la tabla en el slave

```bash
# Conectar al slave y crear la misma tabla
docker exec -it proyectodistribuidas-db-slave-1 mysql -u root -proot -e "
USE inventario;
CREATE TABLE IF NOT EXISTS product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    unit INT DEFAULT 0,
    category VARCHAR(100) DEFAULT 'General',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);"
```

## Paso 5: Configurar replicación en el master

```bash
# Crear usuario replicador en el master
docker exec -it proyectodistribuidas-db-1 mysql -u root -proot -e "
CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED BY 'replicator_password';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
FLUSH PRIVILEGES;"
```

## Paso 6: Obtener información del master

```bash
# Obtener posición del binlog
docker exec -it proyectodistribuidas-db-1 mysql -u root -proot -e "SHOW MASTER STATUS;"
```

## Paso 7: Configurar el slave

```bash
# Configurar el slave (reemplaza FILE y POS con los valores del paso anterior)
docker exec -it proyectodistribuidas-db-slave-1 mysql -u root -proot -e "
STOP SLAVE;
RESET SLAVE;
CHANGE MASTER TO
    MASTER_HOST='db',
    MASTER_USER='replicator',
    MASTER_PASSWORD='replicator_password',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=157;
START SLAVE;"
```

## Paso 8: Verificar replicación

```bash
# Verificar estado del slave
docker exec -it proyectodistribuidas-db-slave-1 mysql -u root -proot -e "SHOW SLAVE STATUS\G"
```

## Paso 9: Probar replicación

```bash
# Insertar dato en master
docker exec -it proyectodistribuidas-db-1 mysql -u root -proot -e "
USE inventario;
INSERT INTO product (name, code, description, unit, category)
VALUES ('Test Product', 'TEST001', 'Producto de prueba', 10, 'Test');"

# Verificar en slave
docker exec -it proyectodistribuidas-db-slave-1 mysql -u root -proot -e "
USE inventario;
SELECT * FROM product WHERE code='TEST001';"
```

## ✅ Verificación Final

- Master: http://localhost:8080 (seleccionar servidor Master)
- Slave: http://localhost:8080 (seleccionar servidor Slave)
- Aplicación: http://localhost (admin/admin123)
