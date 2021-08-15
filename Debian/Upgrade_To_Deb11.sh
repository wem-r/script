#!/bin/bash

if [ $EUID -ne 0 ]; then
  echo "\e[96m You need to be logged as root to use this script: # sudo $0 \e[0m" 1>&2
  exit 1
fi

sed -i 's/buster\/update/bullseye-security/g' /etc/apt/sources.list
sed -i 's/buster/bullseye/g' /etc/apt/sources.list

apt update -y ;  apt full-upgrade -y ; apt dist-upgrade -y
apt autoremove ; apt autoclean
