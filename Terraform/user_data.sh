#!/bin/bash
# Actualiza el sistema
yum update -y

# Instala Git
yum install -y git

# Instala Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Agrega el usuario "martin" y lo agrega al grupo "docker"
useradd martin
usermod -aG docker martin

# Instala Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Habilita el acceso SSH sin contraseña para el usuario "martin"
echo "martin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
