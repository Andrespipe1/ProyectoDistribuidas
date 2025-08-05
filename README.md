# 📦 Sistema de Inventario Distribuido

## Descripción

Aplicación web de gestión de inventario desarrollada en **Flask (Python)** con arquitectura distribuida completamente automatizada. Sistema moderno con autenticación, gestión de productos, consulta en tiempo real, exportación a Excel, balanceo de carga NGINX y replicación MySQL master-slave **100% funcional**.

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   NGINX (LB)   │    │   phpMyAdmin    │    │   MySQL Master  │
│   Puerto: 80    │    │   Puerto: 8080  │    │   Puerto: 3306  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                 ┌────┴────┐
    ┌────┴────┐                 │                 │         │
    │         │                 │                 │   MySQL │
┌───▼───┐ ┌───▼───┐             │             ┌───▼───┐ │ Slave  │
│ Web1  │ │ Web2  │             │             │ Web3  │ │ 3307  │
│(50%)  │ │(33%)  │             │             │(17%)  │ └───────┘
└───────┘ └───────┘             │             └───────┘
```

**🎯 REPLICACIÓN AUTOMÁTICA:** Los datos se sincronizan en tiempo real entre Master y Slave

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
- **⚖️ Balanceo de carga NGINX** automático
- **🔄 Replicación MySQL master-slave** 100% funcional
- **📊 phpMyAdmin con selector Master/Slave**
- **🚀 Configuración completamente automatizada**

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
├── � docker-compose.yml          # Configuración principal de servicios
├── 📄 Dockerfile                  # Imagen de la aplicación Flask
├── 📄 setup-final.ps1             # 🚀 Script de configuración automática
├── � start.sh                    # Script de inicio para contenedores
├──  mysql-init/                 # Scripts de inicialización automática
│   ├── 01-master-init.sql         # Configuración del master + datos
│   └── 02-slave-init.sql          # Configuración del slave + estructura
├── 📁 app/                        # Aplicación Flask
│   ├── app.py                     # Aplicación principal con rutas
│   ├── models.py                  # Modelos SQLAlchemy (User, Product)
│   ├── __init__.py                # Configuración Flask y BD
│   ├── init_db.py                 # Inicializador de BD
│   ├── run.py                     # Punto de entrada de la aplicación
│   ├── requirements.txt           # Dependencias Python
│   └── templates/                 # Plantillas HTML responsivas
│       ├── base.html              # Layout base
│       ├── login.html             # Login moderno
│       ├── inventory.html         # Inventario con búsqueda y filtros
│       ├── register_product.html  # Registro de productos
│       └── edit_product.html      # Edición de cantidad
├── 📁 nginx/                      # Configuración NGINX Load Balancer
│   ├── Dockerfile                 # Imagen personalizada NGINX
│   └── nginx.conf                 # Configuración del balanceador
├── 📄 README.md                   # 📖 Documentación completa
└── 📄 INSTALACION_RAPIDA.md       # 🏃‍♂️ Guía de inicio rápido
```

### **Archivos Clave:**
- **setup-final.ps1**: 🎯 Script principal que automatiza todo el proceso
- **02-slave-init.sql**: 🔄 Garantiza estructura consistente para replicación
- **docker-compose.yml**: 🐳 Orquestación completa con MySQL 5.7

---

## 🚀 Instalación y Uso

### **Prerrequisitos**

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)

### **⚡ Opción 1: Configuración Automática (Recomendado)**

**Para Windows:**
```powershell
# Abrir PowerShell como Administrador
cd "C:\ruta\al\ProyectoDistribuidas"
.\setup-final.ps1
```

✅ **Este script configura automáticamente:**
- Levanta todos los servicios Docker
- Configura la replicación MySQL master-slave
- Verifica que todo funcione correctamente
- Muestra el estado final del sistema

### **Opción 2: Configuración Manual**

```bash
# 1. Clonar el repositorio
git clone https://github.com/Andrespipe1/ProyectoDistribuidas.git
cd ProyectoDistribuidas

# 2. Levantar la infraestructura
docker-compose up --build -d

# 3. Verificar estado
docker-compose ps
```

⚠️ **Nota:** Con la opción manual necesitarás configurar la replicación manualmente.

### **3. Acceder a los servicios**

| Servicio           | URL                   | Credenciales     | Estado |
| ------------------ | --------------------- | ---------------- | ------ |
| **Aplicación Web** | http://localhost      | admin / admin123 | ✅ Activo |
| **phpMyAdmin**     | http://localhost:8080 | root / root      | ✅ Activo |
| **MySQL Master**   | localhost:3306        | root / root      | ✅ Activo |
| **MySQL Slave**    | localhost:3307        | root / root      | ✅ Activo |

### **4. Verificar Replicación Funcionando**

```bash
# Verificar estado de replicación
docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e "SHOW SLAVE STATUS\G" | findstr "Running"

# Resultado esperado:
# Slave_IO_Running: Yes
# Slave_SQL_Running: Yes
```

### **5. Detener y limpiar el entorno**

