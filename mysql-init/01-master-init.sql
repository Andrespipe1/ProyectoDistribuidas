-- Script de inicialización para el Master MySQL
-- Este script se ejecuta automáticamente cuando se crea el contenedor master

-- Crear usuario de replicación
CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'replicator_password';

-- Otorgar permisos de replicación
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';

-- Aplicar cambios
FLUSH PRIVILEGES;

-- Mostrar el estado del master para referencia
SHOW MASTER STATUS;
