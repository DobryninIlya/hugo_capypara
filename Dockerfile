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
    certbot-nginx

# Устанавливаем последнюю версию Hugo
RUN LATEST_HUGO=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | cut -d '"' -f 4) && \
    curl -L https://github.com/gohugoio/hugo/releases/download/${LATEST_HUGO}/hugo_extended_${LATEST_HUGO#v}_Linux-64bit.tar.gz | tar -xz -C /usr/local/bin

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы проекта в контейнер
COPY . /app

# Инициализируем и обновляем подмодули
RUN git submodule init && git submodule update

# Устанавливаем зависимости (если есть)
# RUN npm install # для JavaScript зависимостей
# RUN go mod download # для Go зависимостей
LABEL name="hugo_image"
EXPOSE 443

# Строим сайт Hugo
RUN hugo --ignoreCache

# Получаем сертификаты с помощью certbot
#RUN certbot certonly --standalone --non-interactive --agree-tos --email mr.woodysimpson@gmail.com -d numerologistic.ru

# Запускаем Hugo сервер
CMD ["hugo", "server", "--baseURL", "https://numerologistic.ru", "--bind", "0.0.0.0", "--port", "443"]