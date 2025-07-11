
---

## ¿Qué incluye?

- **3 instancias** de la aplicación Flask (`web1`, `web2`, `web3`)
- **Balanceador de carga NGINX** con balanceo por pesos
- **Base de datos MySQL** (lista para replicación)
- **Persistencia de datos** con volúmenes Docker
- **Usuario administrador** creado automáticamente (`admin` / `admin123`)
- **Scripts de inicialización** para esperar a MySQL y crear tablas/usuario

---

## Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)

---

## Instrucciones de uso

### 1. Clona el repositorio

```bash
git clone https://github.com/tuusuario/ProyectoDistribuidas.git
cd ProyectoDistribuidas
```

### 2. Levanta la infraestructura

```bash
docker-compose up --build
```

- Esto construirá las imágenes y levantará todos los servicios.
- Espera a ver mensajes como:
  - `✅ Base de datos MySQL está lista!`
  - `✅ Tablas creadas exitosamente!`
  - `✅ Usuario administrador creado (admin/admin123)`
  - `🚀 Iniciando aplicación Flask...`

### 3. Accede a la aplicación

- Abre tu navegador y entra a: [http://localhost:80](http://localhost:80)
- Inicia sesión con:
  - **Usuario:** `admin`
  - **Contraseña:** `admin123`

### 4. Prueba el balanceo de carga

- Accede a [http://localhost/health](http://localhost/health) y refresca varias veces.
- Verás el nombre de la instancia que responde (web1, web2 o web3).

---

## ¿Cómo funciona la base de datos?

- **Tablas:** `user` y `product`
- **Contraseñas:** Encriptadas con `werkzeug.security`
- **Validación:** No permite códigos de producto duplicados
- **Persistencia:** Los datos se guardan en un volumen Docker

---

## ¿Cómo funciona el balanceador de carga?

- NGINX distribuye el tráfico entre las 3 instancias de la app.
- El tráfico se reparte según los pesos configurados en `nginx.conf`:
  - web1: 50%
  - web2: 33%
  - web3: 17%

---

## ¿Cómo agregar este proyecto a GitHub?

1. **Inicializa el repositorio (si no lo has hecho):**
   ```bash
   git init
   git add .
   git commit -m "Proyecto base: Inventario distribuido con Docker, NGINX y MySQL"
   ```

2. **Crea el repositorio en GitHub** (desde la web).

3. **Agrega el remoto y sube:**
   ```bash
   git remote add origin https://github.com/tuusuario/ProyectoDistribuidas.git
   git branch -M main
   git push -u origin main
   ```

---

## Notas

- Si quieres agregar replicación MySQL, solo falta agregar el servicio `db-slave` y la configuración de replicación.
- Puedes modificar los pesos en `nginx/nginx.conf` según la capacidad de cada instancia.
- Para pruebas de carga, puedes usar herramientas como [Apache JMeter](https://jmeter.apache.org/) o [Locust](https://locust.io/).

---

## Autor

- **Tu Nombre**
- **Materia:** Tecnologías Distribuidas
- **Docente:** Ing. Vanessa Guevara

---
