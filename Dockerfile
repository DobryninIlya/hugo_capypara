# Используем базовый образ Alpine Linux
FROM alpine:latest

# Устанавливаем необходимые пакеты
RUN apk add --no-cache \
    curl \
    git \
    bash \
    libc6-compat \
    libstdc++ \
    gcc \
    certbot \
    certbot-nginx \
    apache2 \
    apache2-utils

# Устанавливаем последнюю версию Hugo
RUN LATEST_HUGO=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | cut -d '"' -f 4) && \
    curl -L https://github.com/gohugoio/hugo/releases/download/${LATEST_HUGO}/hugo_extended_${LATEST_HUGO#v}_Linux-64bit.tar.gz | tar -xz -C /usr/local/bin

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы проекта в контейнер
COPY . /app

# Инициализируем и обновляем подмодули
RUN git submodule init && git submodule update

# Строим сайт Hugo
RUN hugo --ignoreCache -d /var/www/localhost/htdocs

# Настраиваем Apache
RUN echo "ServerName localhost" >> /etc/apache2/httpd.conf

# Включаем модуль сжатия и настраиваем его
RUN echo "LoadModule deflate_module modules/mod_deflate.so" >> /etc/apache2/httpd.conf && \
    echo "<IfModule mod_deflate.c>" >> /etc/apache2/httpd.conf && \
    echo "  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json" >> /etc/apache2/httpd.conf && \
    echo "</IfModule>" >> /etc/apache2/httpd.conf

# Открываем порт 80 для Apache
EXPOSE 80

# Запускаем Apache сервер
CMD ["httpd", "-D", "FOREGROUND"]