#!/bin/bash
# Wemy - 24/08/2021
# https://github.com/wem-r/script
clear

if [ $EUID -ne 0 ]; then
  echo -e "\t \v \e[33m You must be logged as root to use this script: \e[44m sudo $0 \e[0m \v" 1>&2
  exit 1
fi

if [ "$(cut -d. -f1 /etc/redhat-release)" == "Red Hat Enterprise Linux release 8" ]; then
		echo -e "\t \v \e[96m ==================================================================== \e[0m"
		echo -e "\t \e[96m  ==================================================================== \e[0m"
		echo -e "\t \e[96m  ======            Script compatible, starting now...          ====== \e[0m"
		echo -e "\t \e[96m  ==================================================================== \e[0m"
		echo -e "\t \e[96m  ==================================================================== \e[0m \v"
else
		echo -e "\t \v \e[91m ==================================================================== \e[0m"
		echo -e "\t \e[91m  ==================================================================== \e[0m"
		echo -e "\t \e[91m  ===      Script not compatible with this version of RHEL       === \e[0m" 1>&2
		echo -e "\t \e[91m  ==================================================================== \e[0m"
		echo -e "\t \e[91m  ==================================================================== \e[0m \v"
		exit 1
fi


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))

echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  System Update \e[0m \v"
yum update -y


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  installing : net-tools | yum-utils | unzip | curl | wget | bash-completion | policycoreutils-python-utils | mlocate | bzip2 \e[0m \v"
dnf install -y yum-utils unzip curl wget bash-completion policycoreutils-python-utils mlocate bzip2 net-tools
dnf update -y

echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Generating self-signed certificate \e[0m \v"
openssl req -new -x509 -days 3560 -newkey rsa:4096 -nodes -out /etc/pki/tls/certs/lamps.crt -keyout /etc/pki/tls/private/lamps.key -subj /C=FR/ST=CVL/L=Tours/O=AIS/OU=LAN/CN=localhost/emailAddress=admin@localhost

echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Installing : Apache (httpd) \e[0m \v"
dnf install -y httpd
dnf install -y mod_ssl


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m Creating the Apache2 conf file \e[0m \v"

echo "<VirtualHost *:80>
   #ServerName www.exemple.com
   RewriteEngine On
   RewriteCond %{HTTPS} off
   RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
</VirtualHost>
<IfModule mod_ssl.c>
    <VirtualHost *:443>
    #ServerName www.exemple.com
    DocumentRoot /var/www/html/
    <directory /var/www/html/>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews
        SetEnv HOME /var/www/html/
        SetEnv HTTP_HOME /var/www/html/
        <IfModule mod_dav.c>
        Dav off
        </IfModule>
	<IfModule mod_headers.c>
        Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
        </IfModule>
    </directory>
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/lamps.crt
    SSLCertificateKeyFile /etc/pki/tls/private/lamps.key
   </VirtualHost>
</IfModule>" >>/etc/httpd/conf.d/lamps.conf

sed -i 's/#DocumentRoot \"\/var\/www\/html\"/DocumentRoot \"\/var\/www\/html\/nextcloud\/"/g' /etc/httpd/conf.d/ssl.conf

echo "<h1> Hello World!</h1>" >>/var/www/html/index.html

sudo systemctl enable httpd.service
sudo systemctl start httpd.service


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Installing : php \e[0m \v"
dnf module reset php
dnf module install -y php
dnf install -y php

echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Installing php modules : php | php-gd | php-mbstring | php-intl | php-pecl-apcu | php-mysqlnd | php-opcache | php-json | php-zip | php-redis | php-imagick \e[0m \v"
dnf install -y php php-gd php-mbstring php-intl php-pecl-apcu php-mysqlnd php-opcache php-json php-zip php-posix php-gmp php-bcmath


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Installing : MariaDB Server \e[0m \v"
dnf install -y mariadb mariadb-server
systemctl enable mariadb.service
systemctl start mariadb.service

mysql_secure_installation<<EOF

y
mysql_root_password
mysql_root_password
y
y
y
y
EOF


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Installing : Redis \e[0m \v"
dnf install -y redis
systemctl enable redis.service
systemctl start redis.service

echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Opening the firewall \e[0m \v"
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --reload

setsebool -P httpd_can_network_connect on

echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  changing PHP settings \e[0m"
echo -e "\t \v \e[96m  Max file siez : 1GB \e[0m \v"
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' /etc/php.ini
echo -e "\t \v \e[96m  Memory Limit : 512M \e[0m \v"
sed -i 's/memory_limit\ =\ 128M/memory_limit\ =\ 512M/g' /etc/php.ini

systemctl restart php-fpm.service

IPAddress=$(ifconfig | grep broadcast | awk '{print $2}')
echo -e "\e[96m Your IP Address is: $IPAddress "
echo -e "\t \v \e[96m  \e[0m"

echo
echo -e "\t \v \e[96m ===================================== \e[0m"
echo -e "\t \e[96m          Installation finished            \e[0m"
echo -e "\t \e[96m           https:://$IPAddress/       \e[0m"
echo -e "\t \e[96m  ===================================== \e[0m \v"
