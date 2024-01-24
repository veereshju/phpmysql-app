#!/bin/bash
sudo mkdir /var/www/html/myecommerce
sudo cp -rf php/online-shopping-system/* /var/www/html/myecommerce/.
#echo "DocumentRoot /var/www/html/bookalbum" | sudo tee -a  /etc/apache2/sites-available/000-default.conf
#sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/bookalbum|' /etc/apache2/sites-available/000-default.conf
sudo sed -E -i 's|DocumentRoot[[:space:]]+/var/www/html/[^[:space:]]*|DocumentRoot /var/www/html/myecommerce|' /etc/apache2/sites-available/000-default.conf
sudo systemctl restart apache2

# MySQL credentials
DB_USER="msois"
DB_PASSWORD="Msois@123"
DB_HOST="localhost"
DB_NAME="myecommerce"

# SQL script
SQL_SCRIPT="php/online-shopping-system/database/onlineshop.sql"

# Execute SQL script using MySQL client
mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD $DB_NAME < $SQL_SCRIPT
