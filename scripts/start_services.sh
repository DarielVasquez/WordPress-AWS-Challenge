#!/bin/bash

PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")

cd /var/www/html/wordpress

sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php

sed -i "s/username_here/${MYSQL_USER}/" wp-config.php

sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php

sed -i "s/localhost/${DB_HOST}/" wp-config.php

service nginx start

service php${PHP_VERSION}-fpm start

tail -f /dev/null