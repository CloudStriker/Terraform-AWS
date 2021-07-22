#!/bin/bash
sudo apt install apache2 -y
sudo apt install php php-mysql -y
sudo apt install mariadb-server -y
sudo apt install -y php-curl php-gd php-mbstring php-xml php-xmlrpc
sudo service apache2 restart
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sleep 20
sudo mkdir -p /var/www/html/
sudo rsync -av wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo rm /var/www/html/index.html
sudo service apache2 restart
sleep 20