#!/bin/bash

aws_install () {

}

copy_aws_ec2_files () {



}

aws_setup () {
	copy_aws_ec2_files

}

aws_get_all_ip () {



}

aws_check_newip () {
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

}

bind9_install () {
}

changeIP() {
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
}

restart_bind () {
}


check_log_file () {
			aws_check_newip
}


export_aws_ec2_env () {
}

run_ldap_func () {
ldap_base='dc=us-west-2,dc=compute,dc=internal'
ldap_users_base="ou=users,${ldap_base}"
ldap_group_base="ou=groups,${ldap_base}"

sudo apt-get update && sudo apt-get -y install phpldapadmin slapd ldap-utils libnss-ldap libpam-ldap nslcd
sudo sed -i "s/dc=example,dc=com/${ldap_base}/g" /etc/phpldapadmin/config.php

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
}

run_lamp_func () {
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
}