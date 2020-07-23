#!/bin/bash
# Script Post Install Debian 9
# Remy RATRON - TSsR2020 - 23/07/2020
# https://wemy.ninja/script et https://github.com/wem-r/script
clear

# modification du bashrc
echo -e "\e[96m Modification du .bashrc \e[0m"
cp /root/.bashrc /root/.bashrc.bak
sed -i "7s/# / /" /root/.bashrc
sed -i "8s/# / /" /root/.bashrc
sed -i "9s/# / /" /root/.bashrc
sed -i "10s/# / /" /root/.bashrc
sed -i "11s/# / /" /root/.bashrc
sed -i "14s/# / /" /root/.bashrc

# apt update & upgrade
 echo -e "\e[96m apt update & upgrade \e[0m"
apt-get update -y
apt-get upgrade -y

# installation utilitaires usuels du système
echo -e "\e[96m Install sudo\e[0m"
apt --yes --force-yes install sudo
echo -e "\e[96m Install nmap\e[0m"
apt --yes --force-yes install nmap
echo -e "\e[96m Install zip\e[0m"
apt --yes --force-yes install zip
echo -e "\e[96m Install dnsutils\e[0m"
apt --yes --force-yes install dnsutils
echo -e "\e[96m Install net-tools\e[0m"
apt --yes --force-yes install net-tools
echo -e "\e[96m Install  tzdata\e[0m"
apt --yes --force-yes install tzdata
echo -e "\e[96m Install lynx\e[0m"
apt --yes --force-yes install lynx
echo -e "\e[96m Install curl \e[0m"
apt --yes --force-yes install curl
echo -e "\e[96m Install git \e[0m"
apt --yes --force-yes install git
echo -e "\e[96m Install screen \e[0m"
apt --yes --for ce-yes install screen
echo -e "\e[96mInstall locate \e[0m"
apt --yes --force-yes install locate
echo -e "\e[96m Install ncdu \e[0m"
apt --yes --force-yes install ncdu
echo -e "\e[96m Install ssh \e[0m"
apt --yes --force-yes install ssh

#Configuration fuseau horaire
echo -e "\e[96m Configuration tzdata \e[0m"
echo "tzdata tzdata/Areas select Europe" | debconf-set-selections
echo "tzdata tzdata/Zones/Europe select Paris" | debconf-set-selections
TIMEZONE="Europe/Paris"
echo $TIMEZONE > /etc/timezone

#Configuration Hostname
echo -e "\e[96m Confiduration hostname \e[0m"
cd /
rm /etc/hostname
echo "deb9CEF80" >>/etc/hostname

#Configuration resolv.conf
echo -e "\e[96m Confiduration resolv.conf \e[0m"
cd /
rm /etc/resolv.conf
echo "nameserver 1.1.1.1" >>/etc/resolv.conf

#Configuration carte reseau
echo -e "\e[96m Confiduration fichier interfaces \e[0m"
cd /
rm /etc/network/interfaces
echo "source /etc/network/interfaces.d/*" >>/etc/network/interfaces
echo "" >>/etc/network/interfaces
echo "# The loopback network interfaces" >>/etc/network/interfaces
echo "auto lo" >>/etc/network/interfaces
echo "iface lo inet loopback" >>/etc/network/interfaces
echo "" >>/etc/network/interfaces
echo "# The primary network interface" >>/etc/network/interfaces
echo "allow-hotplug ens33" >>/etc/network/interfaces
echo "iface ens33 inet static" >>/etc/network/interfaces
echo "  address 192.168.1.106" >>/etc/network/interfaces
echo "  netmask 255.255.255.0" >>/etc/network/interfaces
echo "  gateway 192.168.1.254" >>/etc/network/interfaces

reboot
