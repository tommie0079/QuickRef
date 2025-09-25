FROM php:8.2-fpm

# Install system deps and PHP extensions commonly needed (pdo_mysql, zip, gd, etc.)
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libssl-dev \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    git \
    unzip \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) pdo pdo_mysql zip gd \
  && rm -rf /var/lib/apt/lists/*

# Create working dir and ensure permissions are sane
WORKDIR /var/www/html

# Expose the standard FPM port for Nginx to connect to
EXPOSE 9000

# Note:
# Official php images generally come with ext-openssl enabled. After building you can verify inside the container:
#   docker-compose exec php php -m | grep -i openssl
# or create a phpinfo() page in www/ to confirm.
