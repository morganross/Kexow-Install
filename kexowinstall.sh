#!/bin/bash

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
echo -n "Where you wanna download the security files from?"
read text
sudo wget 'https://docs.google.com/uc?export=download&confirm=no_antivirus&id='$text -O creds.tar
sudo tar -C Kexow-Server-Setup-Scripts -xvf creds.tar

#What is the new root pass?
sudo touch pass.txt
sudo chmod 777 pass.txt
echo -n "enter in the new password"
read pass
echo $pass>pass.txt




#sudo mv files to the right /directores


#sudo sed pass in dbsettings with pass.txt


cd Kexow-Server-Server-Scripts
sudo ./main_menu.sh


##include server script in main menu
##with script change pass in dbsettings and changestatus and aws bind




