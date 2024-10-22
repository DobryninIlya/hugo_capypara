# Используем базовый образ Alpine Linux
FROM alpine:latest

# Устанавливаем необходимые пакеты
RUN apk add --no-cache \
    curl \
    git \
    bash \
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

# Устанавливаем зависимости (если есть)
# RUN npm install # для JavaScript зависимостей
# RUN go mod download # для Go зависимостей
LABEL name="hugo_image"
EXPOSE 1313

# Строим сайт Hugo
RUN hugo

# Запускаем Hugo сервер
CMD ["hugo", "server", "--bind", "0.0.0.0"]