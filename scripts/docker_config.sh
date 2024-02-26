#!/bin/bash

apt-get update
apt-get upgrade -y

echo Installing Nginx, MySQL, and PHP...
# DEBIAN_FRONTEND=noninteractive apt-get install -y nginx mariadb-server php-fpm php-mysql wget
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx php-fpm php-mysql wget vim
echo Installed Nginx, MySQL, and PHP!

# echo Creating MySQL database and user...
# service mariadb start
# mysql -u root <<MYSQL_SCRIPT
# CREATE DATABASE wordpress_db;
# CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'password';
# GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';
# FLUSH PRIVILEGES;
# MYSQL_SCRIPT
# echo Created MySQL database and user!

echo Installing WordPress...
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
rm latest.tar.gz
echo Installed WordPress!

echo Configuring WordPress...
chown -R www-data:www-data wordpress
find wordpress/ -type d -exec chmod 755 {} \;
find wordpress/ -type f -exec chmod 644 {} \;
cd wordpress
cp wp-config-sample.php wp-config.php
sed -i "/<?php/a if (\$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') { \$_SERVER['HTTPS'] = 'on'; }" wp-config.php 
echo Configured Wordpress!

echo Configuring Nginx...
cd /etc/nginx/sites-available
SERVER_NAME=$SERVER_NAME
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
service nginx start
service php${PHP_VERSION}-fpm start
echo "upstream php-handler {
        server unix:/var/run/php/php$PHP_VERSION-fpm.sock;
}
server {
        listen 80;
        server_name $SERVER_NAME;
        root /var/www/html/wordpress;
        index index.php;
        location / {
                try_files \$uri \$uri/ /index.php?\$args;
        }
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass php-handler;
        }
}" >> wordpress.conf
ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/
nginx -t
service nginx restart
echo Configured Nginx!

echo Finished executing!