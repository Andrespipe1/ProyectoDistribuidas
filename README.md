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
ProyectoDistribuidas/
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

![Login](./screenshots/login.png)

### Inventario con filtros y acciones

![Inventario](./screenshots/inventario.png)

### Registro de producto

![Registro](./screenshots/registro.png)

> Puedes agregar más capturas en la carpeta `screenshots/` para mostrar tu sistema.

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

- **Desarrollador:** Andrés Tufiño
- **GitHub:** [Andrespipe1](https://github.com/Andrespipe1)
- **País:** Ecuador

¿Dudas, sugerencias o mejoras? ¡Contáctame por GitHub!

---

- El sistema es totalmente responsivo y moderno.
- Puedes personalizar las categorías y la lógica fácilmente.
- Si tienes dudas, revisa los comentarios en el código o pregunta.
