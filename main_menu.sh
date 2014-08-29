#!/bin/bash

ZFILE="/etc/bind/zones/kexow.com.zone"
IP_LIST="/etc/bind/list.txt"
LOG="/var/log/named/queries.log"

while true;do
	echo "*******************************************************************"
	echo "git. get git"
	echo "creds. download creds.tar"
	echo "1. Install ec2-api-tools"
	echo "2. Install bind9 package"
	echo "3. Restart bind9 server"
	echo "4. Copy keypair files export environment variable to current shell"
	echo "5. Monitor the Log file [will not return menu press ctrl+c to exit]"
	echo "6. Copy the necessary file for aws-ec2 tools"
	echo "7. Add aws-ec2 variables your login shell [$HOME/.bashrc]"
	echo "8. Populate list.txt with all existing spot instance"
	echo "9. Run the LDAP script"
	echo "a. Run the Lamp script"
	echo "b. Run the server script"
	echo "c. Move website files"
	echo "d. Git Pydio and install"
	echo "e. Update server_script with new keyfile and ami"
	echo "f. run client script"
	echo "Press any other to Exit"
	echo "*******************************************************************"
	echo -n "Enter your choice :"
	read choice
case "$choice" in
"1")
#Install API Tools
sudo perl -pi.orig -e   'next if /-backports/; s/^# (deb .* multiverse)$/$1/'   /etc/apt/sources.list
sudo apt-add-repository ppa:awstools-dev/awstools
sudo apt-get -y update
sudo apt-get install -y ec2-api-tools
if [ $? -ne 0 ];then
	echo "Fail to install the ec2-api-tools"
else
	echo "Successfully installed ec2-api-tools"
fi
	sleep 2
   ;;
"2")
#Install BIND9 Package AND make some files
	sudo apt-get -y install bind9
if [ $? -ne 0 ]; then
	echo "Failed to install bind9"
	return 1
fi    
sudo chmod a+w /etc/bind/zones
cat > /etc/bind/named.conf.local << EOF
zone "kexow.com" {
        type master;
        file "/etc/bind/zones/kexow.com.zone";
        };

zone "102.254.54.in-addr.arpa" {
     type master;
     file "/etc/bind/zones/rev.102.254.54.in-addr.arpa";

};

EOF

cat > /etc/bind/named.conf.log << EOF
logging {
        channel update_debug {
                file "/var/log/named/update_debug.log" versions 3 size 100k;
                severity debug;
                print-severity  yes;
                print-time      yes;
        };
        channel security_info {
                file "/var/log/named/security_info.log" versions 1 size 100k;
                severity info;
                print-severity  yes;
                print-time      yes;
        };
        channel bind_log {
                file "/var/log/named/bind.log" versions 3 size 1m;
                severity info;
                print-category  yes;
                print-severity  yes;
                print-time      yes;
        };

        channel query_log {
                file "/var/log/named/queries.log";
                severity debug 3;
        };


        category default { bind_log; };
        category lame-servers { null; };
        category update { update_debug; };
        category update-security { update_debug; };
        category security { security_info; };
        category queries { query_log; };
};

EOF

cat > /etc/bind/zones/rev.102.254.54.in-addr.arpa << EOF
@ IN SOA ns1.kexow.com. admin.kexow.com. (
                        2006071801; serial
                        28800; refresh, seconds
                        604800; retry, seconds
                        604800; expire, seconds
                        86400 ); minimum, seconds

                     IN  NS ns1.kexow.com.

50                  IN      PTR    kexow.com

EOF

cat > /etc/bind/zones/kexow.com.zone << EOF
kexow.com. IN      SOA     ns1.kexow.com. admin.kexow.com. (
          2006071801
          10    
          600      
          10 
          10)  
kexow.com. IN      NS      ns1.kexow.com.
kexow.com. IN      NS      ns2.kexow.com.
kexow.com. IN      MX     10 mta.kexow.com.

kexow.com. IN A 54.245.102.50
www           IN      A       54.245.102.50
mta             IN      A      54.245.102.50
ns1              IN      A       54.245.102.50
ns2              IN      A       54.245.102.50
*	IN	A		54.245.102.50
connect IN A 54.184.26.63
EOF
	
sudo touch /etc/bind/list.txt
sudo chmod 777 /etc/bind/list.txt
if [ ! -e /var/log/named ]; then
	sudo mkdir /var/log/named
fi
sudo touch /var/log/named/bind.log /var/log/named/queries.log /var/log/named/security_info.log /var/log/named/update_debug.log
sudo chmod 777 /var/log/named/queries.log
sudo chmod 777 /var/log/named/bind.log
sudo chmod 777 /var/log/named/security_info.log
sudo chmod 777 /var/log/named/update_debug.log

