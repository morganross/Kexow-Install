#!/bin/bash
##Run these commands to download this script
##sudo wget goo.gl/8ET70z -O kexow-install.sh
##sudo sh kexow-install.sh

#in the future combine this script with main menu, but accesible by wget, which means it must be stand alone no source



#do you want to install cliant or server?

#install git
sudo apt-get -y update
sudo apt-get -y install git-core
#git config --global user.name "NewUser"
#git config --global user.email newuser@example.com



#download Kexow-setup-scripts (installer)
git clone git://github.com/morganross/Kexow-Server-Setup-Scripts.git
git clone git://github.com/morganross/Kexow-website.git
#git clone git://github.com/morganross/userfrosting.git
#git clone git://github.com/morganross/pydio.git

#where u want to download security file from?
echo -n "Type in your secret key for the shared google drive folder where creds.tar is located?"
read text
sudo wget 'googledrive.com/host/'$text'/creds.tar' -O creds.tar
sudo tar -C Kexow-Server-Setup-Scripts -xvf creds.tar

#What is the new root pass?
sudo touch pass.txt
sudo chmod 777 pass.txt
echo -n "enter in the new password"
read pass
echo $pass>pass.txt

sudo sed -i "s/PASSWORD85/${pass}/g" /home/ubuntu/Kexow-Server-Setup-Scripts/aws_bind_ip.sh

cd Kexow-Server-Setup-Scripts
sudo bash ./main_menu.sh

##with script change pass in dbsettings and changestatus and aws bind




