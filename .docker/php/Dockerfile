FROM dunglas/frankenphp:php8.3-alpine

COPY Caddyfile /etc/frankenphp/Caddyfile

# INSTALL COMPOSER
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN apk add --update --no-cache \
    nss-tools \
    ca-certificates \
    bash \
    su-exec

RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | bash
RUN apk add --no-cache symfony-cli

RUN install-php-extensions \
    pdo_pgsql \
    gd \
    intl \
    zip 

RUN mkdir -p /var/log/caddy

WORKDIR /app
