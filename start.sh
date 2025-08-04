#!/bin/bash

# Script de inicio para la aplicación Flask
echo "Iniciando aplicación Flask..."

# Esperar a que MySQL esté disponible
echo "Esperando a MySQL..."
while ! mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
    sleep 1
done

echo "MySQL está listo. Inicializando base de datos..."

# Ejecutar la aplicación
python run.py
