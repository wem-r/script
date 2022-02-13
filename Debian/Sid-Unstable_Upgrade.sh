#!/bin/bash

if [ $EUID -ne 0 ]; then
  echo "\e[96m You must be logged as root to use this script: # sudo $0 \e[0m" 1>&2
  exit 1
fi

apt update -y ;  apt full-upgrade -y ; apt dist-upgrade -y
apt autoremove ; apt autoclean

mv /etc/apt/sources.list /etc/apt/sources.list.bak

echo "
deb http://ftp.fr.debian.org/debian/ sid main contrib non-free
deb-src http://ftp.fr.debian.org/debian/ sid main contrib non-free

deb http://ftp.fr.debian.org/debian/ unstable main contrib non-free
deb-src http://ftp.fr.debian.org/debian/ unstable main contrib non-free" >> /etc/apt/sources.list


apt update -y ;  apt full-upgrade -y ; apt dist-upgrade -y
apt autoremove ; apt autoclean
