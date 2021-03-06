#!/bin/bash

# Install required apps
apt-get update
apt-get install -y wget unzip
docker-php-ext-install mysqli pdo pdo_mysql
mkdir -p /var/www/

# Download Invoice Ninja
cd /tmp/
wget -O invoice-ninja.zip https://download.invoiceninja.com/

# Unzip and set Invoice Ninja permissions
unzip invoice-ninja.zip -d /var/www/
mv /var/www/ninja /var/www/invoice-ninja
chown www-data:www-data /var/www/invoice-ninja/ -R
chmod 755 /var/www/invoice-ninja/storage/ -R

# Add Invoice Ninja Virtual Host
echo "<VirtualHost *:80>
    DocumentRoot /var/www/invoice-ninja/public

    <Directory /var/www/invoice-ninja/public>
       DirectoryIndex index.php
       Options +FollowSymLinks
       AllowOverride All
       Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/invoice-ninja.error.log
    CustomLog ${APACHE_LOG_DIR}/invoice-ninja.access.log combined
</VirtualHost>" >> /etc/apache2/sites-available/invoice-ninja.conf

# Adjust Apache config and restart
a2dissite 000-default.conf
a2ensite invoice-ninja.conf
a2enmod rewrite
service apache2 reload
