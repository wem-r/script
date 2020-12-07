#!/bin/bash
# Script Post Install Debian 10
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

echo
echo -e "\e[96m ==> Available Interface \e[0m"
echo
ip link show
echo
echo -e "\e[96m ==> Choose an interface (exemple: ens33) : \e[0m"
read interface
echo
echo -e "\e[96m ==> IP Address (ex: 192.168.20.110) : \e[0m"
read ipaddress
echo -e "\e[96m ==> Netmask (ex: 255.255.255.0) : \e[0m"
read netmask
echo -e "\e[96m ==> Gateway (ex: 192.168.20.254): \e[0m"
read gateway
echo
echo -e "\e[96m ==> DNS Server (ex: 1.1.1.1): \e[0m"
read dns
echo

# modification du bashrc
echo -e "\e[96m Modification du .bashrc \e[0m"
cp /root/.bashrc /root/.bashrc.bak
sed -i "s/# export/ export/" /root/.bashrc
sed -i "s/# eval/ eval/" /root/.bashrc
sed -i "s/# alias ls/ alias ls/" /root/.bashrc
sed -i "s/# alias ll/ alias ll/" /root/.bashrc
sed -i "s/# alias l/ alias l/" /root/.bashrc
sed -i "s/# alias rm/ alias rm/" /root/.bashrc
echo

# apt update & upgrade
echo -e "\e[96m apt update \e[0m"
apt-get update -y
echo
echo -e "\e[96m apt upgrade \e[0m"
apt-get upgrade -y
echo

# installation utilitaires usuels du système
echo -e "\e[96m Install sudo\e[0m"
apt --yes --force-yes install sudo
echo
echo -e "\e[96m Install nmap\e[0m"
apt --yes --force-yes install nmap
echo
echo -e "\e[96m Install zip\e[0m"
apt --yes --force-yes install zip
echo
echo -e "\e[96m Install dnsutils\e[0m"
apt --yes --force-yes install dnsutils
echo
echo -e "\e[96m Install net-tools\e[0m"
apt --yes --force-yes install net-tools
echo
echo -e "\e[96m Install lynx\e[0m"
apt --yes --force-yes install lynx
echo
echo -e "\e[96m Install curl \e[0m"
apt --yes --force-yes install curl
echo
echo -e "\e[96m Install git \e[0m"
apt --yes --force-yes install git
echo
echo -e "\e[96m Install screen \e[0m"
apt --yes --for ce-yes install screen
echo
echo -e "\e[96mInstall locate \e[0m"
apt --yes --force-yes install locate
echo
echo -e "\e[96m Install ncdu \e[0m"
apt --yes --force-yes install ncdu
echo
echo -e "\e[96m Install ssh \e[0m"
apt --yes --force-yes install ssh
echo

#Install Webmin
echo -e "\e[96m Installation de webmin \e[0m"
cd /
wget https://prdownloads.sourceforge.net/webadmin/webmin_1.953_all.deb
apt -y -f install ./webmin_1.953_all.deb
rm -f webmin_1.953_all.deb
echo

#Configuration fuseau horaire
echo -e "\e[96m Configuration tzdata \e[0m"
echo "tzdata tzdata/Areas select Europe" | debconf-set-selections
echo "tzdata tzdata/Zones/Europe select Paris" | debconf-set-selections
TIMEZONE="Europe/Paris"
echo $TIMEZONE > /etc/timezone
echo

#Configuration Hostname
echo -e "\e[96m Confiduration hostname \e[0m"
cd /
rm /etc/hostname
echo "deb10CEF80" >>/etc/hostname
echo

#Configuration resolv.conf
echo -e "\e[96m Confiduration resolv.conf \e[0m"
cd /
rm /etc/resolv.conf
echo "nameserver $dns" >>/etc/resolv.conf
echo

#Configuration carte reseau
echo -e "\e[96m Confiduration fichier interfaces \e[0m"
cd /
rm /etc/network/interfaces
echo "# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interfaces
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug $interface
iface $interface inet static
  address $ipaddress
  netmask $netmask
  gateway $gateway" >>/etc/network/interfaces

reboot
