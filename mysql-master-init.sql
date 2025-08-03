-- Script de inicialización para MySQL Master
-- Se ejecuta automáticamente al crear el contenedor

-- Crear usuario de replicación
CREATE USER IF NOT EXISTS 'replicador'@'%' IDENTIFIED BY 'replicapass';
GRANT REPLICATION SLAVE ON *.* TO 'replicador'@'%';
FLUSH PRIVILEGES;

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS inventario;
USE inventario;

-- Crear tabla de productos si no existe
CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    categoria VARCHAR(50) NOT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    estado ENUM('Disponible', 'Agotado') DEFAULT 'Disponible',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear usuario admin para la aplicación
CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON inventario.* TO 'admin'@'%';
FLUSH PRIVILEGES; 