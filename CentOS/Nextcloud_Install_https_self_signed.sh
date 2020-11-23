#!/bin/bash
# Script Full Install Nextcloud 20 on CentOS 8
# Wemy - TSSR2020 - 10/11/2020
# https://wemy.ninja/script or https://github.com/wem-r/script
clear

if [ $EUID -ne 0 ]; then
  echo -e "\t \v \e[33m Le script doit être lancé en root: \e[44m sudo $0 \e[0m \v" 1>&2
  exit 1
fi

if [ "$(cut -d. -f1 /etc/redhat-release)" == "CentOS Linux release 8" ]; then
		echo -e "\t \v \e[96m ==================================================================== \e[0m"
		echo -e "\t \e[96m  ==================================================================== \e[0m"
		echo -e "\t \e[96m  ======            Script compatible, Installation             ====== \e[0m"
		echo -e "\t \e[96m  ==================================================================== \e[0m"
		echo -e "\t \e[96m  ==================================================================== \e[0m \v"
else
		echo -e "\t \v \e[91m ==================================================================== \e[0m"
		echo -e "\t \e[91m  ==================================================================== \e[0m"
		echo -e "\t \e[91m  ===      Script not compatible with this version of CentOS       === \e[0m" 1>&2
		echo -e "\t \e[91m  ==================================================================== \e[0m"
		echo -e "\t \e[91m  ==================================================================== \e[0m \v"
		exit 1
fi


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Nextcloud 20 install on CentOS \e[0m"
echo -e "\t \e[96m  Starting Now \e[0m \v"
echo -e "\t \e[96m   _  _ _____  _______ ___ _    ___  _   _ ___   \e[0m"
echo -e "\t \e[96m  | \| | __\ \/ /_   _/ __| |  / _ \| | | |   \  \e[0m"
echo -e "\t \e[96m  | .  | _| >  <  | || (__| |_| (_) | |_| | |) | \e[0m"
echo -e "\t \e[96m  |_|\_|___/_/\_\ |_| \___|____\___/ \___/|___/  \e[0m"
echo -e "\t \e[96m                                                 \e[0m \v"



echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  System Update \e[0m \v"
yum update -y


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  installing : epel-release | yum-utils | unzip | curl | wget | bash-completion | policycoreutils-python-utils | mlocate | bzip2 \e[0m \v"
dnf install -y epel-release yum-utils unzip curl wget bash-completion policycoreutils-python-utils mlocate bzip2
dnf update -y

echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Generating self-signed certificate \e[0m \v"
openssl req -new -x509 -days 3560 -newkey rsa:4096 -nodes -out /etc/pki/tls/certs/nextcloud.crt -keyout /etc/pki/tls/private/nextcloud.key -subj /C=FR/ST=CVL/L=Tours/O=TSSR/OU=LAN/CN=localhost/emailAddress=admin@localhost

echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Installing : Apache (httpd) \e[0m \v"
dnf install -y httpd
dnf install -y mod_ssl


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m Creating the Apache2 nextcloud conf file \e[0m \v"

echo "<VirtualHost *:80>
   #ServerName www.exemple.com
   RewriteEngine On
   RewriteCond %{HTTPS} off
   RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
</VirtualHost>

<IfModule mod_ssl.c>
    <VirtualHost *:443>
    #ServerName www.exemple.com
    DocumentRoot /var/www/html/nextcloud
    <directory /var/www/html/nextcloud>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews
        SetEnv HOME /var/www/html/nextcloud
        SetEnv HTTP_HOME /var/www/html/nextcloud
        <IfModule mod_dav.c>
        Dav off
        </IfModule>
    </directory>
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/nextcloud.crt
    SSLCertificateKeyFile /etc/pki/tls/private/nextcloud.key
   </VirtualHost>
</IfModule>" >>/etc/httpd/conf.d/nextcloud.conf

sed -i 's/#DocumentRoot \"\/var\/www\/html\"/DocumentRoot \"\/var\/www\/html\/nextcloud\/"/g' /etc/httpd/conf.d/ssl.conf


sudo systemctl enable httpd.service
sudo systemctl start httpd.service


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Installing : yum-util \e[0m \v"
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf install -y yum-utils


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Installing : php7.4 \e[0m \v"
dnf module reset php
dnf module install -y php:remi-7.4
dnf update -y


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Installing php modules : php | php-gd | php-mbstring | php-intl | php-pecl-apcu | php-mysqlnd | php-opcache | php-json | php-zip | php-redis | php-imagick \e[0m \v"
dnf install -y php php-gd php-mbstring php-intl php-pecl-apcu php-mysqlnd php-opcache php-json php-zip
dnf install -y php-redis php-imagick


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
echo -e "\t \v \e[96m  Creating the database \e[0m \v "
echo "CREATE USER 'user'@'localhost' IDENTIFIED BY 'user_password';" >>nc.sql
echo "CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" >>nc.sql
echo "GRANT ALL PRIVILEGES on nextcloud.* to 'user'@'localhost';" >>nc.sql
echo "FLUSH privileges;" >>nc.sql
mysql -u root -pmysql_root_password <  nc.sql
rm -f nc.sql



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
echo -e "\t \v \e[96m  Downloading Nextcloud \e[0m \v"
cd /tmp
wget https://download.nextcloud.com/server/releases/nextcloud-20.0.1.tar.bz2
wget https://download.nextcloud.com/server/releases/nextcloud-20.0.1.tar.bz2.md5
wget https://download.nextcloud.com/server/releases/nextcloud-20.0.1.tar.bz2.asc
wget https://nextcloud.com/nextcloud.asc
gpg --import nextcloud.asc
gpg --verify nextcloud-20.0.1.tar.bz2.asc nextcloud-20.0.1.tar.bz2
md5sum -c nextcloud-20.0.1.tar.bz2.md5 < nextcloud-20.0.1.tar.bz2
echo -e "\t \v \e[96m Extracting the Archive \e[0m \v"
tar -xvjf nextcloud-20.0.1.tar.bz2
echo -e "\t \v \e[96m Moving it /var/www/html/nextcloud \e[0m \v"
cp -R nextcloud/ /var/www/html/


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Making of the data directory \e[0m \v"
mkdir /var/www/html/nextcloud/data
echo -e "\t \v \e[96m  Changing the owner of /var/www/html/nextcloud to apache  \e[0m \v"
chown -R apache:apache /var/www/html/nextcloud
systemctl restart httpd.service

echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  Opening the firewall \e[0m \v"
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --reload


echo -e "\e[96m "
printf '=%.0s' $(seq 1 $(tput cols))
echo -e "\e[om "
echo -e "\t \v \e[96m  SELinux \e[0m \v"
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/data(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/config(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/apps(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/.htaccess'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/.user.ini'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/3rdparty/aws/aws-sdk-php/src/data/logs(/.*)?'

restorecon -R '/var/www/html/nextcloud/'

setsebool -P httpd_can_network_connect on

sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' /etc/php.ini
sed -i 's/memory_limit\ =\ 128M/memory_limit\ =\ 512M/g' /etc/php.ini
systemctl restart php-fpm.service

echo -e "\e[96m Your IP Address is: "
ip --brief a| awk '{ print $3}' | cut -d/ -f1
echo -e "\t \v \e[96m  \e[0m"

echo
echo -e "\t \v \e[96m ===================================== \e[0m"
echo -e "\t \e[96m          Installation finished            \e[0m"
echo -e "\t \e[96m           https:://IP_ADDRESS/       \e[0m"
echo -e "\t \e[96m  ===================================== \e[0m \v"
