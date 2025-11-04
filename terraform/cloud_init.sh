#!/bin/bash
# Script de cloud-init para instalar Docker y Docker Compose en Ubuntu 22.04

# 1. Actualizar paquetes
sudo apt-get update -y

# 2. Instalar Docker
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 3. Añadir el usuario por defecto (ubuntu) al grupo docker para evitar usar sudo
# El usuario en la imagen de Ubuntu en OCI suele ser 'ubuntu' o el que uses.
# Asumo 'ubuntu'
if id -u ubuntu >/dev/null 2>&1; then
    sudo usermod -aG docker ubuntu
else
    # Si el usuario es distinto, identifica al usuario principal de la instancia.
    echo "Usuario 'ubuntu' no encontrado, ajusta el script si usas otro usuario."
fi

# 4. Habilitar y arrancar el servicio Docker
sudo systemctl enable docker
sudo systemctl start docker

echo "Docker y Docker Compose (plugin) instalados y listos."