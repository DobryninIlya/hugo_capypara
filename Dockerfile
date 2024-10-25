# Используем базовый образ Alpine Linux
FROM alpine:latest

# Устанавливаем необходимые пакеты (добавляем apache2)
RUN apk add --no-cache \
    curl \
    git \
    bash \
    apache2 \
    libc6-compat \
    libstdc++ \
    gcc

# Устанавливаем последнюю версию Hugo
RUN LATEST_HUGO=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | cut -d '"' -f 4) && \
    curl -L https://github.com/gohugoio/hugo/releases/download/${LATEST_HUGO}/hugo_extended_${LATEST_HUGO#v}_Linux-64bit.tar.gz | tar -xz -C /usr/local/bin

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы проекта в контейнер
COPY . /app

# Инициализируем и обновляем подмодули
RUN git submodule init && git submodule update

# Строим сайт Hugo (статические файлы будут в /app/public)
RUN hugo --ignoreCache

# Переносим сгенерированные статические файлы в директорию Apache
RUN mkdir -p /var/www/html && cp -r /app/public/* /var/www/html/

# Открываем порт для Apache
EXPOSE 80

# Запускаем Apache
CMD ["httpd", "-D", "FOREGROUND"]
