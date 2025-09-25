Modify your php/Dockerfile to install Composer automatically when you build the image. Example:

FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libonig-dev libxml2-dev libpng-dev \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl

# Install Composer globally
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