#Enable log file configuration in named.conf
if ! grep -q named.conf.log /etc/bind/named.conf; then
	sudo echo 'include "/etc/bind/named.conf.log";' >> /etc/bind/named.conf
	echo -e "\n include named.conf.log in named.conf..."
else
	echo -e "\n named.conf.log already in named.conf"
fi
       	echo -e "Successfully installed bind9"
    sleep 2
    ;;

"3")
    	sudo /etc/init.d/bind9 restart > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Failed to restart the bind9 server"
		return 1
	else
		echo "Successfully restarted bind9 server"
		return 0
	fi
    sleep 2
    ;;

"4")
    export EC2_URL=https://ec2.us-west-2.amazonaws.com
	export EC2_PRIVATE_KEY=$(echo $HOME/pk.pem)
	export EC2_CERT=$(echo $HOME/cert.pem)
	export AWS_CREDENTIAL_FILE=$HOME/creds.txt
    sleep 2
    ;;

"5")
    if [ -e $LOG ]; then
      #sudo mv $LOG $LOG.$$
      #sudo touch $LOG
      sudo chmod 777 $LOG
tail -F $LOG |while read LINE;do
	if [[ "${LINE}" =~ 'connect' ]]; then
		echo '______  _  _  _____  ______  _____  _   _  _____  _____ ______ 
|  _  \| \ | |/  ___| | ___ \|_   _|| \ | ||  __ \|  ___||  _  \
| | | ||  \| |\ `--.  | |_/ /  | |  |  \| || |  \/| |__  | | | |
| | | || . ` | `--. \ |  __/   | |  | . ` || | __ |  __| | | | |
| |/ / | |\  |/\__/ / | |     _| |_ | |\  || |_\ \| |___ | |/ / 
|___/  \_| \_/\____/  \_|     \___/ \_| \_/ \____/\____/ |___/  

'
		if [ -e $ZFILE ] || [ -e $IP_LIST ];then
	echo "Delete the last line of the $ZFILE"
        sudo sed -i -e "$ d"  $ZFILE
        NEW_IP=$(head -n 1 $IP_LIST)
        sudo echo "connect IN A $NEW_IP" >>$ZFILE
	echo "new zone written with $NEW_IP Delete the First line of the $IP_LIST"
        sudo sed -i -e "1 d" $IP_LIST
else
	echo "Fail to find the $ZFILE or $IP_LIST"
	return 1
fi
	return 0
		echo "called for changeIP"
		ret_code1=$?
		restart_bind
		ret_code2=$?
		if [ $ret_code1 -ne 0 ] || [ $ret_code2 -ne 0 ];then
			echo "Fail to restart bind server or change IP was not happen. Press Control-c to exit"
		else
			echo "we changed ip and it worked with no errors, now we call for aws_check_newip"
			request_id=$1
echo " $LCOUNT aws check new ip has started, script will request new instace if under 4 entries in list"
aws_setup
LCOUNT=$(wc -l $IP_LIST | awk '{print $1}')
#count the IP address if it is zero then populate all the instance IPs to list.txt
if [ "$LCOUNT" -eq 0 ]; then
		echo "list.txt $LCOUNTis null populate existing instance IP"
              IFS=$'\n'
                for IP in $ip_address
                do
        		echo "Got IP from ec2 and IP address $IP END"
        		echo $IP >> $IP_LIST
		done
#If the count is less then 4 and greater than one then create spot instance and wait till the state changed to active
#Once it is active then get IP address and add to list.txt
elif [ "$LCOUNT" -le 4 ] && [ "$LCOUNT" -ge 1 ];then
	echo "list has between 1 and 4 entries, Creating instance $LCOUNT "
	sir=$(ec2-request-spot-instances ami-aa39599a -p 0.006 -k ssdkingstong -t t1.micro | grep -o -P '.{0,0}sir-.{0,8}')
	echo "$LCOUNT Instance info $sir"
	sleep 5
	while true;do
		state=$(ec2-describe-spot-instance-requests $sir | awk '{print $6}')
		echo "State is $state"
        	if [ "$state"  = "active" ];then
                	break
		else
			echo "waiting for spot to become instace, going sleep 13 seconds"
			sleep 13
        	fi
	done
	instance_id=$(ec2-describe-spot-instance-requests $sir | awk '{print $8}')
        ip_address=`ec2-describe-instances $instance_id | awk '/INSTANCE/{print $14}'`
        echo "Got IP from ec2 and IP address $ip_address"
        echo $ip_address >> $IP_LIST
