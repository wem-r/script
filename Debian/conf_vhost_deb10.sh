#!/bin/bash
# script qui install un vhost complet (site1) en mode mutualisé local
# Wemy -TSSR2020 - 23/07/2020
# https://wemy.ninja/script et https://github.com/wem-r/script
clear

if [ $EUID -ne 0 ]; then
  echo "\e[96m Le script doit être lancé en root: # sudo $0 \e[0m" 1>&2
  exit 1
fi

if [ "$(cut -d. -f1 /etc/debian_version)" == "10" ]; then
				echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m             Version compatible, début de l'installation              \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
else
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ===      Script non compatible avec votre version de Debian      === \e[0m" 1>&2
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ==================================================================== \e[0m"
        exit 1
fi

#=================================================================================================================================
#=================================================================================================================================
#=================================================================================================================================

echo
echo
echo -e "\e[96m ==> User name : \e[0m"
read username
echo -e "\e[96m ==> password : \e[0m"
read password
echo

domain="deb9CEF80.lan"

# creation du USER et de ses droits et répertoire
echo -e "\e[96m USER creation \e[0m"
useradd $username --password $password -m
mkdir /home/$username/www
touch /home/$username/www/index.html
chown -R www-data:www-data /home/$username/www
usermod -a -G www-data $username
chmod -R 775 /home/$username/www
echo

# creation du certificat du genre site1.bobdy.lan
# le certificat et la clé sont dans 2 fichiers séparés dans /home/site/
#openssl req  -new -x509 -days 3560 -nodes -out /home/$username/apache.pem -keyout /home/$username/apache.pem
echo -e "\e[96m SSL certificate \e[0m"
openssl req  -new -x509 -days 3560 -nodes -out /home/$username/apache.pem -keyout /home/$username/apache.pem -subj /C=FR/ST=CVL/L=Tours/O=TSSR/OU=LAN/CN=localhost/emailAddress=admin@localhost
echo

# creation du vhost apache du genre /etc/apache2/sites-available/site1.conf
# la conf 80 et 443 est dans le même fichier. le doc root est /home/site1/www
echo -e "\e[96m VHOST \e[0m"

echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/$username.conf
echo "  ServerName $username.$domain" >> /etc/apache2/sites-available/$username.conf
echo "  RewriteEngine on" >> /etc/apache2/sites-available/$username.conf
echo "  RewriteCond %{HTTPS} !on" >> /etc/apache2/sites-available/$username.conf
echo "  RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}" >> /etc/apache2/sites-available/$username.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/$username.conf
echo "<VirtualHost *:443>" >> /etc/apache2/sites-available/$username.conf
echo "ServerName $username.$domain" >> /etc/apache2/sites-available/$username.conf
echo "DocumentRoot /home/$username/www" >> /etc/apache2/sites-available/$username.conf
echo "    <Directory /home/$username/www/>" >> /etc/apache2/sites-available/$username.conf
echo "        Options -Indexes" >> /etc/apache2/sites-available/$username.conf
echo "        AllowOverride all" >> /etc/apache2/sites-available/$username.conf
echo "        Order allow,deny" >> /etc/apache2/sites-available/$username.conf
echo "        allow from all" >> /etc/apache2/sites-available/$username.conf
echo "    </Directory>" >> /etc/apache2/sites-available/$username.conf
echo "    SSLEngine on" >> /etc/apache2/sites-available/$username.conf
echo "    SSLCertificateFile /home/$username/apache.pem " >> /etc/apache2/sites-available/$username.conf
echo "</Virtualhost>" >> /etc/apache2/sites-available/$username.conf

a2ensite $username
systemctl restart apache2
echo

# creation de la base site1 pour le user site1  dans mysql
#avec les privileges globaux uniquement sur cette base
echo -e "\e[96m MySQL \e[0m"

echo "CREATE USER '$username'@'%' IDENTIFIED BY '$password';" >>$username.sql
echo "GRANT USAGE ON *.* TO '$username'@'%' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;" >>$username.sql
echo "CREATE DATABASE IF NOT EXISTS $username;" >>$username.sql
echo "GRANT ALL PRIVILEGES ON $username.* TO '$username'@'%';" >>$username.sql
mysql -u root -pdadfba16 <  $username.sql
# rm $username.sql
echo

#creation d'une page vierge html dans /home/site1/www/index.html 
#avec welcome sur site1
echo -e "\e[96m creation of index.html \e[0m"
echo "<h1>welcome chez $username</h1>" >> /home/$username/www/index.html
systemctl restart apache2
echo

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
