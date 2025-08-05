import time
import pymysql
from __init__ import app, db
from models import User, Product

def wait_for_db():
    """Espera a que la base de datos esté disponible"""
    max_attempts = 120  # Aumentado para desarrollo (6 minutos)
    attempt = 0
    
    while attempt < max_attempts:
        try:
            # Intentar conectar a MySQL
            connection = pymysql.connect(
                host='db',
                user='root',
                password='root',
                database='inventario',
                port=3306,
                connect_timeout=10  # Timeout más largo
            )
            connection.close()
            print("✅ Base de datos MySQL está lista!")
            return True
        except Exception as e:
            print(f"⏳ Esperando a MySQL... (intento {attempt + 1}/{max_attempts})")
            time.sleep(3)  # Pausa de 3 segundos
            attempt += 1
    
    print("❌ No se pudo conectar a MySQL después de varios intentos")
    return False

def create_tables():
    """Crea las tablas en la base de datos"""
    with app.app_context():
        db.create_all()
        print("✅ Tablas creadas exitosamente!")

def create_admin_user():
    """Crea un usuario administrador por defecto"""
    with app.app_context():
        # Verificar si ya existe un usuario admin
        admin = User.query.filter_by(username='admin').first()
        if not admin:
            admin = User('admin', 'admin123')
            db.session.add(admin)
            db.session.commit()
            print("✅ Usuario administrador creado (admin/admin123)")

if __name__ == '__main__':
    if wait_for_db():
        create_tables()
        create_admin_user()
        print("🚀 Base de datos inicializada correctamente!")
    else:
        print("❌ Error al inicializar la base de datos")
        exit(1) 