fi
		fi
  	fi
done
fi
    sleep 2
    ;;
"6")
    if [ ! -e $HOME/pk.pem ]; then
	cp -f pk.pem $HOME
	echo "copied pk.pem file to $HOME"    
fi
if [ ! -e $HOME/creds.txt ];then
	cp -f creds.txt $HOME
	echo "copied creds.txt file to $HOME"
fi

if [ ! -e $HOME/cert.pem ];then
	cp -f cert.pem $HOME
	echo "copied cert.pem file to $HOME"
fi
    sleep 2
    ;;
"7")
echo 'export EC2_URL=https://ec2.us-west-2.amazonaws.com' >>$HOME/.bashrc
echo 'export EC2_PRIVATE_KEY=$(echo $HOME/pk.pem)' >>$HOME/.bashrc
echo 'export EC2_CERT=$(echo $HOME/cert.pem)'  >>$HOME/.bashrc
echo 'export AWS_CREDENTIAL_FILE=$HOME/creds.txt' >>$HOME/.bashrc
source $HOME/.bashrc
echo "Successfully set EC2 environment variables"
    sleep 2
    ;;
"8")
    echo "Script trying to get all IP from ec2-spot-instance"
>$IP_LIST
echo "list.txt is null populate existing instance IP"
ip_address=$(ec2-describe-instances  | awk '/INSTANCE/{print $14}')
IFS=$'\n'
for IP in $ip_address
do
	echo "Got IP from ec2 and IP address $IP END"
       	echo $IP >> $IP_LIST
done
    sleep 2
    ;;
"9")


#ldap_base='dc=us-west-2,dc=compute,dc=internal'
#wget -qO- http://ipecho.net/plain ; echo

sudo apt-get -y update

sudo apt-get -y install phpldapadmin
sudo sed -i "s/dc=example,dc=com/dc=us-west-2,dc=compute,dc=internal/g" /etc/phpldapadmin/config.php
#install debconf utils
sudo echo 'slapd slapd/password1 password yourpass' | sudo debconf-set-selections -v
sudo echo 'slapd slapd/password2 password yourpass' | sudo debconf-set-selections -v
sudo echo 'slapd slapd/root_password password yourpass' | sudo debconf-set-selections -v
sudo echo 'slapd slapd/root_password_again password yourpass' | sudo debconf-set-selections -v

#sudo echo 'slapd slapd/internal/adminpw	password yourpass' | sudo debconf-set-selections -v
#sudo echo 'slapd slapd/internal/generated_adminpw password	yourpass' | sudo debconf-set-selections -v

sudo apt-get -y install slapd
sudo apt-get -y install ldap-utils


#PRESEED libness
sudo echo 'libnss-ldap     libnss-ldap/rootbindpw  password yourpass' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     libnss-ldap/bindpw      password yourpass' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     libnss-ldap/dblogin     boolean false' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     libnss-ldap/override    boolean false' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     shared/ldapns/base-dn   string   dc=us-west-2,dc=compute,dc=internal' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     libnss-ldap/rootbinddn  string   cn=admin,dc=us-west-2,dc=compute,dc=internal' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     shared/ldapns/ldap_version      select   3' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     libnss-ldap/binddn      string   cn=proxyuser,dc=us-west-2,dc=compute,dc=internal' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     shared/ldapns/ldap-server       string   ldapi://54.245.102.50/' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     libnss-ldap/nsswitch    note' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     libnss-ldap/confperm    boolean false' | sudo debconf-set-selections -v
sudo echo 'libnss-ldap     libnss-ldap/dbrootlogin boolean true' | sudo debconf-set-selections -v
#change change2 change3 change 4 change 5 last time i enter666666666665555																
fffff6666666666666666778888jackel	KDFHDFHD

											
											morganross@rossmorr.com
sudo apt-get -y install libnss-ldap
sudo apt-get -y install libpam-ldap
sudo apt-get -y install nslcd

#sudo sed -i "s/dc=example,dc=com/${ldap_base}/g" /etc/phpldapadmin/config.php




sudo apt-get -y  install nfs-kernel-server
echo " /home   *(rw,sync,no_subtree_check) " >> /etc/exports
sudo exportfs -a

sudo echo "dn: ou=Groups,dc=us-west-2,dc=compute,dc=internal
objectclass: organizationalUnit
objectclass: top
ou: Groups

dn: cn=admins,ou=Groups,dc=us-west-2,dc=compute,dc=internal
cn: admins
gidnumber: 500
objectclass: posixGroup
objectclass: top

