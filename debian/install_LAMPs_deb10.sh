#!/bin/bash
# Script LAMPs Install deb10
# Wemy - TSSR2020 - 23/07/2020
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
echo -e "\e[96m ==> Your User name ? \e[0m"
read username

# Install Apache2
echo -e "\e[96m Installation Apache2 \e[0m"
apt -y install apache2
systemctl enable apache2

echo -e "\e[96m SSL certificate \e[0m"
openssl req  -new -x509 -days 3560 -nodes -out /home/$username/apache.pem -keyout /home/$username/apache.pem -subj /C=FR/ST=CVL/L=Tours/O=TSSR/OU=LAN/CN=localhost/emailAddress=admin@localhost
echo

mkdir /home/$username/www
chown -R www-data:www-data /home/$username/www
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

    DocumentRoot /home/$username/www

    <Directory /home/$username/www/>
      Options -Indexes
      AllowOverride all
      Order allow,deny
      allow from all
    </Directory>

    SSLEngine on
    SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite HIGH:!aNULL:!MD5:!ADH:!RC4:!DH:!RSA
    SSLHonorCipherOrder on
    SSLCertificateFile /home/$username/apache.pem
    SSLCertificateKeyFile /home/$username/apache.pem

    LogLevel warn
    ErrorLog ${APACHE_LOG_DIR}/wemy.ninja-error.log
    CustomLog ${APACHE_LOG_DIR}/wemy.ninja-access.log combined

</VirtualHost>">>/etc/apache2/sites-available/website.conf

a2enmod ssl
a2enmod rewrite
a2enmod headers
a2dissite 000-default

echo "<h1> TEST </h1>">>/home/$username/www/index.html

a2ensite website.conf

sed -i "/$159/ s/^/# /" /etc/apache2/apache2.conf
sed -i "/$160/ s/^/# /" /etc/apache2/apache2.conf
sed -i "/$161/ s/^/# /" /etc/apache2/apache2.conf
sed -i "/$162/ s/^/# /" /etc/apache2/apache2.conf
sed -i "/$163/ s/^/# /" /etc/apache2/apache2.conf

sed -i "/$170/ s/^/# /" /etc/apache2/apache2.conf
sed -i "/$171/ s/^/# /" /etc/apache2/apache2.conf
sed -i "/$172/ s/^/# /" /etc/apache2/apache2.conf
sed -i "/$173/ s/^/# /" /etc/apache2/apache2.conf
sed -i "/$174/ s/^/# /" /etc/apache2/apache2.conf

systemctl restart apache2

echo 
# Install MySQL
echo -e "\e[96m installation MySQL \e[0m"
apt install mariadb-server -y
mysql_secure_installation<<EOF

y
mysql_root_password
mysql_root_password
y
y
y
y
EOF
systemctl enable mariadb
echo

# install de php
echo -e "\e[96m Installation php \e[0m"
apt update
apt install -y php
apt install -y php-curl php-gd php-mysql php-zip php-apcu php-xml php-ldap php-mbstring 
systemctl restart apache2
echo
