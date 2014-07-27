#!/bin/bash

##the client script is a simple wget and execute, in the future we can include an option in this script to do nothing but run that wget and execute, even though it wounldnt save any steps
##it would make one less link to remember.

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

cd /installer
sudo ./main_menu.sh



##include lamp.sh into main menu
##include server script in main menu
##with script change pass in dbsettings and changestatus
#put download website into main menu









echo -n "Enter some text > "
read text
echo "You entered: $text"



source aws_bind_ip.sh
while true;do
	echo "*******************************************************************"
	echo "1. Install ec2-api-tools"
	echo "9. Run the LDAP script"
	echo "Press any other to Exit"
	echo "*******************************************************************"
	echo -n "Enter your choice :"
	read choice
case "$choice" in
"1")
	aws_install
	sleep 2
   ;;
"9")
    run_ldap_func
    sleep 2
    ;;

*)
    echo "exit from menu"
    break
    ;;
esac
done
       


