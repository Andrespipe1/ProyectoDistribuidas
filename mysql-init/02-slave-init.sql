-- Script de inicialización para el Slave MySQL
-- Este script se ejecuta automáticamente cuando se crea el contenedor slave

-- Asegurar que la base de datos inventario existe
CREATE DATABASE IF NOT EXISTS inventario;
USE inventario;

-- Crear tabla User (basada en models.py) - SIN utf8mb4 para coincidir con master
CREATE TABLE IF NOT EXISTS user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(80) NOT NULL UNIQUE,
    password VARCHAR(200) NOT NULL
) ENGINE=InnoDB;

-- Crear tabla Product (basada en models.py) - SIN utf8mb4 para coincidir con master
CREATE TABLE IF NOT EXISTS product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200),
    unit INT NOT NULL DEFAULT 0,
    category VARCHAR(50)
) ENGINE=InnoDB;

-- Mostrar las tablas creadas para verificación
SHOW TABLES;
