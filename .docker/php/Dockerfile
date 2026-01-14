FROM dunglas/frankenphp:php8.3-alpine

COPY Caddyfile /etc/frankenphp/Caddyfile

RUN apk add --no-cache \
    nss-tools \
    ca-certificates

RUN install-php-extensions \
    pdo_pgsql \
    gd \
    intl \
    zip \
    opcache

RUN mkdir -p /var/log/caddy

WORKDIR /app