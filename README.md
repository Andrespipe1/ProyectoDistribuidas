# 📦 Sistema de Inventario Distribuido

## Descripción

Aplicación web de gestión de inventario desarrollada en **Flask (Python)** con arquitectura distribuida y moderna. Permite gestionar productos con autenticación, edición, eliminación, consulta en tiempo real, exportación a Excel, balanceo de carga NGINX y replicación MySQL master-slave.

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

## ✨ Funcionalidades Principales

- **🔐 Inicio de sesión seguro** (admin/admin123 por defecto)
- **📝 Registro, edición y eliminación de productos**
- **Validación de códigos únicos** (no se pueden repetir)
- **Formulario moderno y responsivo** con categorías predefinidas y opción "Otra..."
- **Consulta en tiempo real** (AJAX) por nombre, código, descripción, categoría y estado
- **Filtro por estado** (Disponible/Agotado) y por categoría
- **Edición rápida de cantidad**
- **Exportar inventario filtrado a Excel**
- **Balanceo de carga NGINX**
- **Replicación MySQL master-slave**
- **phpMyAdmin con selector de Master/Slave**

---

## 🐳 Infraestructura Docker

### **Servicios Implementados:**

| Servicio     | Descripción          | Puerto | Función                             |
| ------------ | -------------------- | ------ | ----------------------------------- |
| `nginx`      | Balanceador de carga | 80     | Distribuye tráfico entre apps       |
| `web1`       | Instancia 1 de Flask | -      | 50% del tráfico (peso 3)            |
| `web2`       | Instancia 2 de Flask | -      | 33% del tráfico (peso 2)            |
| `web3`       | Instancia 3 de Flask | -      | 17% del tráfico (peso 1)            |
| `db`         | MySQL Master         | 3306   | Base de datos principal             |
| `db-slave`   | MySQL Slave          | 3307   | Base de datos replica               |
| `phpmyadmin` | Gestión MySQL        | 8080   | Interfaz web para BD (Master/Slave) |

---

## 📁 Estructura del Proyecto

```
# 🏢 Sistema Distribuido de Inventario

Sistema web distribuido de gestión de inventario con Flask, MySQL master-slave replication, NGINX load balancer y alta disponibilidad.

## 🚀 Características

- **🔄 Replicación MySQL Master-Slave**: Datos replicados automáticamente
- **⚖️ Load Balancer NGINX**: Distribución inteligente de tráfico
- **🏗️ Arquitectura Distribuida**: 3 instancias Flask para alta disponibilidad
- **📊 Monitoreo con phpMyAdmin**: Acceso a ambas bases de datos
- **🐳 Containerización Docker**: Fácil despliegue y escalabilidad
- **⚡ Configuración Automática**: Scripts de inicialización incluidos

## 📋 Arquitectura del Sistema

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   NGINX         │    │   Flask Apps     │    │   MySQL         │
│   Load Balancer │────│   (3 instancias) │────│   Master-Slave  │
│   Port 80       │    │   web1,web2,web3 │    │   3306 / 3307   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                       ┌──────────────────┐
                       │   phpMyAdmin     │
                       │   Port 8080      │
                       └──────────────────┘
```

## 🎯 Inicio Rápido

### Opción 1: Configuración Automática (Recomendado)

**Para Windows:**
```powershell
# Abrir PowerShell como Administrador
cd "C:\ruta\al\ProyectoDistribuidas"
.etup-mysql-replication.ps1
```

**Para Linux/macOS:**
```bash
cd /ruta/al/ProyectoDistribuidas
chmod +x setup-mysql-replication.sh
./setup-mysql-replication.sh
```

### Opción 2: Configuración Manual

```bash
# 1. Clonar el repositorio
git clone [URL-del-repositorio]
cd ProyectoDistribuidas

# 2. Construir y levantar servicios
docker-compose up -d

# 3. Verificar estado
docker-compose ps

# 4. Configurar replicación (ver MANUAL_REPLICACION.md)
```

## 📚 Documentación

