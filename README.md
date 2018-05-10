# VestaCP on Digital Ocean (Ubuntu 16.04 LTE)

A little script to have a web server in Digital Ocean with Vesta Control Panel in no time.
Good for people with no linux experience and much better for the others.

Original script can be found at https://github.com/FastDigitalOceanDroplets/VestaCP

Script will install: 

 - VestaCP
 - Nginx 1.11.x
 - PHP 7.0.x
 - MySQL 5.7.x
 - Exim 4.x
 - Dovecot 2.2.x
 - vsftpd
 - named
 - iptables
 - fail2ban

On servers over 3Gb of ram:

 - Spam-Assassin
 - ClamAV

What is done additionally to a standard VestaCP installation:
- Make the VestaCP interface secure by default by automatically adding a free Let's Encrypt certificate.
  - NOTE: Ensure your domain is already mapped to your droplet!
- Add a v-search-command to allow finding shell Vesta commands easily
- Make a swap partition of 1 gb to make some room for some things to work better.
- Configure server Time Zone.
- Configure server Locales.
- Fully Update the OS.
- Setup unattended-upgrades.
- Remove admin group.
- Add php-zip and php-gd modules
- Fix bash profile
- ...and after installation, run patches to the specific VestaCP version if available.

Minimal requirements

A 5 dollars a month Digital Ocean Ubuntu 16.04 64 bit server, 1 GB ram / 1 CPU, 25 GB SSD Disk, 1000 GB Transfer.
Get it at https://m.do.co/c/9e2b87317b00 (my affiliate link) or https://goo.gl/WWmpYW (original dev's affiliate link). 
With this affiliate program link, they will instantly give you `10 u$ credit in virtual machines` (this is a 2 month free hosting) just for signing in with that link.

After login to the droplet for the first time, copy the line bellow and execute it in the terminal

    curl -O https://raw.githubusercontent.com/mrhasbean/VestaCP/master/vestacp.sh && bash vestacp.sh

Once installed REBOOT the droplet. (Very important to do for the nex step !!!)

Once rebooted, run the following for some basic setup and patch installation for the specific VestaCP version. Copy the line bellow and execute it in the terminal. (the patch may or may not reboot the system again)

    bash post.sh

Raise an issue on Github for any problems you find.
