#!/bin/bash
# Script Post Install Debian 10
# Wemy - 20/08/2021
# https://github.com/wem-r/script
clear

if [ $EUID -ne 0 ]; then
  echo "\e[96m Le script doit être lancé en root: # sudo $0 \e[0m" 1>&2
  exit 1
fi

if [ "$(cut -d. -f1 /etc/debian_version)" == "11" ]; then
				echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m             Debian version compatible, script starting now...        \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
                                echo -e "\e[96m ==================================================================== \e[0m"
else
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ==================================================================== \e[0m"
        echo -e "\e[91m ===                This script is for Debian 11                  === \e[0m" 1>&2
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

# Customizing bashrc
echo -e "\e[96m Modification du .bashrc \e[0m"
cp /root/.bashrc /root/.bashrc.bak
sed -i "s/# export/ export/" /root/.bashrc
sed -i "s/# eval/ eval/" /root/.bashrc
sed -i "s/# alias ls/ alias ls/" /root/.bashrc
sed -i "s/# alias ll/ alias ll/" /root/.bashrc
sed -i "s/# alias l/ alias l/" /root/.bashrc
sed -i "s/# alias rm/ alias rm/" /root/.bashrc
. /root/.bashrc
echo

# apt update & upgrade
echo -e "\e[96m apt update \e[0m"
apt update -y ;  apt full-upgrade -y ; apt dist-upgrade -y
echo

# installation utilitaires usuels du système
echo -e "\e[96m Install nmap zip dnsutils net-tools lynx curl git screen locate ncdu apt-transport-https ca-certificates gcc lsb-release neofetch tcpdump tzdata unzip vim ccze \e[0m"
apt install -y sudo nmap zip dnsutils net-tools lynx curl git screen locate ncdu apt-transport-https ca-certificates gcc lsb-release neofetch tcpdump tzdata unzip vim ccze
echo

#TimeZone Configuration
echo -e "\e[96m Configuration tzdata \e[0m"
echo "tzdata tzdata/Areas select Europe" | debconf-set-selections
echo "tzdata tzdata/Zones/Europe select Paris" | debconf-set-selections
TIMEZONE="Europe/Paris"
echo $TIMEZONE > /etc/timezone
echo


#Configuration resolv.conf
echo -e "\e[96m Confiduration resolv.conf \e[0m"
echo "nameserver $dns" >/etc/resolv.conf
echo

#Configuration NIC
echo -e "\e[96m NIC Configuration \e[0m"
mv /etc/network/interfaces /etc/network/interfaces.bak
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
  gateway $gateway" >/etc/network/interfaces

reboot
