@echo off
color 02
mode con cols=80 lines=20
echo =====================================
echo Choose:
echo 1 Configurer l'ip en 192.168.20.110
echo 2 Configurer l'ip en DHCP
echo ======================================
:choice
SET /P C=ip fixe ou DHCP ?
if [%C%]==[1] goto A
if [%C%]==[2] goto B
goto choice
:A
@echo off
echo Configuration de l'adresse ip en: 192.168.20.210
netsh interface ip set address "Wi-Fi" static 192.168.20.210 255.255.255.0 192.168.20.254
netsh interface ip add dns "Wi-Fi" addr="192.168.20.254"
::rem netsh interface ip add dns "Wi-Fi" addr="192.168.20.254"
netsh interface ip show config "Wi-Fi"
pause
goto end
:B
@echo off
echo Configuration de l'adresse ip en DHCP
netsh interface ip set address "Wi-Fi" source=dhcp
netsh interface ip set dnsservers "Wi-Fi" source=dhcp
netsh interface ip show config "Wi-Fi"
pause
goto end
:end