```bash
docker-compose down           # Detener todo
# Para limpiar volúmenes y datos:
docker-compose down -v --remove-orphans
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

## 🔄 Replicación MySQL Automatizada

### **Estado Actual:**
✅ **COMPLETAMENTE FUNCIONAL** - La replicación master-slave está 100% operativa

- **Slave_IO_Running: Yes** - Conexión estable con el master
- **Slave_SQL_Running: Yes** - Ejecutando consultas correctamente  
- **Sincronización en tiempo real** - Los datos se replican instantáneamente
- **Scripts de inicialización** - Tablas creadas automáticamente en slave

### **Características:**
- 🔄 **Replicación unidireccional**: Master → Slave
- 🚀 **Configuración automática**: Sin intervención manual
- 📊 **Monitoreo incluido**: Visible desde phpMyAdmin
- ⚡ **MySQL 5.7**: Optimizado para mejor rendimiento
- 🛡️ **Estructura consistente**: Tablas idénticas en ambos servidores

### **Verificación de Funcionamiento:**
```bash
# 1. Insertar datos en master
docker exec proyectodistribuidas-db-1 mysql -u root -proot inventario -e "
INSERT INTO product (name, code, description, unit, category) 
VALUES ('Test Replicacion', 'REP001', 'Prueba funcionamiento', 10, 'Testing');"

# 2. Verificar replicación en slave
docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot inventario -e "
SELECT * FROM product WHERE code='REP001';"
```

**Resultado esperado:** El producto aparece automáticamente en el slave.

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

### **Stack Tecnológico:**
- **Backend**: Flask + SQLAlchemy + MySQL 5.7
- **Frontend**: Bootstrap 5 + AJAX + JavaScript
- **Contenedorización**: Docker + Docker Compose
- **Balanceador**: NGINX con distribución por pesos
- **Base de Datos**: MySQL Master-Slave replication
- **Monitoreo**: phpMyAdmin con selector Master/Slave
- **Exportación**: pandas + xlsxwriter para Excel

### **Rendimiento:**
- ⚡ **MySQL 5.7**: Startup optimizado (~30 segundos)
- 🔄 **Replicación en tiempo real**: Latencia < 1 segundo  
- ⚖️ **Balanceo inteligente**: Web1(50%) + Web2(33%) + Web3(17%)
- 📱 **Responsive Design**: Compatible con móviles y tablets

---

## 👤 Autor y Contacto

- **Desarrolladores:** Andrés Tufiño - Darwin Cachimil - Anderson Vilatuña - Wilmer Vargas
- **GitHub:** [Andrespipe1](https://github.com/Andrespipe1)
- **País:** Ecuador



---

## 🎉 Estado del Proyecto

### **✅ COMPLETAMENTE FUNCIONAL**

**Última actualización: Agosto 2025**

- 🚀 **Configuración 100% automática** con `setup-final.ps1`
- 🔄 **Replicación MySQL verificada** (Slave_IO_Running: Yes, Slave_SQL_Running: Yes)
- ⚖️ **Load Balancer operativo** con distribución por pesos
- 📊 **Monitoreo activo** via phpMyAdmin Master/Slave
- 🧹 **Código optimizado** sin archivos innecesarios
- 📱 **Sistema totalmente responsivo** y moderno

### **Instrucciones de Uso:**
1. **Clonar** el repositorio
2. **Ejecutar** `.\setup-final.ps1` (Windows)
3. **Acceder** a http://localhost
4. **¡Listo!** Sistema completamente operativo

**El sistema es totalmente responsivo, moderno y está listo para producción.**

---

## 🛠️ Configuración Manual de Replicación MySQL (Solo si es necesario)

⚠️ **NOTA IMPORTANTE**: La replicación se configura automáticamente con `setup-final.ps1`. Esta sección es solo para casos especiales.

### Estado Actual de la Replicación:
```bash
# Verificar estado (debe mostrar ambos en "Yes")
docker exec proyectodistribuidas-db-slave-1 mysql -u root -proot -e "SHOW SLAVE STATUS\G" | findstr "Running"

# Resultado esperado:
# Slave_IO_Running: Yes
# Slave_SQL_Running: Yes
```

### Solo si necesitas reconfigurar manualmente:

1. **Accede a phpMyAdmin en el master (`db`)**
   - URL: http://localhost:8080
   - Selecciona servidor `Master`
   - Usuario: `root`, Contraseña: `root`

2. **Crear usuario de replicación en el master:**
```sql
CREATE USER 'replicator'@'%' IDENTIFIED BY 'replicator_pass';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
FLUSH PRIVILEGES;
```

3. **Obtener estado del master:**
```sql
SHOW MASTER STATUS;
```

4. **Configurar slave:**
```sql
STOP SLAVE;
CHANGE MASTER TO
  MASTER_HOST='db',
  MASTER_USER='replicator',
  MASTER_PASSWORD='replicator_pass',
  MASTER_LOG_FILE='mysql-bin.000001',  -- usar valor real
  MASTER_LOG_POS=154;                  -- usar valor real
START SLAVE;
```
