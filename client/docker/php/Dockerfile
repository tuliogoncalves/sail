FROM php:8.1-fpm
LABEL stage=local

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    supervisor \
    procps

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Install redis
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Install star-container
COPY ./docker/supervisor/start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

# Copy php config install
COPY ./docker/php/php.ini /usr/local/etc/php/conf.d/php.ini

# Set working directory
WORKDIR /var/www

# Expose port 9000
EXPOSE 9000

USER $user

ENTRYPOINT ["start-container"]
