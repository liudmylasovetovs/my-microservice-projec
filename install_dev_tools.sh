#!/bin/bash
set -e

echo "=== Оновлення індексу пакетів ==="
sudo apt-get update -y

echo "=== Перевірка та встановлення Docker ==="
if ! command -v docker >/dev/null 2>&1; then
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  echo "Docker встановлено"
else
  echo "Docker вже встановлений"
fi

echo "=== Перевірка та встановлення Docker Compose ==="
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  echo "Docker Compose (v2) вже встановлений"
elif command -v docker-compose >/dev/null 2>&1; then
  echo "Docker Compose (v1) вже встановлений"
else
  sudo apt-get install -y docker-compose-plugin || sudo apt-get install -y docker-compose
  echo "Docker Compose встановлено"
fi

echo "=== Перевірка та встановлення Python ==="
if ! command -v python3 >/dev/null 2>&1; then
  sudo apt-get install -y python3 python3-pip
  echo "Python встановлено"
else
  echo "Python вже встановлений: $(python3 -V)"
  command -v pip3 >/dev/null 2>&1 || sudo apt-get install -y python3-pip
fi

echo "=== Перевірка та встановлення Django ==="
if ! python3 -m django --version >/dev/null 2>&1; then
  # ставимо для поточного користувача; якщо скрипт запущено через sudo —
  # проведемо інсталяцію від імені реального користувача
  RUN_AS="${SUDO_USER:-$USER}"
  sudo -u "$RUN_AS" pip3 install --user --break-system-packages "Django>=4"
  sudo -u "$RUN_AS" python3 -m django --version
  echo "Django встановлено (user-site)"
else
  echo "Django вже встановлений: $(python3 -m django --version)"
fi

echo "=== Усі інструменти готові! ==="
