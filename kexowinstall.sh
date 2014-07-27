#!/bin/bash


#where u want to download security file from?
sudo wget http://$vARIABLE creds.tar
extract creds.tar /installer

#What is the new root pass?
sudo mk pass.txt
sudo echo $variable>pass.txt

#install git
sudo apt-get install git-core
git config --global user.name "NewUser"
git config --global user.email newuser@example.com



#download Kexow-setup-scripts 
git clone git://github.com/morganross/Kexow-Server-Setup-Scripts.git







run main menu

##include lamp.sh into main menu
##include server script in main menu

enter in password, then use it to change pass in dbsettings and changestatus



this is a test of notepadd++ but not really

put lamp.sh and ldap.sh into the main menu.
put serer_script into main meu
put download website into meain menu


while true; do
    read -p "Do you wish to install this program?" yn
    case $yn in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -n "Enter some text > "
read text
echo "You entered: $text"
       


