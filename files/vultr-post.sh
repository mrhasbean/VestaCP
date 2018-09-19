#!/bin/bash

cd /root/vestacp

hostname=`hostname -f`
myip=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
hostip=`dig @8.8.8.8 +short $hostname`

if [ "$myip" == "$hostip" ]; then
	
	# Adds HTTPS certificate from LetsEncrypt to VestaCP control panel at the host name site on the admin user
	
		# force creation of pipe because on ocational times is missing.
		touch /usr/local/vesta/data/queue/letsencrypt.pipe
		chmod 750 /usr/local/vesta/data/queue/letsencrypt.pipe
	
	v-add-letsencrypt-user admin
	v-add-letsencrypt-domain admin $hostname
	while [ ! -f "/home/admin/conf/web/ssl."$hostname".pem" ]; do sleep 1;echo; done
	while [ ! -f "/home/admin/conf/web/ssl."$hostname".key" ]; do sleep 1;echo; done
	curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/mrhasbean/VestaCP/master/files/vesta_ssl > /etc/cron.daily/vesta_ssl
	sed -i 's/0DOMAIN0/'$hostname'/gi' /etc/cron.daily/vesta_ssl
	chmod +x /etc/cron.daily/vesta_ssl
	/etc/cron.daily/vesta_ssl
	
	# Update VestaCP settings for admin user
	v-delete-user-package gainsboro
	v-delete-user-package palegreen
	v-delete-user-package slategrey
	v-add-dns-record admin $hostname ns1 A $hostip
	v-add-dns-record admin $hostname ns2 A $hostip
	v-change-user-ns admin ns1.$hostname ns2.$hostname
	v-change-dns-record admin $hostname 1 ns1.$hostname.
	v-change-dns-record admin $hostname 2 ns2.$hostname.
	
	# Change default admin port to 2083
	sed -i 's/8083;/2083;/' /usr/local/vesta/nginx/conf/nginx.conf
	v-add-firewall-rule ACCEPT 0.0.0.0/0 2083 TCP
	sed -i -e '/8083/ s/ACCEPT/DROP/' /usr/local/vesta/data/firewall/rules.conf
	v-update-firewall
	service vesta restart
	
	# Remove the 15-mailboxes.conf file if it exists in Dovecot config directory
	if [ -f /etc/dovecot/conf.d/15-mailboxes.conf ]; then
		  mv /etc/dovecot/conf.d/15-mailboxes.conf /root/
	fi

	# Create & populate the Roundcube Database if it doesn't exist
	if [[ ! -d /var/lib/mysql/roundcube ]]; then

		  DB="roundcube"
		  IFS="'" read -ra IN <<< `grep dbpass /etc/roundcube/debian-db.php`
		  DBPASS="${IN[1]}"

		  mysql -e "CREATE DATABASE ${DB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
		  mysql -e "CREATE USER ${DB}@localhost IDENTIFIED BY '${DBPASS}';"
		  mysql -e "GRANT ALL PRIVILEGES ON ${DB}.* TO '${DB}'@'localhost';"
		  mysql -e "FLUSH PRIVILEGES;"

		  mysql roundcube < /usr/share/dbconfig-common/data/roundcube/install/mysql

	fi
	
	curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/mrhasbean/VestaCP/master/files/deploy_email > /root/vestacp/deploy_email.txt
	sed -i 's/0DOMAIN0/'$hostname'/gi' /root/vestacp/deploy_email.txt
	sed -i 's/0IPADDR0/'$hostip'/gi' /root/vestacp/deploy_email.txt
	recipients="steve.h@wpinsites.com"
	
	/usr/sbin/sendmail "$recipients" < /root/vestacp/deploy_email.txt

	rm -f /etc/cron.d/vultr_ssl
	service cron restart
	
fi
