

---

### **README.md**

```markdown
# 🚀 CI/CD Pipeline con Docker, Flask, MySQL, Nginx y AWS

Este repositorio implementa un pipeline de **CI/CD** que despliega automáticamente una aplicación web en Flask utilizando
**MySQL** como base de datos, **Nginx** como balanceador de carga, y **Docker Compose** para la orquestación de contenedores.
El despliegue se realiza en una instancia **EC2 de AWS**, utilizando **GitHub Actions** para la integración continua.

---

## 📂 Estructura del Proyecto

```plaintext
docker-mysql-nginx-flask-cicd
├── docker-compose.yml       # Configuración de servicios Docker
├── flask-app/
│   ├── app.py               # Código principal de la aplicación Flask
│   ├── requirements.txt     # Dependencias necesarias para la app Flask
│   └── Dockerfile           # Dockerfile para construir la app Flask
├── mysql/
│   ├── my.cnf               # Configuración personalizada de MySQL
│   ├── Dockerfile           # Dockerfile para configurar el contenedor MySQL
│   └── init-scripts/
│       └── init.sql         # Script SQL de inicialización de MySQL
├── nginx/
│   ├── nginx.conf           # Configuración del servidor web Nginx
│   └── Dockerfile           # Dockerfile para el contenedor Nginx
├── terraform/
│   ├── main.tf              # Configuración principal de Terraform
│   ├── outputs.tf           # Definición de salidas de Terraform
│   ├── providers.tf         # Configuración de proveedores en Terraform
│   └── variables.tf         # Variables para parametrizar en Terraform
└── README.md                # Descripción del proyecto
```

---

## 🛠️ Requisitos Previos

### **1. Infraestructura**
- **Instancia EC2 (AWS Free Tier)**:
  - **AMI**: Ubuntu Server 20.04 LTS
  - **Tipo de Instancia**: t2.micro
  - **Puertos abiertos**: 22 (SSH), 80 (HTTP)

---

### **A. Generar un nuevo par de claves SSH en la EC2**
Conéctate a tu instancia EC2 desde la consola de AWS (usando Session Manager o el cliente SSH que funcione actualmente).

Ejecuta el siguiente comando para generar el par de claves:
```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
```

Esto hará lo siguiente:
- Generará un par de claves (`id_rsa` y `id_rsa.pub`) en el directorio `~/.ssh`.
- Dejará la clave privada (`id_rsa`) protegida sin contraseña.

---

### **B. Configurar la clave pública en `authorized_keys`**
Agrega la clave pública recién creada al archivo `authorized_keys`:
```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

---

### **C. Descargar la clave privada (opcional)**
Para poder usar la nueva clave privada desde tu máquina local o GitHub Actions, descárgala desde la EC2:

#### **C.1. Usando `cat` y copiar manualmente**
Muestra el contenido de la clave privada:
```bash
cat ~/.ssh/id_rsa
```

Copia el contenido completo (incluyendo las líneas `-----BEGIN RSA PRIVATE KEY-----` y `-----END RSA PRIVATE KEY-----`) y guárdalo en un archivo local, por ejemplo, `my_ec2_key.pem`.

---

#### **C.2. Usando `scp`**
Si tienes acceso desde otra máquina, usa `scp` para transferir la clave privada directamente:
```bash
scp -i /ruta/a/tu/clave_actual.pem martin@<IP_PUBLICA_EC2>:~/.ssh/id_rsa ./my_ec2_key.pem
```

---

### **D. Configurar permisos locales para la clave**
Asegúrate de que la clave privada tenga los permisos adecuados en tu máquina local:
```bash
chmod 600 my_ec2_key.pem
```

---

### **E. Probar la conexión con la nueva clave**
Desde tu máquina local, prueba conectarte con la nueva clave:
```bash
ssh -i ./my_ec2_key.pem martin@<IP_PUBLICA_EC2>
```
---


### **2. Software en la instancia EC2**
Instala Docker y Docker Compose ejecutando:
```bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y
sudo apt install git -y

# Instalar Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar versiones
docker --version
docker-compose --version
```

---

## ⚙️ Configuración del Pipeline CI/CD

### **Archivos Clave**
1. **`Dockerfile`**: Define cómo construir la imagen Docker para la aplicación Flask.
2. **`docker-compose.yml`**: Orquesta los servicios: Flask, MySQL y Nginx.
3. **`deploy.yml`**: Configura el flujo CI/CD en GitHub Actions para automatizar el despliegue.

### **Pipeline CI/CD**
El flujo está definido en `.github/workflows/deploy.yml` y realiza los siguientes pasos:

1. **Clonar el repositorio**:
   Baja el código fuente desde GitHub.

2. **Configurar la clave SSH**:
   Crea y configura un archivo `id_rsa` con la clave privada almacenada en los secretos de GitHub.

3. **Conectar a la instancia EC2**:
   Usa SSH para acceder de forma segura al servidor remoto.

4. **Actualizar la aplicación**:
   - Detiene los contenedores activos.
   - Descarga las nuevas imágenes desde Docker Hub.
   - Reinicia los contenedores usando `docker-compose`.

---

## 🚀 Instrucciones de Despliegue

### **1. Clonar el repositorio**
```bash
git clone https://github.com/MartinM-17/docker-mysql-nginx-flask-cicd.git
cd docker-mysql-nginx-flask-cicd
```

### **2. Configurar los secretos en GitHub**
Agrega los siguientes secretos en **Settings > Secrets** de tu repositorio:

| Nombre del Secreto       | Descripción                          |
|--------------------------|--------------------------------------|
| `AWS_SSH_PRIVATE_KEY`    | Contenido de la clave privada SSH.  |
| `DOCKER_USERNAME`        | Usuario de Docker Hub.              |
| `DOCKER_PASSWORD`        | Contraseña de Docker Hub.           |
| `DB_HOST`                | Dirección de la base de datos.      |
| `DB_USER`                | Usuario de la base de datos.        |
| `DB_PASSWORD`            | Contraseña de la base de datos.     |
| `DB_NAME`                | Nombre de la base de datos.         |
| `VM_HOST`                | IP pública de la instancia EC2.     |

### **3. Activar el Pipeline**
Realiza un push a la rama `main`:
```bash
git add .
git commit -m "Despliegue inicial"
git push origin main
```

### **4. Verificar la aplicación**
- Accede a la IP pública de tu instancia EC2 en el navegador:
  ```
  http://<EC2_PUBLIC_IP>
  ```

---

## 📋 Ejemplo de Configuración del Deploy (deploy.yml)

```yaml
name: Deploy to EC2

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Setup SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.AWS_SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa

      - name: SSH to EC2 and deploy
        run: |
          ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@<EC2_PUBLIC_IP> << 'EOF'
            cd ~/app
            docker-compose down
            docker-compose pull
            docker-compose up -d
          EOF
```

---

## 📚 Referencias
- [Guía de EC2 en AWS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
- [Documentación oficial de Docker](https://docs.docker.com/)
- [GitHub Actions](https://docs.github.com/en/actions)

---

