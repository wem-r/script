#!/bin/bash
# script qui install un vhost complet (site1) en mode mutualisé local
# v1.1 par T.CHERRIER - 23/07/2020

domain="deb9CEF80.lan"

# creation du USER et de ses droits et répertoire
echo -e "\e[96m USER creation \e[0m"
useradd $1 --password $2 -m
mkdir /home/$1/www
touch /home/$1/www/index.html
chown -R www-data:www-data /home/$1/www
usermod -a -G www-data $1
chmod -R 775 /home/$1/www

# creation du certificat du genre site1.bobdy.lan
# le certificat et la clé sont dans 2 fichiers séparés dans /home/site/
#openssl req  -new -x509 -days 3560 -nodes -out /home/$1/apache.pem -keyout /home/$1/apache.pem
echo -e "\e[96m SSL certificate \e[0m"
openssl req  -new -x509 -days 3560 -nodes -out /home/$1/apache.pem -keyout /home/$1/apache.pem -subj /C=FR/ST=CVL/L=Tours/O=TSSR/OU=LAN/CN=localhost/emailAddress=admin@localhost
# creation du vhost apache du genre /etc/apache2/sites-available/site1.conf
# la conf 80 et 443 est dans le même fichier. le doc root est /home/site1/www
echo -e "\e[96m VHOST \e[0m"

echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/$1.conf
echo "ServerName $1.$domain" >> /etc/apache2/sites-available/$1.conf
echo "RewriteEngine on" >> /etc/apache2/sites-available/$1.conf
echo "RewriteCond %{HTTPS} !on" >> /etc/apache2/sites-available/$1.conf
echo "RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}" >> /etc/apache2/sites-available/$1.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/$1.conf
echo "<VirtualHost *:443>" >> /etc/apache2/sites-available/$1.conf
echo "ServerName $1.$domain" >> /etc/apache2/sites-available/$1.conf
echo "DocumentRoot /home/$1/www" >> /etc/apache2/sites-available/$1.conf
echo "    <Directory /home/$1/www/>" >> /etc/apache2/sites-available/$1.conf
echo "        Options -Indexes" >> /etc/apache2/sites-available/$1.conf
echo "        AllowOverride all" >> /etc/apache2/sites-available/$1.conf
echo "        Order allow,deny" >> /etc/apache2/sites-available/$1.conf
echo "        allow from all" >> /etc/apache2/sites-available/$1.conf
echo "    </Directory>" >> /etc/apache2/sites-available/$1.conf
echo "    SSLEngine on" >> /etc/apache2/sites-available/$1.conf
echo "    SSLCertificateFile /home/$1/apache.pem " >> /etc/apache2/sites-available/$1.conf
echo "</Virtualhost>" >> /etc/apache2/sites-available/$1.conf

a2ensite $1
systemctl restart apache2

# creation de la base site1 pour le user site1  dans mysql
#avec les privileges globaux uniquement sur cette base
echo -e "\e[96m MySQL \e[0m"

echo "CREATE USER '$1'@'%' IDENTIFIED BY '$2';" >>$1.sql
echo "GRANT USAGE ON *.* TO '$1'@'%' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;" >>$1.sql
echo "CREATE DATABASE IF NOT EXISTS $1;" >>$1.sql
echo "GRANT ALL PRIVILEGES ON $1.* TO '$1'@'%';" >>$1.sql
mysql -u root -pdadfba16 <  $1.sql
# rm $1.sql

#creation d'une page vierge html dans /home/site1/www/index.html 
#avec welcome sur site1
echo -e "\e[96m index/html \e[0m"
echo "<h1>welcome chez $1</h1>" >> /home/$1/www/index.html
systemctl restart apache2

sed -i "159s/<Directory \/\>/# <Directory \/\>/" /etc/apache2/apache2.conf
sed -i "160s/        Options FollowSymLinks/#        Options FollowSymLinks/" /etc/apache2/apache2.conf
sed -i "161s/        AllowOverride None/#        AllowOverride None/" /etc/apache2/apache2.conf
sed -i "162s/Require all denied/# Require all denied/" /etc/apache2/apache2.conf
sed -i "159s/<\/\Directory>/# <\/\Directory>/" /etc/apache2/apache2.conf

sed -i "170s/<Directory \/\var\/\www\/\>/# <Directory \/\var\/\www\/\>/" /etc/apache2/apache2.conf
sed -i "171s/        Options Indexes FollowSymLinks/#        Options Indexes FollowSymLinks/" /etc/apache2/apache2.conf
sed -i "172s/        AllowOverride None/#        AllowOverride None/" /etc/apache2/apache2.conf
sed -i "173s/        Require all granted/#        Require all granted/" /etc/apache2/apache2.conf
sed -i "174s/<\/\Directory>/# <\/\Directory>/" /etc/apache2/apache2.conf
systemctl restart apache2
