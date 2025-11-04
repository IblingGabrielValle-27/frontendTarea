#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive  # Evita prompts interactivos

USER_TO_ADD="$1"  # Usuario SSH (ej. opc)

# -------------------------------------------------------------
# 0️⃣ Esperar a que apt/dpkg esté libre
# -------------------------------------------------------------
echo "⏳ Esperando a que otros procesos de apt terminen..."
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Lock de apt activo, esperando 5s..."
    sleep 5
done

# -------------------------------------------------------------
# 1️⃣ Actualizar sistema y dependencias básicas
# -------------------------------------------------------------
echo "🔧 --- 1. Actualizando sistema y dependencias básicas ---"
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Activar repositorios universe y multiverse
sudo sed -i 's/^# deb http/deb http/g' /etc/apt/sources.list
sudo apt-get update -y

# Instalar ufw si está disponible
if ! command -v ufw &> /dev/null; then
    sudo apt-get install -y ufw || echo "⚠ ufw no disponible, se omite"
else
    echo "ufw ya instalado"
fi

# -------------------------------------------------------------
# 2️⃣ Instalar Docker y Docker Compose
# -------------------------------------------------------------
echo "🐳 --- 2. Instalando Docker y Docker Compose ---"
if ! command -v docker &> /dev/null; then
    echo "Instalando Docker..."
    sudo mkdir -p /etc/apt/keyrings
    sudo rm -f /etc/apt/keyrings/docker.gpg  # Eliminar clave vieja si existe

    # Descargar clave con reintentos y sin TTY
    curl -fsSL --retry 5 --retry-delay 3 https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor --no-tty --batch -o /etc/apt/keyrings/docker.gpg

    # Agregar repositorio
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "✅ Docker instalado."
else
    echo "Docker ya estaba instalado."
fi

# Alias docker-compose clásico
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_PATH=$(find /usr/lib* -name docker-compose -type f 2>/dev/null | head -n1)
    if [ -n "$DOCKER_COMPOSE_PATH" ]; then
        sudo ln -sf "$DOCKER_COMPOSE_PATH" /usr/local/bin/docker-compose
        echo "✅ Alias docker-compose creado."
    else
        echo "⚠ No se encontró el binario de docker-compose plugin, se omite alias."
    fi
fi

# -------------------------------------------------------------
# 3️⃣ Configurar usuario para Docker
# -------------------------------------------------------------
echo "👤 --- 3. Configurando permisos del usuario ---"
sudo usermod -aG docker "$USER_TO_ADD"

# -------------------------------------------------------------
# 4️⃣ Configurar Firewall (22 y 80)
# -------------------------------------------------------------
echo "🧱 --- 4. Configurando Firewall (puerto 22 y 80) ---"
if command -v ufw &> /dev/null; then
    if sudo ufw status | grep -q inactive; then
        sudo ufw allow 22/tcp
        sudo ufw allow 80/tcp
        echo "y" | sudo ufw enable
    else
        echo "⚙ UFW ya habilitado, asegurando reglas..."
        sudo ufw allow 22/tcp
        sudo ufw allow 80/tcp
    fi
    sudo ufw status verbose
fi

# -------------------------------------------------------------
# 5️⃣ Preparar directorio de despliegue
# -------------------------------------------------------------
echo "📁 --- 5. Preparando directorio de despliegue ---"
DEPLOY_PATH="/home/$USER_TO_ADD/deploy"
sudo mkdir -p "$DEPLOY_PATH"
sudo chown -R "$USER_TO_ADD":"$USER_TO_ADD" "$DEPLOY_PATH"

echo "✅ --- Configuración de la VM completada correctamente ---"