FROM php:8.2-apache

# Unzip tool install karein
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

# Apache document root set karein
WORKDIR /var/www/html

# Project files aur zip copy karein
COPY . /var/www/html/

# Agar zip file exist karti hai to use extract karein
RUN if [ -f *.zip ]; then unzip -o *.zip -d /var/www/html/ && rm -f *.zip; fi

# Permissions theek karein
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Render ke PORT environment variable ko Apache ke saath map karne ke liye start script
RUN echo '#!/bin/bash\n\
sed -i "s/80/${PORT:-80}/g" /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf\n\
apache2-foreground' > /start.sh && chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
