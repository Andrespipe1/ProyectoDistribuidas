# 📦 Sistema de Inventario Distribuido

## Descripción

Aplicación web de gestión de inventario desarrollada en **Flask (Python)** con arquitectura distribuida. Implementa un sistema completo de inventario con autenticación de usuarios, registro y consulta de productos en tiempo real, balanceador de carga NGINX y base de datos MySQL lista para replicación master-slave.

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   NGINX (LB)   │    │   phpMyAdmin    │    │   MySQL Master  │
│   Puerto: 80    │    │   Puerto: 8080  │    │   Puerto: 3306  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
    ┌────┴────┐                 │                 ┌────┴────┐
    │         │                 │                 │         │
┌───▼───┐ ┌───▼───┐             │             ┌───▼───┐ ┌───▼───┐
│ Web1  │ │ Web2  │             │             │ Web3  │ │Slave DB│
│(50%)  │ │(33%)  │             │             │(17%)  │ │(3307) │
└───────┘ └───────┘             │             └───────┘ └───────┘
```

---

## ✨ Funcionalidades Implementadas

### ✅ Requisitos Mínimos Cumplidos

1. **🔐 Inicio de sesión para usuarios**

   - Interfaz moderna con gradientes y animaciones
   - Usuario administrador creado automáticamente
   - Sesiones seguras con Flask

2. **📝 Registro de productos**

   - Formulario completo con validación
   - Campos: nombre, código, descripción, unidad, categoría
   - Interfaz mejorada con categorías predefinidas

3. **🔍 Validación de códigos únicos**

   - Validación automática en backend
   - Mensajes de error informativos
   - Prevención de duplicados

4. **⚡ Consulta en tiempo real**
   - Buscador por nombre, código y descripción
   - Filtro por categoría
   - Resultados instantáneos
   - Contador de productos encontrados

---

## 🐳 Infraestructura Docker

### **Servicios Implementados:**

| Servicio     | Descripción          | Puerto | Función                       |
| ------------ | -------------------- | ------ | ----------------------------- |
| `nginx`      | Balanceador de carga | 80     | Distribuye tráfico entre apps |
| `web1`       | Instancia 1 de Flask | -      | 50% del tráfico (peso 3)      |
| `web2`       | Instancia 2 de Flask | -      | 33% del tráfico (peso 2)      |
| `web3`       | Instancia 3 de Flask | -      | 17% del tráfico (peso 1)      |
| `db`         | MySQL Master         | 3306   | Base de datos principal       |
| `db-slave`   | MySQL Slave          | 3307   | Base de datos replica         |
| `phpmyadmin` | Gestión MySQL        | 8080   | Interfaz web para BD          |

---

## 📁 Estructura del Proyecto

```
ProyectoDistribuidas/
│
├── app/                          # Aplicación Flask
│   ├── app.py                   # Rutas y lógica principal
│   ├── models.py                # Modelos SQLAlchemy
│   ├── __init__.py              # Configuración Flask
│   ├── init_db.py               # Inicialización BD
│   ├── requirements.txt         # Dependencias Python
│   └── templates/               # Plantillas HTML
│       ├── login.html           # Login moderno
│       ├── inventory.html       # Inventario con búsqueda
│       └── register_product.html # Registro de productos
│
├── nginx/                       # Configuración NGINX
│   ├── nginx.conf              # Balanceo por pesos
│   └── Dockerfile              # Imagen NGINX
│
├── start.sh                     # Script de inicialización
├── Dockerfile                   # Imagen aplicación Flask
├── docker-compose.yml          # Orquestación completa
└── README.md                   # Documentación
```

---

## 🚀 Instalación y Uso

### **Prerrequisitos**

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)

### **1. Clonar el repositorio**

```bash
git clone https://github.com/tuusuario/ProyectoDistribuidas.git
cd ProyectoDistribuidas
```

### **2. Levantar la infraestructura**

```bash
docker-compose up --build
```

### **3. Acceder a los servicios**

| Servicio           | URL                   | Credenciales     |
| ------------------ | --------------------- | ---------------- |
| **Aplicación Web** | http://localhost:80   | admin / admin123 |
| **phpMyAdmin**     | http://localhost:8080 | root / root      |
| **MySQL Master**   | localhost:3306        | root / root      |
| **MySQL Slave**    | localhost:3307        | root / root      |

---

## 🔧 Configuración del Balanceador

### **Distribución de Carga (nginx.conf):**

```nginx
upstream backend {
    server web1:5000 weight=3;  # 50% del tráfico
    server web2:5000 weight=2;  # 33% del tráfico
    server web3:5000 weight=1;  # 17% del tráfico
}
```

### **Verificar Balanceo:**

- Accede a: `http://localhost/health`
- Refresca varias veces
- Verás diferentes hostnames (web1, web2, web3)

