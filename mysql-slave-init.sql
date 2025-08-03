-- Script de inicialización para MySQL Slave
-- Se ejecuta automáticamente al crear el contenedor

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