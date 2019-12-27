# Setup Pi-hole on Docker

This enables you to run Pi-hole on Docker without any reverse proxy. The example below will not use Pi-hole as a DHCP server. 

Source: https://www.smarthomebeginner.com/run-pihole-in-docker-on-ubuntu-with-reverse-proxy/

## Step 1 - Disable Ubuntu's DNS

Disable Ubuntu's resolver service:
```
sudo systemctl disable systemd-resolved.service
sudo systemctl stop systemd-resolved.service
``

Open the network manager configuration using the following command for editing:
```
sudo nano /etc/NetworkManager/NetworkManager.conf
```

Add 'dns=default' under the [main] section. 

The file contents should look like this:
```
[main]
plugins=ifupdown,keyfile
dns=default
...
```

Rename /etc/resolv.conf symbolic link file:
```
sudo mv /etc/resolv.conf /etc/resolv.conf.bak
```

Restart the network manager:
```
sudo service network-manager restart
```

## Step 2 - Setup Pi-hole using Docker-Compose

**You must alter the .env file as per your requirements!**
The instructions below contains my personal defaults.

To setup (run as root):

```
sudo su
 
mkdir Docker-Compose-Pihole

cd Docker-Compose-NTP 
 
curl -LJO https://raw.githubusercontent.com/RepositoriumCodice/Scripts/master/Linux/Docker-Compose-Pihole/.env
curl -LJO https://raw.githubusercontent.com/RepositoriumCodice/Scripts/master/Linux/Docker-Compose-Pihole/docker-compose.yml

docker-compose up --detach
```

## Step 3 - Forward Google DNS to Pi-hole

On your router do something like the following:

DHCP->DHCP Settings->Set Primary/Secondary DNS

Set the DNS to the Pi-hole IP: 192.168.0.100

Advanced Routing->Static Routing

ID	Destination Network     Subnet Mask		Default Gateway
1	8.8.8.8			255.255.255.255		192.168.0.100	
2	8.8.4.4			255.255.255.255		192.168.0.100	