- **[📖 Manual Completo de Replicación](MANUAL_REPLICACION.md)**: Guía detallada paso a paso
- **[🔧 Solución de Problemas](MANUAL_REPLICACION.md#-solución-de-problemas)**: Errores comunes y soluciones

## 🌐 Acceso a Servicios

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Aplicación Web** | http://localhost | Sistema de inventario principal |
| **phpMyAdmin** | http://localhost:8080 | Interfaz de administración de BD |
| **MySQL Master** | localhost:3306 | Base de datos principal |
| **MySQL Slave** | localhost:3307 | Base de datos de respaldo |

### Credenciales por Defecto
- **MySQL Root**: Usuario: `root`, Contraseña: `root`
- **Replicación**: Usuario: `replicator`, Contraseña: `replicator_password`

## 🏗️ Estructura del Proyecto

```
ProyectoDistribuidas/
├── 📄 docker-compose.yml          # Configuración principal
├── 📄 Dockerfile                  # Imagen de la aplicación Flask
├── 📁 mysql-init/                 # Scripts de inicialización automática
│   ├── 01-master-init.sql         # Configuración del master
│   └── setup-replication.sh       # Script de replicación
├── 📁 app/                        # Aplicación Flask
│   ├── app.py                     # Aplicación principal
│   ├── models.py                  # Modelos de datos
│   ├── init_db.py                 # Inicializador de BD
│   └── templates/                 # Plantillas HTML
├── 📁 nginx/                      # Configuración NGINX
│   ├── Dockerfile                 # Imagen personalizada
│   └── nginx.conf                 # Configuración del balanceador
├── 📄 setup-mysql-replication.sh  # Script automático (Linux/macOS)
├── 📄 setup-mysql-replication.ps1 # Script automático (Windows)
└── 📄 MANUAL_REPLICACION.md       # Manual detallado
```

## ⚙️ Configuración Avanzada

### Variables de Entorno
```yaml
# Aplicación Flask
DATABASE_URL: mysql+pymysql://root:root@db:3306/inventario

# phpMyAdmin
PMA_HOSTS: db,db-slave
PMA_USER: root
PMA_PASSWORD: root
```

### Configuración MySQL
```yaml
# Master (server-id=1)
--log-bin=mysql-bin
--binlog-format=ROW

# Slave (server-id=2)
--relay-log=mysql-relay-bin
--read-only=1
```

## 🔍 Monitoreo y Verificación

### Verificar Estado de Replicación
```bash
# Estado del slave
docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e "SHOW SLAVE STATUS\G" | grep -E "(Slave_IO_Running|Slave_SQL_Running|Last_Error)"

# Estado del master
docker exec proyectodistribuidas-db-1 mysql -u root -proot -e "SHOW MASTER STATUS;"
```

### Probar Replicación
```bash
# Insertar en master
docker exec proyectodistribuidas-db-1 mysql -u root -proot -e "
USE inventario; 
INSERT INTO product (name, code, description, unit, category) 
VALUES ('Test', 'T001', 'Producto de prueba', 1, 'Test');"

# Verificar en slave
docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e "
USE inventario; 
SELECT * FROM product WHERE code='T001';"
```

## 🚨 Solución de Problemas

### Problemas Comunes

1. **Server IDs iguales**: Verificar configuración en docker-compose.yml
2. **Puertos ocupados**: Cambiar puertos en configuración
3. **Replicación fallida**: Consultar [Manual de Replicación](MANUAL_REPLICACION.md)

### Logs y Debugging
```bash
# Ver logs de contenedores
docker-compose logs db
docker-compose logs db-slave
docker-compose logs web1

# Estado de contenedores
docker-compose ps

# Reinicio limpio
docker-compose down && docker-compose up -d
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 🎉 ¡Listo para Producción!

Con esta configuración tienes un sistema completamente funcional con:
- ✅ Alta disponibilidad
- ✅ Replicación automática
- ✅ Load balancing
- ✅ Monitoreo incluido
- ✅ Fácil escalabilidad
│
├── app/                          # Aplicación Flask
│   ├── app.py                   # Rutas y lógica principal
│   ├── models.py                # Modelos SQLAlchemy
│   ├── __init__.py              # Configuración Flask
│   ├── init_db.py               # Inicialización BD
│   ├── requirements.txt         # Dependencias Python
│   └── templates/               # Plantillas HTML (modernas y responsivas)
│       ├── base.html            # Layout base
│       ├── login.html           # Login moderno
│       ├── inventory.html       # Inventario con búsqueda y acciones
│       ├── register_product.html # Registro de productos
│       └── edit_product.html    # Edición de cantidad
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
git clone https://github.com/Andrespipe1/ProyectoDistribuidas.git
cd ProyectoDistribuidas
```

### **2. Levantar la infraestructura**

```bash
docker-compose up --build -d
```

- La base de datos y el usuario admin se crean automáticamente.
- Si cambias dependencias en `requirements.txt`, ejecuta:

```bash
docker-compose build web1 web2 web3
```

### **3. Acceder a los servicios**

| Servicio           | URL                   | Credenciales     |
| ------------------ | --------------------- | ---------------- |
| **Aplicación Web** | http://localhost:80   | admin / admin123 |
| **phpMyAdmin**     | http://localhost:8080 | root / root      |
| **MySQL Master**   | localhost:3306        | root / root      |
| **MySQL Slave**    | localhost:3307        | root / root      |

### **4. Detener y limpiar el entorno**

```bash
docker-compose down           # Detener todo
# Para limpiar volúmenes y datos:
docker-compose down -v
```

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

## 🔄 Replicación MySQL

- La replicación master-slave está lista para configurarse desde el inicio.
- Puedes usar el selector de servidores en phpMyAdmin para gestionar tanto el master como el slave.
- Los archivos `mysql-master.cnf` y `mysql-slave.cnf` ya están configurados para la replicación.

---

## 🧪 Pruebas y Funcionalidades

- **Registrar productos:** Completa el formulario y verifica que no se repitan códigos.
- **Editar cantidad:** Haz clic en “Editar” en la tabla y cambia la cantidad.
- **Eliminar productos:** Haz clic en “Eliminar” y confirma.
- **Buscar y filtrar:** Usa el buscador, el filtro de categoría y el filtro de estado (Disponible/Agotado).
- **Exportar a Excel:** Haz clic en el botón verde “Exportar a Excel” para descargar el inventario filtrado.
- **Consulta en tiempo real:** Los resultados se actualizan automáticamente al escribir o filtrar.
- **Probar balanceo de carga:** Accede a `/health` y refresca varias veces.
- **Probar replicación:** Agrega productos y verifica en ambos servidores desde phpMyAdmin.

---

## 🖼️ Capturas de pantalla

### Login moderno

<img width="600" height="400" alt="imagen" src="https://github.com/user-attachments/assets/d016ec55-a822-454b-a205-8c9283d34519" />

### Inventario con filtros y acciones

<img width="600" height="400" alt="imagen" src="https://github.com/user-attachments/assets/ded573dd-be12-4da3-b177-87cf9bdb4a5d" />

### Registro de producto

<img width="600" height="400" alt="imagen" src="https://github.com/user-attachments/assets/cd6ca9fe-ba86-45d6-b3d9-888ec8d999ad" />

---

## 📊 Características Técnicas

- **Flask** + **SQLAlchemy** + **Bootstrap 5** + **AJAX**
- **Docker Compose** para orquestación
- **NGINX** como balanceador de carga
- **MySQL 8** con replicación
- **phpMyAdmin** con selector de Master/Slave
- **Exportación a Excel** con pandas/xlsxwriter

---

## 👤 Autor y Contacto

- **Desarrolladores:** Andrés Tufiño - Darwin Cachimil - Anderson Vilatuña - Wilmer Vargas
- **GitHub:** [Andrespipe1](https://github.com/Andrespipe1)
- **País:** Ecuador



---

- El sistema es totalmente responsivo y moderno.
- Puedes personalizar las categorías y la lógica fácilmente.
- Si tienes dudas, revisa los comentarios en el código o pregunta.

---

## 🛠️ Configuración Manual de Replicación MySQL (Master-Slave)

Si la replicación no está configurada automáticamente, sigue estos pasos para configurarla usando phpMyAdmin y los nombres de tus servicios:

### 1. Accede a phpMyAdmin en el master (`db`)

- URL: [http://localhost:8080](http://localhost:8080)
- Selecciona el servidor `db`
- Usuario: `root`
- Contraseña: `root`

### 2. Crea el usuario de replicación en el master

En la pestaña "SQL", ejecuta:

```sql
CREATE USER 'replicador'@'%' IDENTIFIED BY 'replicapass';
GRANT REPLICATION SLAVE ON *.* TO 'replicador'@'%';
FLUSH PRIVILEGES;
```

### 3. Obtén el estado del master

En la pestaña "SQL", ejecuta:

```sql
SHOW MASTER STATUS;
```

- Apunta el valor de `File` (ejemplo: `mysql-bin.000001`) y `Position` (ejemplo: `154`).

### 4. Accede a phpMyAdmin en el slave (`db-slave`)

- Cambia el servidor a `db-slave` en phpMyAdmin.

### 5. Configura el slave

En la pestaña "SQL", ejecuta (reemplaza los valores de `MASTER_LOG_FILE` y `MASTER_LOG_POS` por los que obtuviste en el paso anterior):

```sql
STOP SLAVE;

CHANGE MASTER TO
  MASTER_HOST='db',
  MASTER_USER='replicador',
  MASTER_PASSWORD='replicapass',
  MASTER_LOG_FILE='mysql-bin.000001',  -- <-- pon aquí el valor de File
  MASTER_LOG_POS=154;                  -- <-- pon aquí el valor de Position

START SLAVE;
```

### 6. Verifica el estado de la replicación en el slave

En el slave, ejecuta:

```sql
SHOW SLAVE STATUS
```

- Busca que `Slave_IO_Running` y `Slave_SQL_Running` digan `Yes`.
<img width="1024" height="768" alt="imagen" src="https://github.com/user-attachments/assets/87681fcd-457b-464d-8901-aae91baeebb1" />

---

**Notas:**

- La replicación es unidireccional: lo que insertes en el master (`db`) aparecerá en el slave (`db-slave`).
- Si editas o insertas datos en el slave, **no** se replicarán al master.
- Si tienes dudas, revisa los logs de MySQL o consulta la sección de ayuda.
