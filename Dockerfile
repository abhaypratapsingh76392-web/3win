FROM php:8.2-apache

# Unzip install karein
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

# Apache Rewrite Module enable karein (.htaccess ke liye zaroori hai)
RUN a2enmod rewrite

# Apache me .htaccess allow karne ke liye configuration update karein
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Document root
WORKDIR /var/www/html

# Files copy karein
COPY . /var/www/html/

# Zip extract karein agar exist karti hai
RUN if [ -f *.zip ]; then unzip -o *.zip -d /var/www/html/ && rm -f *.zip; fi

# Permissions theek karein
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Render PORT mapping script
RUN echo '#!/bin/bash\n\
sed -i "s/80/${PORT:-80}/g" /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf\n\
apache2-foreground' > /start.sh && chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
