#!/bin/bash

# Inicializar la base de datos
echo "🔧 Inicializando base de datos..."
python init_db.py

# Si la inicialización fue exitosa, ejecutar la aplicación
if [ $? -eq 0 ]; then
    echo "🚀 Iniciando aplicación Flask..."
    python app.py
else
    echo "❌ Error al inicializar la base de datos"
    exit 1
fi 