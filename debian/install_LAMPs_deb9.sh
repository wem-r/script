#!/bin/bash
# Script Automatisation installation
# Wemy - TSSR2020 - 23/07/2020
# https://wemy.ninja/script et https://github.com/wem-r/script

# Install Apache2
echo -e "\e[96m Installation Apache2 \e[0m"
apt -y install apache2
a2enmod ssl
a2enmod rewrite
a2enmod headers
a2dissite 000-default
systemctl restart apache2

#Install MySQL
echo -e "\e[96m installation MySQL \e[0m"
echo -e "deb http://repo.mysql.com/apt/debian/ stretch mysql-5.7\ndeb-src http://repo.mysql.com/apt/debian/ stretch mysql-5.7" > /etc/apt/sources.list.d/mysql.list
wget -O /tmp/RPM-GPG-KEY-mysql https://repo.mysql.com/RPM-GPG-KEY-mysql
apt-key add /tmp/RPM-GPG-KEY-mysql
apt update
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password root"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password root"
debconf-set-selections <<< "mysql-community-server mysql-server/default-auth-override select Use Legacy Authentication Method (Retain MySQL 5.x Compatibility)"
DEBIAN_FRONTEND=noninteractive apt -y install mysql-server
systemctl restart apache2


 #install de php7
 echo -e "\e[96m Installation php7 \e[0m"
apt -y install php
sed -i 's+upload_max_filesize = 2M+upload_max_filesize = 32M+g' /etc/php/7.0/apache2/php.ini
apt -y install php-curl php-gd php-mcrypt php-zip php-apcu php-xml php-ldap
systemctl restart apache2

#Install phpmyadmin
 echo -e "\e[96m installation phpmyadmin \e[0m"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
apt -y install phpmyadmin
sed -i 's+Alias /phpmyadmin+Alias /pma+g' /etc/phpmyadmin/apache.conf
systemctl restart apache2

 echo -e "\e[96m installation vsftpd \e[0m"
apt install vsftpd
cp /etc/vsftpd.conf /etc/vsftpd.bak
rm /etc/vsftpd.conf

#configuration du service avec chrootage et passv et ssl
touch /etc/vsftpd.conf


echo "listen=NO" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "listen_ipv6=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "local_enable=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "write_enable=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "local_umask=022" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "dirmessage_enable=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "use_localtime=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "xferlog_enable=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "connect_from_port_20=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "ftpd_banner=David Banner" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "chroot_local_user=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "secure_chroot_dir=/var/run/vsftpd/empty" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "pam_service_name=vsftpd" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "rsa_cert_file=/etc/letsencrypt/live/authpedago.wemy.ninja/fullchain.pem" >> /etc/vsftpd.conf
echo "rsa_private_key_file=/etc/letsencrypt/live/authpedago.wemy.ninja/privkey.pem" >> /etc/vsftpd.conf
echo "ssl_enable=YES" >> /etc/vsftpd.conf
echo "allow_anon_ssl=NO" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "force_local_data_ssl=YES" >> /etc/vsftpd.conf
echo "force_local_logins_ssl=YES" >> /etc/vsftpd.conf
echo "ssl_tlsv1=YES" >> /etc/vsftpd.conf
echo "ssl_sslv2=NO" >> /etc/vsftpd.conf
echo "ssl_sslv3=NO" >> /etc/vsftpd.conf
echo "require_ssl_reuse=NO" >> /etc/vsftpd.conf
echo "ssl_ciphers=HIGH" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf
echo "pasv_enable=yes" >> /etc/vsftpd.conf
echo "pasv_min_port=65000" >> /etc/vsftpd.conf
echo "pasv_max_port=65500" >> /etc/vsftpd.conf

