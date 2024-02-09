#!/bin/bash
#sudo mkdir /var/www/html/myecommerce
#sudo cp -rf php/online-shopping-system/* /var/www/html/myecommerce/.

# Destination directory
DEST_DIR="/var/www/html/myecommerce"

# Check if the destination directory exists
if [ ! -d "$DEST_DIR" ]; then
    # If the directory doesn't exist, create it
    sudo mkdir -p "$DEST_DIR"
    
    # Copy files only if the destination directory was created
    if [ $? -eq 0 ]; then
        sudo cp -rf php/online-shopping-system/* "$DEST_DIR/"
        echo "Files copied to $DEST_DIR."
    else
        echo "Failed to create directory $DEST_DIR."
    fi
else
    echo "Directory $DEST_DIR already exists. Skipping copy."
fi
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
#mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
#mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD $DB_NAME < $SQL_SCRIPT

# MySQL command to check if the user already exists
CHECK_USER_QUERY="SELECT user FROM mysql.user WHERE user = 'msois';"

# MySQL command to create the user
CREATE_USER_QUERY="CREATE USER IF NOT EXISTS 'msois'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Msois@123';"

# MySQL command to grant privileges to the user
GRANT_PRIVILEGES_QUERY="GRANT ALL PRIVILEGES ON *.* TO 'msois'@'localhost' WITH GRANT OPTION;"

# MySQL command to flush privileges
FLUSH_PRIVILEGES_QUERY="FLUSH PRIVILEGES;"

# Execute MySQL commands
mysql -u"$DB_USER" -p"$DB_PASSWORD" -h"$DB_HOST" -e "$CHECK_USER_QUERY"
if [ $? -eq 0 ]; then
    echo "User 'msois' already exists."
else
    echo "User 'msois' does not exist. Creating..."
    mysql -u"$DB_USER" -p"$DB_PASSWORD" -h"$DB_HOST" -e "$CREATE_USER_QUERY"
    mysql -u"$DB_USER" -p"$DB_PASSWORD" -h"$DB_HOST" -e "$GRANT_PRIVILEGES_QUERY"
    mysql -u"$DB_USER" -p"$DB_PASSWORD" -h"$DB_HOST" -e "$FLUSH_PRIVILEGES_QUERY"
    echo "User 'msois' created and granted privileges."
fi

DB_EXISTS=$(mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='$DB_NAME';" --skip-column-names)

if [ $DB_EXISTS -eq 0 ]; then
    # Create the database if it doesn't exist
    mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD -e "CREATE DATABASE $DB_NAME;"
    
    # Execute the SQL script
    mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD $DB_NAME < $SQL_SCRIPT
else
    echo "Database $DB_NAME already exists. Skipping creation and SQL script execution."
fi