dn: ou=Users,dc=us-west-2,dc=compute,dc=internal
objectclass: organizationalUnit
objectclass: top
ou: Users" > /tmp/new.ldif

sudo ldapadd -x -D "cn=admin,dc=us-west-2,dc=compute,dc=internal" -w PASSWORD85 -f /tmp/new.ldif
    sleep 2
    ;;
"a")
#Install LAMP
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo passwd ubuntu
sudo service ssh restart
sudo apt-get update
sudo apt-get -y install apache2
sudo apt-get -y install mysql-server libapache2-mod-auth-mysql php5-mysql 
sudo /usr/bin/mysql_secure_installation
sudo apt-get -y install php5 libapache2-mod-php5 php5-mcrypt
sudo service apache2 restart
sudo apt-get -y install phpmyadmin
sudo sed -i '$ a\
Include /etc/phpmyadmin/apache.conf' /etc/apache2/apache2.conf
sudo service apache2 restart
sudo chmod 400 /home/ubuntu/Kexow-Server-Setup-Scripts/clients.pem
sudo chmod 755 /home/ubuntu/Kexow-Server-Setup-Scripts/server_script.sh
#move to bind install
sudo chmod 777 /var/log/named/queries.log
sudo chmod 777 /etc/bind/list.txt
sudo chmod 777 /etc/ssh/ssh_config
sudo /etc/init.d/apache2 restart
sudo echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
append sudoers file
    sleep 2
    ;;
"b")
    ##Configuration parameters
AMINAME=ami-aa39599a
CHECKPERIOD=60 #in seconds
File=/etc/bind/list.txt
##Command Aliases
EC2DESC=ec2-describe-instances

##Do not edit
RAWFILE=/tmp/rawlist.txt

while true
do
#$EC2DESC | grep $AMINAME > $RAWFILE
ec2-describe-instances |grep ami-aa39599a | grep running | grep ssdkingstong > $RAWFILE

let i=0
declare -a ServerIPS
while read line; do
    #echo $line # or whaterver you want to do with the $line variablea
    IP=`echo $line | cut -d ' ' -f 14`
    ServerIPS[$i]=$IP
  i=$(( i + 1 ))
    #echo $i
done < $RAWFILE

#echo ${ServerIPS[@]}

