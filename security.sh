#!/bin/bash

# Ubuntu Security Script
# Brian Strauch

function pause() {
  read -p "Press [Enter] to continue..."
}

if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script."
  exit 1
fi

# Firewall
sudo ufw enable

# Updates
sudo apt-get -y dist-upgrade
sudo apt-get -y update

# Lock Out Root User
sudo passwd -l root

# Configure Password Aging Controls
sudo sed -i '/^PASS_MAX_DAYS/ c\PASS_MAX_DAYS   30' /etc/login.defs
sudo sed -i '/^PASS_MIN_DAYS/ c\PASS_MIN_DAYS   7'  /etc/login.defs
sudo sed -i '/^PASS_WARN_AGE/ c\PASS_WARN_AGE   14' /etc/login.defs

# Password Authentication
sudo sed -i '1 s/^/auth optional pam_tally.so deny=5 unlock_time=900 onerr=fail audit even_deny_root_account silent\n/' /etc/pam.d/common-auth

# Force Strong Passwords
sudo apt-get -y install libpam-cracklib
sudo sed -i '1 s/^/password requisite pam_cracklib.so retry=3 minlen=8 difok=3 reject_username minclass=3 maxrepeat=2 dcredit=1 ucredit=1 lcredit=1 ocredit=1\n/' /etc/pam.d/common-password

# -----[ Apache ]---------------------------------------
echo -n "Apache [Y/n] "
read option

if [[ $option =~ ^[Yy]$ ]]; then
	sudo apt-get -y install apache2
else
	sudo apt-get -y purge apache2*
fi

# -----[ Bind9 ]---------------------------------------
echo -n "Bind9 [Y/n] "
read option

if [[ $option =~ ^[Yy]$ ]]; then
	sudo apt-get -y install bind9
else
	sudo apt-get -y purge bind9 # Intentionally omits '*'
fi

# -----[ MongoDB ]--------------------------------------
echo -n "MongoDB [Y/n] "
read option

if [[ $option =~ ^[Yy]$ ]]; then
	sudo apt-get -y install mongodb
else
	sudo apt-get -y purge mongodb*
fi

# -----[ MySQL ]----------------------------------------
echo -n "MySQL [Y/n] "
read option

if [[ $option =~ ^[Yy]$ ]]; then
	sudo apt-get -y install mysql-server
	# Disable remote access
	sudo sed -i '/bind-address/ c\bind-address = 127.0.0.1' /etc/mysql/my.cnf
	sudo service mysql restart
else
	sudo apt-get -y purge mysql*
fi

# -----[ NGINX ]---------------------------------------
echo -n "NGINX [Y/n] "
read option

if [[ $option =~ ^[Yy]$ ]]; then
	sudo apt-get -y install nginx
else
	sudo apt-get -y purge nginx*
fi

# ------[ OpenSSH Server ]------------------------------
echo -n "OpenSSH-Server [Y/n] "
read option

if [[ $option =~ ^[Yy]$ ]]; then
	sudo apt-get -y install openssh-server
	# Disable root login
	sudo sed -i '/^PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config
	sudo service ssh restart
else
	sudo apt-get -y purge openssh-server*
fi

# -----[ Samba ]---------------------------------------
echo -n "Samba [Y/n] "
read option

if [[ $option =~ ^[Yy]$ ]]; then
	sudo apt-get -y install samba
else
	sudo apt-get -y purge samba*
fi

# -----[ TightVNCServer ]---------------------------------------
echo -n "TightVNCServer [Y/n] "
read option

if [[ $option =~ ^[Yy]$ ]]; then
	sudo apt-get -y install tightvncserver
else
	sudo apt-get -y purge tightvncserver*
fi

# -----[ VSFTP ]----------------------------------------
echo -n "VSFTP [Y/n] "
read option

if [[ $option =~ ^[Yy]$ ]]; then
	sudo apt-get -y install vsftpd
	# Disable anonymous uploads
	sudo sed -i '/^anon_upload_enable/ c\anon_upload_enable no' /etc/vsftpd.conf
	sudo service vsftpd restart
else
	sudo apt-get -y purge vsftpd*
fi

# Malware
sudo apt-get -y purge hydra john nikto
pause

# Media Files
for suffix in mp3 txt wav wma aac mp4 mov avi gif jpg png bmp img exe msi bat sh; do
	sudo find /home -name *.$suffix
done
