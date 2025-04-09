#!/bin/bash
# ┌────────────────────────────────────────────────────────────┐
# │  🐾 purpl35p4c3 • GitHub Setup by l1ttl3bugc4t 💜             │
# │  script: git_purrr_setup.sh                                │
# │  desc: instala, configura y conecta GitHub con SSH         │
# └────────────────────────────────────────────────────────────┘

# 🐾 Pedir datos al usuario
read -p "✨ Ingresa tu nombre de usuario Git: " GIT_NAME
read -p "📧 Ingresa tu correo de GitHub: " GIT_EMAIL

echo "🔧 Instalando git..."
sudo apt update && sudo apt install git -y

echo "⚙️ Configurando identidad git..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo "🧪 Verificando configuración..."
git config --list

# 🔐 Crear clave SSH
echo "🔐 Generando clave SSH para GitHub..."
ssh-keygen -t ed25519 -C "$GIT_EMAIL"

# 🐾 Mostrar la clave para agregar en GitHub
echo
echo "📋 Copia esta clave y pégala en GitHub > Settings > SSH and GPG keys:"
echo "────────────────────────────────────────────────────────────"
cat ~/.ssh/id_ed25519.pub
echo "────────────────────────────────────────────────────────────"

# 💡 Opción: configurar git para que siempre use SSH
read -p "¿Quieres que Git use SSH por defecto en lugar de HTTPS? (s/n): " SSH_YN
if [[ "$SSH_YN" == "s" || "$SSH_YN" == "S" ]]; then
  git config --global url."git@github.com:".insteadOf "https://github.com/"
  echo "🐱 Git usará SSH por defecto ahora."
fi

echo
echo "✅ ¡Listo! Git ha sido configurado con estilo purrrfecto."
echo "🐾 Recuerda agregar tu clave pública en GitHub para terminar la conexión."
