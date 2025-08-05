#!/usr/bin/env python3
"""
Script de inicio alternativo más robusto para la aplicación Flask
"""
import time
import sys
import os
from init_db import wait_for_db, create_tables, create_admin_user

def main():
    """Función principal que inicializa la BD y ejecuta la app"""
    print("🔧 Inicializando aplicación...")
    
    # Esperar a que la base de datos esté disponible
    if not wait_for_db():
        print("❌ Error: No se pudo conectar a la base de datos")
        sys.exit(1)
    
    # Crear tablas y usuario admin
    try:
        create_tables()
        create_admin_user()
        print("✅ Base de datos inicializada correctamente!")
    except Exception as e:
        print(f"❌ Error al inicializar la base de datos: {e}")
        sys.exit(1)
    
    # Importar y ejecutar la aplicación Flask
    try:
        print("🚀 Iniciando aplicación Flask...")
        # Cambiar al directorio del script
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        
        # Importar la app desde el módulo __init__
        import __init__
        app = __init__.app
        print("✅ Flask app importada correctamente!")
        print("🌐 Iniciando servidor en puerto 5000...")
        app.run(host='0.0.0.0', port=5000, debug=False)
    except Exception as e:
        print(f"❌ Error al iniciar la aplicación: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