### SSH to each server and see if there is any user logged in
let t=0
declare -a AddIPS
for i in "${ServerIPS[@]}"
do
  #echo "connceting to $i"
  output=`ssh -i /home/ubuntu/installer/clients.pem  ubuntu@$i 'sudo x2golistsessions_root'`
  #echo "output is $output"
  #if output contains GNOME then someone is logged in, else noone is in.
  if [[ $output == *GNOME* ]]
        then
                #echo "$i server has someone logged in!";
                let m=5
        else
                echo "$i has noone logged in. Adding it to list!";
                AddIPS[$t]=$i
                # Now simply check if these IPs are already in list.txt if not add them
                if grep -q ${AddIPS[$t]} "$File"; then
                        #echo "IP already exists!"
                        let m=6
                else
                        echo ${AddIPS[$t]} >> $File
						echo '
          __    _____    ______                 _      _            _ 
     _   /  |  |_   _|   | ___ \               | |    | |          | |
   _| |_ `| |    | |     | |_/ /      __ _   __| |  __| |  ___   __| |
  |_   _| | |    | |     |  __/      / _` | / _` | / _` | / _ \ / _` |
    |_|  _| |_  _| |_  _ | |      _ | (_| || (_| || (_| ||  __/| (_| |
         \___/  \___/ (_)\_|     (_) \__,_| \__,_| \__,_| \___| \__,_|
                                                                      
                                                                      '
 fi
                t=$(( t + 1 ))
        fi
done
#echo ${AddIPS[@]}

sleep  $CHECKPERIOD
done

    sleep 2
    ;;
"c")
sudo mv /home/ubuntu/Kexow-website/* /var/www/
sudo chmod 777 -R /var/www/xtra/
sudo chmod 777 -R /var/www/pyro/
sudo chmod 4777 /var/www/adscript.sh
sudo chmod 4777 /var/www/xtra/changestaus.sh
    sleep 2
    ;;		
"d")
    echo your mom $text
	#git pydio and change it up
    sleep 2
    ;;
"git")
    sudo apt-get -y install git-core
git clone git://github.com/morganross/Kexow-Server-Setup-Scripts.git
git clone git://github.com/morganross/Kexow-website.git
    sleep 2
    ;;	
"e")
    #change ami and keyfile in server_script. 
    sleep 2
    ;;	
"creds")
echo -n "Type in your secret key for the shared google drive folder where creds.tar is located?"
read text
sudo wget 'googledrive.com/host/'$text'/creds.tar' -O creds.tar
sudo tar -xvf creds.tar
    sleep 2
    ;;	
"f")
    #here is the client setup script 
	ldap_server='ldap://54.245.102.50'
ldap_base='dc=us-west-2,dc=compute,dc=internal'
ldap_users_base="ou=users,${ldap_base}"
ldap_group_base="ou=groups,${ldap_base}"

sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo passwd ubuntu
 
##mising ssh restart
sudo apt-get update && sudo apt-get -y install ldap-utils libnss-ldapd libpam-ldap nslcd

# Generate ldap.conf
cat <<EOF | sudo tee /etc/ldap/ldap.conf
uri  ${ldap_server}
base ${ldap_base}

ldap_version   3
timelimit      30
bind_timelimit 30
idle_timelimit 3600
bind_policy    soft
deref          never

nss_base_passwd ${ldap_users_base}?sub
nss_base_shadow ${ldap_users_base}?sub
nss_base_group  ${ldap_groups_base}?one

pam_login_attribute  uid
pam_password         md5
pam_member_attribute member
pam_filter           objectClass=posixAccount

#ssl start_tls
#ssl on
#TLS_CACERTFILE /etc/ssl/certs/ldap.pem
EOF

sudo ln -fs /etc/ldap/ldap.conf /etc/ldap.conf

cat <<EOF | sudo tee /etc/nslcd.conf
uid nslcd
gid nslcd

uri  ${ldap_server}
base ${ldap_users_base}
base ${ldap_group_base}
ldap_version   3
EOF

# PAM files
cat <<EOF | sudo tee /etc/pam.d/common-account
account [success=2 new_authtok_reqd=done default=ignore]  pam_unix.so
account [success=1 default=ignore]                        pam_ldap.so
account requisite                                         pam_deny.so
account required                                          pam_permit.so
EOF

cat <<EOF | sudo tee /etc/pam.d/common-auth
auth  [success=2 default=ignore]  pam_unix.so  nullok_secure
auth  [success=1 default=ignore]  pam_ldap.so  use_first_pass
auth  requisite                   pam_deny.so
auth  required                    pam_permit.so
EOF

cat <<EOF | sudo tee /etc/pam.d/common-password
password  [success=2 default=ignore]                  pam_unix.so obscure sha512
password  [success=1 user_unknown=ignore default=die] pam_ldap.so use_authtok try_first_pass
password  requisite                                   pam_deny.so
password  required                                    pam_permit.so
EOF

cat <<EOF | sudo tee /etc/pam.d/common-session
session [default=1]   pam_permit.so
session requisite     pam_deny.so
session required      pam_permit.so
session required      pam_unix.so
session optional      pam_ldap.so
session required      pam_mkhomedir.so skel=/etc/skel umask=0022
EOF

[ -z "`grep ldap /etc/nsswitch`" ] && sudo sed -i 's/compat/compat ldap/g' /etc/nsswitch.conf
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

sudo service nscd  stop
sudo service nslcd restart
sudo service ssh   restart

sudo apt-get -y install autofs
echo " /home    /etc/auto.home " >> /etc/auto.master
touch /etc/auto.home
echo " *    54.245.102.50:/home/& " >> /etc/auto.home
sudo service autofs restart
sudo apt-get -y install ubuntu-desktop
sudo apt-get -y install gnome-core gnome-session-fallback
sudo apt-get -y install python-software-properties
sudo add-apt-repository ppa:x2go/stable
sudo apt-get update
sudo apt-get -y install x2goserver
sudo apt-get -y install xautolock
sudo chmod +s /sbin/shutdown
sudo touch /etc/xdg/autostart/xautolock.desktop
sudo chmod 777 /etc/xdg/autostart/xautolock.desktop
sudo echo "[Desktop Entry]
Type=Application
Exec=/opt/xautolock.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=XAUTOLOCK
Name=XAUTOLOCK
Comment[en_US]=xautolock emre
Comment=xautolock emre" > /etc/xdg/autostart/xautolock.desktop
sudo echo "#!/bin/sh
shutdown -h now
exit 0" > /etc/gdm/PostSession/Default
sudo touch /opt/xautolock.sh
sudo chmod 755 /opt/xautolock.sh
sudo echo '#!/bin/bash
xautolock -time 3 -locker "/sbin/shutdown -h now" &' > /opt/xautolock.sh
sudo chmod 755 /opt/xautolock.sh
    sleep 2
	;;
*)
    echo "exit from menu"
    break
    ;;
esac
done
