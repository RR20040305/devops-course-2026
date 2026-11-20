# Конфигурация виртуальной машины devops-vm

## 1. Параметры машины
- ОЗУ: 2048 МБ
- Ядра: 2
- Диск: 25 ГБ

## 2. Сетевые интерфейсы
- Адаптер 1 (NAT): 10.0.2.15
- Адаптер 2 (Host-only): 192.168.56.101

## 3. Правило проброса портов
- Порт хоста: 2222
- Порт гостя: 2222

## 4. Учётные записи
- student (sudo, пароль)
- devops (sudo, ключ ed25519)

## 5. Служба SSH
- Порт: 2222
- Конфигурация: /etc/ssh/sshd_config.d/99-hardening.conf
- Директивы: PermitRootLogin no, PasswordAuthentication no, MaxAuthTries 3, AllowUsers devops

## 6. Правила межсетевого экрана (UFW)
- default deny incoming, default allow outgoing
- allow 2222/tcp (LIMIT)
- allow 80/tcp
- allow 443/tcp

## 7. Снимки состояния
- 01-clean-install
- 02-keys-configured
- 03-ssh-hardened
- 04-nginx-https
- 05-docker-compose

## 8. Веб-сервер (Nginx)
- Пакет: nginx
- Конфигурация ресурса: /etc/nginx/sites-available/devops-site
- Каталог ресурса: /var/www/devops-site (владелец: devops:devops, права: 755)
- Сертификат: /etc/ssl/certs/devops.crt (права 644)
- Ключ: /etc/ssl/private/devops.key (права 600, владелец root)
- Срок действия сертификата: 365 дней

## 9. Контейнеризация (Docker)
- Пакет: docker-ce, docker-compose-plugin
- Приложение: Flask (образ devops-app:1.0)
- Конфигурация: ~/app/docker-compose.yml
- СУБД: PostgreSQL 16 (том db_data)
- Порт приложения: 127.0.0.1:5000 (доступен только локально)
- Nginx проксирует /app/ на http://127.0.0.1:5000/
