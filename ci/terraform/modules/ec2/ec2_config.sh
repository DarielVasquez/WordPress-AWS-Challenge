#!/bin/bash

apt-get update
apt-get upgrade -y

echo Installing Nginx, MySQL, and PHP...
apt install -y nginx mariadb-server php-fpm php-mysql
echo Installed Nginx, MySQL, and PHP!

echo Creating MySQL database and user...
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE wordpress_db;
CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo Created MySQL database and user!

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
sed -i 's/database_name_here/wordpress_db/' wp-config.php
sed -i 's/username_here/wordpress_user/' wp-config.php
sed -i 's/password_here/password/' wp-config.php
echo Configured Wordpress!

echo Configuring Nginx...
cd /etc/nginx/sites-available
SERVER_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
echo "upstream php-handler {
        server unix:/var/run/php/php$PHP_VERSION-fpm.sock;
}
server {
        listen 80;
        server_name $SERVER_IP;
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
systemctl restart nginx
echo Configured Nginx!

echo Finished executing!