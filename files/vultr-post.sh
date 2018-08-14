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
	
	curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/mrhasbean/VestaCP/master/files/deploy_email > /root/vestacp/deploy_email.txt
	sed -i 's/0DOMAIN0/'$hostname'/gi' /root/vestacp/deploy_email.txt
	sed -i 's/0IPADDR0/'$hostip'/gi' /root/vestacp/deploy_email.txt
	recipients="steve.h@wpinsites.com"
	
	/usr/sbin/sendmail "$recipients" < /root/vestacp/deploy_email.txt

	rm -f /etc/cron.d/vultr_ssl
	service cron restart
	
fi
