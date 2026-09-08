FROM php:8.2-apache

# Unzip aur zaroori database/graphics libraries install karein
RUN apt-get update && apt-get install -y \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions jo script files ko chahiye hoti hain
RUN docker-php-ext-install mysqli pdo pdo_mysql gd zip

# Apache rewrite module enable karein
RUN a2enmod rewrite

# .htaccess allow karein
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Production PHP settings: Screen par se saare Notices, Warnings aur Deprecated errors band karein
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && echo "display_errors = Off" >> "$PHP_INI_DIR/php.ini" \
    && echo "display_startup_errors = Off" >> "$PHP_INI_DIR/php.ini" \
    && echo "error_reporting = E_ALL & ~E_NOTICE & ~E_WARNING & ~E_DEPRECATED" >> "$PHP_INI_DIR/php.ini" \
    && echo "log_errors = On" >> "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html

# Saari files copy karein
COPY . /var/www/html/

# Zip extract karein agar maujood ho
RUN if [ -f *.zip ]; then unzip -o *.zip -d /var/www/html/ && rm -f *.zip; fi

# Permissions theek karein
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Render dynamic PORT start script
RUN echo '#!/bin/bash\n\
sed -i "s/80/${PORT:-80}/g" /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf\n\
apache2-foreground' > /start.sh && chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
