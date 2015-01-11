# Log in to your server as the root user:
# ssh root@yourip

SSH_PORT = 22 # could be any port


# Update the package list and upgrade existing packages:

apt-get -y update && apt-get -y upgrade

# Install the UFW Firewall package:

apt-get install ufw


# Add the deploy user and add it to /etc/sudoers:
useradd -U -s /bin/bash -m deploy
adduser deploy sudo


# Change the SSH port (security measure). Change the SSH_PORT variable  
# to whatever you want to change the port to:

sed -i "s/Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
service ssh reload


# Configure the firewall (UFW) to allow the $SSH_PORT, 80 (http) and 443 (https) ports:

ufw allow $SSH_PORT
ufw allow 80
ufw allow 443
ufw --force enable


# Finally, lock the root (disabling the password):
# From now on, SSH in to your VPS as deploy and sudo su to log in as root.

passwd -l root


# All done

exit