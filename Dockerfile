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
    nginx

# Устанавливаем последнюю версию Hugo
RUN LATEST_HUGO=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | cut -d '"' -f 4) && \
    curl -L https://github.com/gohugoio/hugo/releases/download/${LATEST_HUGO}/hugo_extended_${LATEST_HUGO#v}_Linux-64bit.tar.gz | tar -xz -C /usr/local/bin

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы проекта в контейнер
COPY . /app

# Инициализируем и обновляем подмодули
RUN git submodule init && git submodule update

# Строим статический сайт с помощью Hugo
RUN hugo --ignoreCache -d /var/www/html

# Настраиваем NGINX
COPY nginx.conf /etc/nginx/nginx.conf

# Открываем порт 80 для сервера
EXPOSE 443

# Запуск NGINX
CMD ["nginx", "-g", "daemon off;"]