---

## 🔄 Replicación MySQL Manual

### **Configuración desde phpMyAdmin:**

1. **Accede a phpMyAdmin**: `http://localhost:8080`
2. **Configura el MASTER (puerto 3306):**

   ```sql
   -- Habilitar binlog
   SET GLOBAL log_bin = ON;
   SET GLOBAL binlog_format = 'ROW';
   SET GLOBAL server_id = 1;

   -- Crear usuario replicador
   CREATE USER 'replicator'@'%' IDENTIFIED BY 'replicator123';
   GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
   FLUSH PRIVILEGES;

   -- Ver estado del master
   SHOW MASTER STATUS;
   ```

3. **Configura el SLAVE (puerto 3307):**

   ```sql
   -- Configurar slave
   SET GLOBAL server_id = 2;
   SET GLOBAL relay_log = 'mysql-relay-bin';
   SET GLOBAL log_slave_updates = ON;

   -- Configurar replicación (usa datos del SHOW MASTER STATUS)
   CHANGE MASTER TO
       MASTER_HOST = 'db',
       MASTER_USER = 'replicator',
       MASTER_PASSWORD = 'replicator123',
       MASTER_LOG_FILE = 'mysql-bin.000001',
       MASTER_LOG_POS = 157;

   -- Iniciar replicación
   START SLAVE;

   -- Verificar estado
   SHOW SLAVE STATUS\G
   ```

---

## 🧪 Pruebas del Sistema

### **1. Prueba de Funcionalidad**

- Registra productos con diferentes categorías
- Prueba el buscador en tiempo real
- Verifica validación de códigos únicos

### **2. Prueba de Balanceo**

- Accede a `http://localhost/health`
- Refresca 10 veces
- Verifica distribución de carga

### **3. Prueba de Replicación**

- Crea productos en el master
- Verifica que aparezcan en el slave
- Monitorea desde phpMyAdmin

---

## 📊 Características Técnicas

### **Tecnologías Utilizadas:**

- **Backend**: Flask (Python 3.11)
- **Base de Datos**: MySQL 8.0
- **ORM**: SQLAlchemy
- **Balanceador**: NGINX
- **Contenedores**: Docker & Docker Compose
- **Gestión BD**: phpMyAdmin

### **Seguridad:**

- Contraseñas encriptadas con Werkzeug
- Validación de entrada de datos
- Sesiones seguras de Flask
- Conexiones SSL-ready

### **Escalabilidad:**

- Arquitectura distribuida
- Balanceo de carga automático
- Replicación de base de datos
- Contenedores independientes

---

## 🐛 Solución de Problemas

### **Error de Conexión a MySQL:**

```bash
# Verificar logs
docker-compose logs db
docker-compose logs web1
```

### **Reiniciar Servicios:**

```bash
docker-compose restart
```

### **Limpiar Volúmenes:**

```bash
docker-compose down -v
docker-compose up --build
```

---

## 📝 Notas de Desarrollo

### **Scripts de Inicialización:**

- `start.sh`: Orquesta la inicialización
- `init_db.py`: Espera MySQL y crea tablas/usuario
- Configuración automática de base de datos

### **Variables de Entorno:**

- `DATABASE_URL`: Conexión a MySQL
- `MYSQL_ROOT_PASSWORD`: Contraseña root
- `PMA_HOST`: Host para phpMyAdmin

---

## 👥 Autores

- **Estudiante**: [Tu Nombre]
- **Materia**: Tecnologías Distribuidas
- **Docente**: Ing. Vanessa Guevara
- **Fecha**: Julio 2025

---

## 📄 Licencia

Este proyecto es parte de una práctica académica para la materia de Tecnologías Distribuidas.

---

## 🤝 Contribuciones

Para contribuir al proyecto:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

---

_¡Sistema de inventario distribuido listo para producción! 🚀_
