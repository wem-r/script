#!/bin/bash
# Script Full Install Nextcloud 20 on CentOS 8
# Wemy - TSSR2020 - 10/11/2020
# https://wemy.ninja/script or https://github.com/wem-r/script
clear

if [ $EUID -ne 0 ]; then
  echo "\e[96m Le script doit être lancé en root: # sudo $0 \e[0m" 1>&2
  exit 1
fi

if [ "$(cut -d. -f1 /etc/redhat-release)" == "CentOS Linux release 8" ]; then
				echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m ======      Version compatible, début de l'installation       ====== \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
else
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ===      Script non compatible avec votre version de CentOS      === \e[0m" 1>&2
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ==================================================================== \e[0m"
        exit 1
fi

echo
echo
echo -e "\e[96m Nextcloud 20 install on CentOS \e[0m"
echo -e "\e[96m Starting Now \e[0m"

echo
echo -e "\e[96m System Update \e[0m"
sudo yum update

echo
echo -e "\e[96m installing : epel-release | yum-utils | unzip | curl | wget | bash-completion | policycoreutils-python-utils | mlocate | bzip2 \e[0m"
sudo dnf install -y epel-release yum-utils unzip curl wget bash-completion policycoreutils-python-utils mlocate bzip2
sudo dnf update -y

echo 
echo -e "\e[96m Installing : Apache (httpd) \e[0m"
sudo dnf install -y httpd

echo -e "\e[96m Creating the Apache2 nextcloud conf file \e[0m"

echo "<VirtualHost *:80>" >>/etc/httpd/conf.d/nextcloud.conf
echo "  DocumentRoot /var/www/html/nextcloud/" >>/etc/httpd/conf.d/nextcloud.conf
echo "  ServerName  transfert2.cd37.fr" >>/etc/httpd/conf.d/nextcloud.conf
echo "" >>/etc/httpd/conf.d/nextcloud.conf
echo "  <Directory /var/www/html/nextcloud/>" >>/etc/httpd/conf.d/nextcloud.conf
echo "    Require all granted" >>/etc/httpd/conf.d/nextcloud.conf
echo "    AllowOverride All" >>/etc/httpd/conf.d/nextcloud.conf
echo "    Options FollowSymLinks MultiViews" >>/etc/httpd/conf.d/nextcloud.conf
echo "" >>/etc/httpd/conf.d/nextcloud.conf
echo "    <IfModule mod_dav.c>" >>/etc/httpd/conf.d/nextcloud.conf
echo "      Dav off" >>/etc/httpd/conf.d/nextcloud.conf
echo "    </IfModule>" >>/etc/httpd/conf.d/nextcloud.conf
echo "" >>/etc/httpd/conf.d/nextcloud.conf
echo "  </Directory>" >>/etc/httpd/conf.d/nextcloud.conf
echo "</VirtualHost>" >>/etc/httpd/conf.d/nextcloud.conf


sudo systemctl enable httpd.service
sudo systemctl start httpd.service

echo 
echo -e "\e[96m Installing : yum-util \e[0m"
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf install -y yum-utils

echo
echo -e "\e[96m Installing : php7.4 \e[0m"
dnf module reset php
dnf module install -y php:remi-7.4
dnf update -y

echo
echo -e "\e[96m Installing php modules : php | php-gd | php-mbstring | php-intl | php-pecl-apcu | php-mysqlnd | php-opcache | php-json | php-zip | php-redis | php-imagick \e[0m"
dnf install -y php php-gd php-mbstring php-intl php-pecl-apcu php-mysqlnd php-opcache php-json php-zip
dnf install -y php-redis php-imagick

echo
echo -e "\e[96m Installing : MariaDB Server \e[0m"
dnf install -y mariadb mariadb-server
systemctl enable mariadb.service
systemctl start mariadb.service

mysql_secure_installation<<EOF

y
nc
nc
y
y
y
y
EOF

echo
echo -e "\e[96m Creating the database \e[0m"
echo "CREATE USER 'nc'@'localhost' IDENTIFIED BY 'nc';" >>nc.sql
echo "CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" >>nc.sql
echo "GRANT ALL PRIVILEGES on nextcloud.* to 'nc'@'localhost';" >>nc.sql
echo "FLUSH privileges;" >>nc.sql
mysql -u root -pnc <  nc.sql
rm -f nc.sql


echo
echo -e "\e[96m Installing : Redis \e[0m"
dnf install -y redis
systemctl enable redis.service
systemctl start redis.service

echo
echo -e "\e[96m Downloading the Nextcloud archive \e[0m"
cd /tmp
wget https://download.nextcloud.com/server/releases/nextcloud-20.0.1.tar.bz2
wget https://download.nextcloud.com/server/releases/nextcloud-20.0.1.tar.bz2.md5
wget https://download.nextcloud.com/server/releases/nextcloud-20.0.1.tar.bz2.asc
wget https://nextcloud.com/nextcloud.asc
gpg --import nextcloud.asc
gpg --verify nextcloud-20.0.1.tar.bz2.asc nextcloud-20.0.1.tar.bz2
md5sum -c nextcloud-20.0.1.tar.bz2.md5 < nextcloud-20.0.1.tar.bz2
echo -e "\e[96m Extracting the Archive \e[0m"
tar -xvjf nextcloud-20.0.1.tar.bz2
echo -e "\e[96m Moving it /var/www/html/nextcloud \e[0m"
cp -R nextcloud/ /var/www/html/

echo
echo -e "\e[96m Making of the data directory \e[0m"
mkdir /var/www/html/nextcloud/data
echo -e "\e[96m Change of owner \e[0m"
chown -R apache:apache /var/www/html/nextcloud
systemctl restart httpd.service

echo -e "\e[96m Opening the firewall \e[0m"
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload

echo
echo -e "\e[96m SELinux \e[0m"
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/data(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/config(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/apps(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/.htaccess'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/.user.ini'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/nextcloud/3rdparty/aws/aws-sdk-php/src/data/logs(/.*)?'

restorecon -R '/var/www/html/nextcloud/'

setsebool -P httpd_can_network_connect on

echo
echo -e "\e[96m ======================================== \e[0m"
echo -e "\e[96m   You can now access to nextcloud on :   \e[0m"
echo -e "\e[96m       https:://transfert2.cg37.fr/       \e[0m"
echo -e "\e[96m        ou https:://131.1.100.90/         \e[0m"
echo -e "\e[96m ======================================== \e[0m"
