#!/bin/bash
# Script full install LAMPs + GLPI on Debian 10
# Wemy - 25/08/2022
# https://github.com/wem-r/script
clear 

if [ $EUID -ne 0 ]; then
  echo "\e[96m Le script doit être lancé en root: # sudo $0 \e[0m" 1>&2
  exit 1
fi

if [ "$(cut -d. -f1 /etc/debian_version)" == "11" ]; then
				echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m             Script compatible, Installation starting now             \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
else
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ===    Your Debian version is not compatible with this script    === \e[0m" 1>&2
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ==================================================================== \e[0m"
        exit 1
fi

#=================================================================================================================================
#=================================================================================================================================
#=================================================================================================================================

echo
echo
echo -e "\e[96m     /\_/\           ___   \e[0m"
echo -e "\e[96m    = o_o =_______    \ \  \e[0m"
echo -e "\e[96m     __^      __(  \.__) ) \e[0m"
echo -e "\e[96m (@)<_____>__(_____)____/  \e[0m"
echo
echo
echo
echo
echo -e "\e[96m ==> If you want to use stronger passwords, change the username and change the Database name: "
echo -e "\e[33m     hit ^C and edit this script (Lines 50, 52, 54 and 56) \e[0m"
echo
echo -e "\e[96m ==> Otherwise, \e[33mPress Enter to continue \e[0m"
echo -e "\e[96m ==> Login infos at the end \e[0m"
echo
read yeahgoahead

apt install -y net-tools dnsutils curl
IPAddress=$(ifconfig | grep broadcast | awk '{print $2}')
#MySQL Root Password
mysqlrootpwd=mysql_root_password
#GLPI Database Name
glpidbname=glpidb
#GLPI MySQL User
glpiuser=glpiuser
#GLPI MySQL User Password
glpiuserpassword=glpipwd


echo
echo -e "\e[96m	================================================================================ \e[0m"
echo -e "\e[96m                                             _          ___   \e[0m"
echo -e "\e[96m                      /\                    | |        |__ \  \e[0m"
echo -e "\e[96m                     /  \   _ __   __ _  ___| |__   ___   ) | \e[0m"
echo -e "\e[96m                    / /\ \ | '_ \ / _\` |/ __| '_ \ / _ \ / /  \e[0m"
echo -e "\e[96m                   / ____ \| |_) | (_| | (__| | | |  __// /_  \e[0m"
echo -e "\e[96m                  /_/    \_\ .__/ \__,_|\___|_| |_|\___|____| \e[0m"
echo -e "\e[96m                           | |                                \e[0m"
echo -e "\e[96m			   					     \e[0m"


# Apache2 Install 
echo -e "\e[96m Apache2 Installation \e[0m"
apt -y install apache2
systemctl enable apache2

echo -e "\e[96m Generating Self-Signed certificate \e[0m"
openssl req  -new -x509 -days 3560 -nodes -out /etc/ssl/glpi.pem -keyout /etc/ssl/glpi.pem -subj /C=FR/ST=CVL/L=Tours/O=AIS/OU=LAN/CN=localhost/emailAddress=admin@localhost
echo

echo -e "\e[96m Creating the vhost conf file \e[0m"
echo "<VirtualHost *:80>
    #ServerName wemy.ninja
    #ServerAlias www.domain.tld
    RewriteEngine on
    #RewriteCond %{HTTPS}!on
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}

</VirtualHost>

<VirtualHost *:443>

    #ServerName wemy.ninja
    #ServerAlias www.domain.tld

    DocumentRoot /var/www/html/glpi/

    <Directory /var/www/html/glpi/>
      Options -Indexes
      AllowOverride all
      Order allow,deny
      allow from all
    </Directory>

    SSLEngine on
    SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite HIGH:!aNULL:!MD5:!ADH:!RC4:!DH:!RSA
    SSLHonorCipherOrder on
    SSLCertificateFile /etc/ssl/glpi.pem
    SSLCertificateKeyFile /etc/ssl/glpi.pem

    LogLevel warn
    ErrorLog ${APACHE_LOG_DIR}/glpi.ninja-error.log
    CustomLog ${APACHE_LOG_DIR}/glpi.ninja-access.log combined

</VirtualHost>">>/etc/apache2/sites-available/glpi.conf

a2enmod ssl
a2enmod rewrite
a2enmod headers
a2dissite 000-default
a2ensite glpi.conf

sed -i "159,163 {s/^/#/}" /etc/apache2/apache2.conf
sed -i "170,174 {s/^/#/}" /etc/apache2/apache2.conf



echo -e "\e[96m	================================================================================ \e[0m"
echo
echo -e "\e[96m                       __  __        _____  ____  _       \e[0m"
echo -e "\e[96m                      |  \/  |      / ____|/ __ \| |      \e[0m"
echo -e "\e[96m                      | \  / |_   _| (___ | |  | | |      \e[0m"
echo -e "\e[96m                      | |\/| | | | |\___ \| |  | | |      \e[0m"
echo -e "\e[96m                      | |  | | |_| |____) | |__| | |____  \e[0m"
echo -e "\e[96m                      |_|  |_|\__, |_____/ \___\_\______| \e[0m"
echo -e "\e[96m                               __/ |                      \e[0m"
echo -e "\e[96m                              |___/                       \e[0m"
echo -e "\e[96m							         \e[0m"

# Install MySQL
echo -e "\e[96m MySQL installation \e[0m"
apt install mariadb-server -y
mysql_secure_installation<<EOF

y
mysqlrootpwd
mysqlrootpwd
y
y
y
y
EOF
systemctl enable mariadb
echo

echo "CREATE DATABASE $glpidbname;" >>glpidatabase.sql
echo "GRANT ALL PRIVILEGES ON $glpidbname.* TO '$glpiuser'@'localhost' IDENTIFIED BY '$glpiuserpassword';" >>glpidatabase.sql
echo "FLUSH PRIVILEGES;" >>glpidatabase.sql
mysql -u root -p$mysqlrootpwd <  glpidatabase.sql
rm glpidatabase.sql
echo

echo -e "\e[96m	================================================================================ \e[0m"
echo
echo -e "\e[96m                                     _            \e[0m"
echo -e "\e[96m                                    | |           \e[0m"
echo -e "\e[96m                               _ __ | |__  _ __   \e[0m"
echo -e "\e[96m                              | '_ \| '_ \| '_ \  \e[0m"
echo -e "\e[96m                              | |_) | | | | |_) | \e[0m"
echo -e "\e[96m                              | .__/|_| |_| .__/  \e[0m"
echo -e "\e[96m                              | |         | |     \e[0m"
echo -e "\e[96m                              |_|         |_|     \e[0m"
echo -e "\e[96m			                                 \e[0m"
			      
# install de php
echo -e "\e[96m php Installation \e[0m"
apt update
apt install -y php
apt install -y php-curl php-fileinfo php-gd php-mysql php-zip php-apcu php-xml php-ldap php-mbstring php-intl php-xmlrpc php-cas php-bz2

systemctl restart apache2
echo

echo -e "\e[96m	================================================================================ \e[0m"
echo

# Downloading GLPI
echo -e "\e[96m GLPI Installation \e[0m"
cd /var/www/html
wget https://github.com/glpi-project/glpi/releases/download/10.0.2/glpi-10.0.2.tgz
tar zxvf glpi-10.0.2.tgz
rm -f glpi-10.0.2.tgz
chown -R www-data:www-data glpi/

clear
echo
echo -e "\e[96m  __  __  _  _  ___   ___   _     \e[0m"
echo -e "\e[96m |  \/  || || |/ __| / _ \ | |    \e[0m"
echo -e "\e[96m | |\/| | \_. |\__ \| (_) || |__  \e[0m"
echo -e "\e[96m |_|  |_| |__/ |___/ \__\_\|____| \e[0m"
echo
echo
echo -e "\e[96m ==> MySQL Root Password : \e[31m$mysqlrootpwd \e[0m"
echo
echo -e "\e[96m ==> GLPI Database Name :\e[31m $glpidbname \e[0m"
echo -e "\e[96m ==> GLPI MySQL User :\e[31m $glpiuser \e[0m"
echo -e "\e[96m ==> GLPI MySQL User Password :\e[31m $glpiuserpassword \e[0m"
echo
echo -e "\e[96m ==> The Self-Signed Certificate is located here :\e[31m /etc/ssl/glpi.pem \e[0m"
echo
echo -e "\e[96m ==========================================================  \e[0m"
echo
echo
echo -e "\e[96m   ___  _     ___  ___  \e[0m"
echo -e "\e[96m  / __|| |   | _ \|_ _| \e[0m"
echo -e "\e[96m | (_ || |__ |  _/ | |  \e[0m"
echo -e "\e[96m  \___||____||_|  |___| \e[0m"
echo
echo
echo -e "\e[96m ==>  Your GLPI is now Up and Running  \e[0m"
echo
echo -e "\e[96m ==> +++++++++++++++++++++++++++++++++ \e[0m"
echo -e "\e[96m ==>     https://$IPAddress/           \e[0m"
echo -e "\e[96m ==> +++++++++++++++++++++++++++++++++ \e[0m"
echo
echo
echo
