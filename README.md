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
git clone https://github.com/tuusuario/ProyectoDistribuidas.git
cd ProyectoDistribuidas
```

### **2. Levantar la infraestructura**

```bash
docker-compose up --build -d
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

## 🔄 Replicación MySQL

- La replicación master-slave está lista para configurarse desde el inicio.
- Puedes usar el selector de servidores en phpMyAdmin para gestionar tanto el master como el slave.

---

## 🧪 Pruebas y Funcionalidades

- Registrar, editar y eliminar productos
- Buscar y filtrar en tiempo real (AJAX)
- Exportar inventario filtrado a Excel
- Validar códigos únicos
- Probar balanceo de carga y replicación

---

## 📊 Características Técnicas

- **Flask** + **SQLAlchemy** + **Bootstrap 5** + **AJAX**
- **Docker Compose** para orquestación
- **NGINX** como balanceador de carga
- **MySQL 8** con replicación
- **phpMyAdmin** con selector de Master/Slave
- **Exportación a Excel** con pandas/xlsxwriter

---

## 💡 Notas finales

- El sistema es totalmente responsivo y moderno.
- Puedes personalizar las categorías y la lógica fácilmente.
- Si tienes dudas, revisa los comentarios en el código o pregunta.
