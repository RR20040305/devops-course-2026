#!/usr/bin/env bash
set -uo pipefail

PASS=0; FAIL=0

check() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$actual" == "$expected" ]]; then
    echo " [OK]   $desc"
    ((PASS++))
  else
    echo " [FAIL] $desc (ожидалось: '$expected', получено: '$actual')"
    ((FAIL++))
  fi
}

echo " [1] Служба SSH"
check "Вход от имени root запрещён" "no" "$(sudo sshd -T | awk '/^permitrootlogin/{print $2}')"
check "Парольная аутентификация отключена" "no" "$(sudo sshd -T | awk '/^passwordauthentication/{print $2}')"
check "MaxAuthTries равен 3" "3" "$(sudo sshd -T | awk '/^maxauthtries/{print $2}')"
PORT=$(sudo sshd -T | awk '/^port/{print $2}')
if [[ "$PORT" != "22" ]]; then
    echo " [OK]   Порт SSH отличен от 22 (port=$PORT)"; ((PASS++))
else
    echo " [FAIL] Порт SSH равен 22"; ((FAIL++))
fi

echo " [2] Межсетевой экран (UFW)"
check "Межсетевой экран активен" "active" "$(sudo ufw status | awk '/^Status:/{print $2}')"
check "Политика incoming = deny" "deny" "$(sudo ufw status verbose | awk '/^Default:/{print $2}')"

echo " [3] Веб-сервер Nginx"
check "Nginx активен" "active" "$(systemctl is-active nginx 2>/dev/null || echo 'inactive')"
check "Синтаксис Nginx корректен" "0" "$(sudo nginx -t >/dev/null 2>&1; echo $?)"

echo " [4] Безопасность ресурсов"
check "Права ключа 600" "600" "$(sudo stat -c '%a' /etc/ssl/private/devops.key 2>/dev/null || echo 'missing')"
check "Сертификат действителен >30 дней" "0" "$(sudo openssl x509 -checkend 2592000 -noout -in /etc/ssl/certs/devops.crt >/dev/null 2>&1; echo $?)"
check "Нет файлов с правами 666 в /var/www" "" "$(sudo find /var/www/devops-site -perm -o+w -type f 2>/dev/null)"

echo " [5] Контейнеризация (Docker)"
check "Docker Compose app запущен" "running" "$(cd ~/app 2>/dev/null && docker compose ps --services --filter status=running | grep -q '^app$' && echo 'running' || echo 'not running')"
check "Порт 5000 не слушает извне" "" "$(sudo ss -tlnp | grep '0.0.0.0:5000' || true)"

echo "----------------------------------------"
echo "Пройдено: $PASS, не пройдено: $FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
