# Proyecto de Autenticación con FreeRADIUS, MariaDB, Apache y Nginx

Este proyecto proporciona un sistema de autenticación centralizada utilizando FreeRADIUS, MariaDB, Apache y Nginx, todo desplegado con Docker. Está diseñado para ser fácil de reproducir y de entender, incluso si tienes pocos conocimientos técnicos.

---

## Tecnologías Utilizadas y su Rol en el Proyecto

### Docker
[Docker](https://www.docker.com/) es una plataforma que permite empaquetar, distribuir y ejecutar aplicaciones en contenedores. Un contenedor es una unidad ligera y portátil que incluye todo lo necesario para ejecutar una aplicación: código, dependencias, configuraciones y sistema base. En este proyecto, **Docker** se usa para aislar cada servicio (FreeRADIUS, MariaDB, Apache y Nginx) en su propio contenedor, facilitando la instalación, despliegue y portabilidad del sistema. Todo se orquesta con `docker-compose` para que puedas levantar el entorno completo con un solo comando.

### Apache
[Apache HTTP Server](https://httpd.apache.org/) es uno de los servidores web más usados en el mundo. En este proyecto, **Apache** se utiliza como servidor web principal y se configura con el módulo `libapache2-mod-auth-radius` para proteger el acceso a recursos web mediante autenticación RADIUS. Apache recibe las peticiones desde Nginx y, antes de servir el contenido, valida las credenciales del usuario preguntando a FreeRADIUS.

### Nginx
[Nginx](https://nginx.org/) es un servidor web y proxy inverso muy eficiente. Aquí, **Nginx** actúa como proxy inverso delante de Apache. Su función es recibir todas las peticiones HTTP externas y reenviarlas a Apache solo si el usuario está autenticado. Utiliza la directiva `auth_request` para delegar la autenticación a Apache, asegurando que solo usuarios válidos puedan acceder a los recursos protegidos.

### FreeRADIUS
[FreeRADIUS](https://freeradius.org/) es un servidor de autenticación RADIUS de código abierto, ampliamente utilizado para gestionar el acceso a redes y servicios. En este proyecto, **FreeRADIUS** valida las credenciales de los usuarios consultando la base de datos MariaDB. Apache se comunica con FreeRADIUS usando el protocolo RADIUS para autenticar a los usuarios que intentan acceder al sitio web.

#### ¿Cómo se integran?
- **Docker** ejecuta y aísla cada servicio.
- **Nginx** recibe la petición y pide autenticación a **Apache**.
- **Apache** solicita la validación de credenciales a **FreeRADIUS** mediante RADIUS.
- **FreeRADIUS** consulta a **MariaDB** para verificar usuario y contraseña.
- Si todo es correcto, el usuario accede al recurso.

---

## Tabla de Contenidos
1. [Descripción General](#descripción-general)
2. [Requisitos Previos](#requisitos-previos)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Guía Paso a Paso](#guía-paso-a-paso)
    - [1. Clonar el Proyecto](#1-clonar-el-proyecto)
    - [2. Configuración de MariaDB](#2-configuración-de-mariadb)
    - [3. Configuración de FreeRADIUS](#3-configuración-de-freeradius)
    - [4. Configuración de Apache](#4-configuración-de-apache)
    - [5. Configuración de Nginx](#5-configuración-de-nginx)
    - [6. Levantar los Servicios](#6-levantar-los-servicios)
    - [7. Añadir Usuarios](#7-añadir-usuarios)
5. [¿Cómo Funciona la Integración?](#cómo-funciona-la-integración)
6. [Comandos Útiles](#comandos-útiles)
7. [Notas y Consejos](#notas-y-consejos)

---

## Requisitos Previos
- Tener [Docker](https://docs.docker.com/get-docker/) y [Docker Compose](https://docs.docker.com/compose/install/) instalados.
- Sistema operativo compatible (Linux, Windows, MacOS).

---

## Estructura del Proyecto
- `docker-compose.yaml`: Orquestación de todos los servicios.
- `freeradius/`: Archivos y configuración de FreeRADIUS.
- `mariadb/`: Scripts y esquema de la base de datos.
- `server/`: Configuración de Apache y autenticación.
- `nginx/`: Configuración de Nginx como proxy inverso.

---

## Guía Paso a Paso

### 1. Clonar el Proyecto
```bash
git clone <URL_DEL_REPOSITORIO>
cd freeradius-auth
```

### 2. Configuración de MariaDB
- MariaDB almacena los usuarios y contraseñas para autenticación.
- Los archivos importantes son:
  - `schema.sql`: Crea las tablas necesarias para FreeRADIUS.
  - `create_user.sh`: Script para añadir usuarios.
  - `setup_schema.sh`: Inicializa la base de datos.
- Las credenciales por defecto están en `docker-compose.yaml`:
  - Usuario: `radius`
  - Contraseña: `radpass`

No necesitas hacer nada manualmente: los scripts se ejecutan automáticamente al iniciar el contenedor.

### 3. Configuración de FreeRADIUS
- FreeRADIUS se conecta a MariaDB para validar usuarios.
- El archivo `clients.conf` define qué clientes pueden conectarse (en este caso, el servidor Apache).
- El archivo `sql` y su enlace simbólico activan el módulo SQL para usar MariaDB.

### 4. Configuración de Apache
- Apache se configura para usar autenticación RADIUS mediante el módulo `libapache2-mod-auth-radius`.
- El archivo `000-default.conf` contiene la configuración del sitio.
- Se crea una página de ejemplo en `/var/www/html/index.html`.

### 5. Configuración de Nginx
- Nginx actúa como proxy inverso y controla el acceso usando autenticación delegada a Apache.
- El archivo `nginx.conf` define:
  - El proxy hacia Apache (`proxy_pass http://server/auth/`)
  - El uso de `auth_request` para proteger rutas.

### 6. Levantar los Servicios
Simplemente ejecuta:
```bash
docker-compose up --build
```
Esto descargará las imágenes necesarias, construirá los contenedores y levantará todo el sistema.

### 7. Añadir Usuarios
Para añadir un usuario a la base de datos RADIUS:
```bash
docker exec -it freeradius-mariadb bash
cd /docker-entrypoint-initdb.d
./create_user.sh <usuario> <contraseña>
```
Reemplaza `<usuario>` y `<contraseña>` por los datos deseados.

---

## ¿Cómo Funciona la Integración?

1. **MariaDB** almacena los usuarios y contraseñas.
2. **FreeRADIUS** consulta a MariaDB para autenticar usuarios.
3. **Apache** usa FreeRADIUS para autenticar accesos web.
4. **Nginx** recibe las peticiones y las pasa a Apache solo si el usuario está autenticado.

El flujo es:
- El usuario accede a Nginx → Nginx pide autenticación a Apache (/auth) → Apache valida con FreeRADIUS → FreeRADIUS consulta a MariaDB.

---

## Comandos Útiles
- **Levantar servicios:**
  ```bash
  docker-compose up --build
  ```
- **Detener servicios:**
  ```bash
  docker-compose down
  ```
- **Ver logs de un servicio:**
  ```bash
  docker-compose logs <servicio>
  ```
  Ejemplo: `docker-compose logs freeradius`

---

## Notas y Consejos
- Puedes modificar las contraseñas y usuarios en `docker-compose.yaml` si lo deseas.
- Para limpiar todo y empezar de cero, elimina el volumen de MariaDB:
  ```bash
  docker volume rm freeradius-auth_mariadb_data
  ```
- Si tienes dudas, revisa los archivos de configuración en cada carpeta.

---

¡Listo! Ahora tienes un sistema de autenticación centralizada fácil de desplegar y entender.
