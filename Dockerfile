FROM php:8.2-apache

# Install system dependencies and PHP extensions required by Laravel
RUN apt-get update && apt-get install -y \
    git curl zip unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip mbstring exif pcntl bcmath gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Allow .htaccess overrides for Laravel
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html

# Copy composer binary from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Change Apache root to Laravel's public folder
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf

# Create SQLite database file if it doesn't exist, and fix permissions
RUN touch database/database.sqlite \
    && chown -R www-data:www-data database \
    && chmod -R 775 database

# Install PHP dependencies via Composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Set permissions on storage and bootstrap cache folders
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]

