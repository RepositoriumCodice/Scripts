# Setup NextCloud on Docker - DRAFT

This content is still in draft mode, I have a working solution that is fully functional.

The following steps will setup NextCloud using a:
* AWS Route 53 
* Lets Encrypt on Docker
* REDIS on Docker
* NGINX Reverse Proxy on Docker
* NextCloud on Docker
* MySQL on Docker
* Synology NAS
* BackBlaze

This guide assumes that you have:
* Registered a domain with AWS Route 53 Domains
* Have a static IP to forward the domain too
* Configured an A Record in AWS to point to the static IP
* Your Synology NAS is configured to serve NFS

The guide below was originally inspired by the following guides:
* https://www.freecodecamp.org/news/docker-nginx-letsencrypt-easy-secure-reverse-proxy-40165ba3aee2/
* https://medium.com/faun/docker-letsencrypt-dns-validation-75ba8c08a0d?

The steps below are high-level in nature, but I am happy to expand if needed.

## Check that your Route 53 DNS is correct

First ping the DNS and check that the name resolves the correct IP.

Next make sure your router forwards port 80, 443 and 8080 to the docker host.

## Setup NFS mounts

On your NAS setup NFS mounts for:
* MYSQL
* REDIS
* Lets Encrypt
* Reverse Proxy
* Next Cloud Data
* Next Cloud Apps
* Next Cloud Config

## Setup MySQL and Create a NextCloud Database

Use the following code to setup a MySQL instance if you dont have one already:
```
  mysql:
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: myRootPassword
    ports:
      - 3306:3306
    volumes:
      - thg001-mysql:/var/lib/mysql
    image: 'mysql:latest'
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    
volumes:    
  nfs-mysql:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=my.nfs.server,rsize=65536,wsize=65536,timeo=14,tcp,rw,noatime"
      device: ":/volume1/mysql/"     
```

_You will need to set the MYSQL_ROOT_PASSWORD, DNS of your NFS server and also the volume mentioned as: /volume1/mysql/._

Login into your MySQL server as root.

Run the following command to create the database and user with password. 

```
CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'passwordThatMustBeSecure';
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES on nextcloud.* to 'nextcloud'@'%';
FLUSH privileges;
```

_You will need to change 'passwordThatMustBeSecure' with the password that you would like to use in NextCloud. Also, ensure that your character set is set to utf8mb4 and the collation is utf8mb4_general_ci. This means NextCloud will have full support for Emojis (textbased smilies). _

## Setup an AWS IAM API user

Create an IAM API user for Route 53 and note the access key and secret. We will use this later with Let's Encrypt to automatically provide DNS validation for our certificates.

## Adjust NextCloud

Download the nextcloud Docker image.

Next we need to adjust the www-data user id and group id within the image to match a user in the Synology NAS. I have done this to avoid permission issues between the NextCloud and the Synology NAS. You can create new users in the Synology NAS, but cannot specify the UID or GID.  

Run the NextCloud container: docker run -d -p 8080:80 nextcloud

Then login and run the following commands.

pkill -9 -u www-data
usermod -u 1024 www-data
groupmod -g 101 users
groupmod -g 100 www-data

_Your www-data user and group will now match the admin user and users groups on the Synology NAS._

Finaly save your custom image to your repo.

## Step 4 - Setup Nextcloud

the following compose file will load all the initial dependencies.

```
version: '2'

services:  
  mysql:
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: myPassword
    ports:
      - 3306:3306
    volumes:
      - NFS-mysql:/var/lib/mysql
    image: 'mysql:latest'
    command: --default-authentication-plugin=mysql_native_password
    restart: always
      
  redis:
    container_name: redis
    image: 'bitnami/redis:latest'
    ports:
    - 6379:6379
    environment:
    - ALLOW_EMPTY_PASSWORD=yes
    volumes:
    - nfs-redis:/bitnami/redis/data   
    restart: always
    
  letsEncryptNextCloud:
    container_name: letsEncryptNextCloud
    image: linuxserver/letsencrypt
    restart: always
    environment:
    - PUID=1000
    - PGID=1000
    - TZ=Australia/Sydney
    - URL=myDomain.com
    - SUBDOMAINS=nextcloud
    - VALIDATION=dns
    - DNSPLUGIN=route53
    - EMAIL=support@myDomain.com
    - DHLEVEL=4096
    volumes:
    - nfs-letsEncryptNextCloud:/config
     
  reverse:
    container_name: reverse
    hostname: reverse
    image: nginx
    ports:
      - 180:80
      - 1443:443
    volumes:
      - nfs-reverseProxy:/etc/nginx
      - nfs-letsEncryptNextCloud:/nfs-letsEncryptNextCloud
    restart: always
    
  nextcloud:
    container_name: nextcloud
    image: myDockerHost:5000/nextcoud:synology
    depends_on:
      - mysql
      - redis
    links:
      - mysql
      - redis
    ports:
      - 8080:80
    volumes:
    - nfs-nextCloudData:/var/www/html/data
    - nfs-nextCloudApps:/var/www/html/apps
    - nfs-nextCloudConfig:/var/www/html/config      
    restart: always	
    
volumes:
  nfs-nextCloudConfig:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=mySynologyNFSDNSorIP,uid=1024,gid=100,rsize=65536,wsize=65536,timeo=14,tcp,rw,noatime"
      device: ":/volume1/nfs-nextCloudConfig/"
      
  nfs-nextCloudApps:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=mySynologyNFSDNSorIP,uid=1024,gid=100,rsize=65536,wsize=65536,timeo=14,tcp,rw,noatime"
      device: ":/volume1/nfs-nextCloudApps/"
      
  nfs-nextCloudData:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=mySynologyNFSDNSorIP,uid=1024,gid=100,rsize=65536,wsize=65536,timeo=14,tcp,rw,noatime"
      device: ":/volume1/nfs-nextCloudData/"
      
  nfs-mysql:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=mySynologyNFSDNSorIP,rsize=65536,wsize=65536,timeo=14,tcp,rw,noatime"
      device: ":/volume1/mysql/"  
      
  nfs-letsEncryptNextCloud:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=mySynologyNFSDNSorIP,rsize=65536,wsize=65536,timeo=14,tcp,rw,noatime"
      device: ":/volume1/letsEncryptNextCloud/"  
      
  nfs-reverseProxy:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=mySynologyNFSDNSorIP,rsize=65536,wsize=65536,timeo=14,tcp,rw,noatime"
      device: ":/volume1/reverseProxy/" 
       
  nfs-redis:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=mySynologyNFSDNSorIP,rsize=65536,wsize=65536,timeo=14,tcp,rw,noatime"
      device: ":/volume1/redis/"  
      
```

Open Nextcloud in the browser: http://0.0.0.0/8080

Follow the install and ensure you use the static IP of MySQL.

Edit the config in /mnt/containers/nextcoud/config.


## Step 4 - Setup Lets Encrypt

Use the docker-compose.yml example:

```
version: '2'
services:
  letsencrypt:
    image: linuxserver/letsencrypt
    container_name: letsencrypt
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Australia/Sydney
      - URL=mydomain.com
      - SUBDOMAINS=sub,
      - VALIDATION=dns
      - DNSPLUGIN=route53
      - EMAIL=support@mydomain.com
      - DHLEVEL=4096
    volumes:
      - /mnt/containers/letsencrypt:/config
```

Then run this since docker cannot ready symlinks
#!/bin/bash
cp /mnt/containers/letsencrypt/etc/letsencrypt/live/mydomain.com/fullchain.pem /mnt/containers/letsencrypt/etc/letsencrypt/live/mydomain.com/fullchain1.pem; 
cp /mnt/containers/letsencrypt/etc/letsencrypt/live/mydomain.com/privkey.pem /mnt/containers/letsencrypt/etc/letsencrypt/live/mydomain.com/privkey1.pem;


## Step 5 - Setup Reverse Proxy

Setup the reverse proxy step 1

Use the docker-compose.yml example:

```
  reverse:
    container_name: reverse
    hostname: reverse
    image: nginx
    ports:
    - 180:80
    - 1443:443
```

Use ```docker ps``` to get the contianer Id.

Copy the NGINX folder to local since these files don't exist locally, and NGINX will not start if they are not local and mounted.

```
docker cp conainterID:/etc/nginx mnt/containers/reverse
```

Now stop & remove the reverse container and use the docker-compose.yml example:
```
  reverse:
    container_name: reverse
    hostname: reverse
    image: nginx
    ports:
    - 180:80
    - 1443:443
    volumes:
    - /mnt/containers/reverse/nginx:/etc/nginx
    - /mnt/containers/letsencrypt/etc/letsencrypt/live/mydomain.com/etc/ssl/private
```

In the /nginx folder run:
```
openssl dhparam -out dhparams.pem 4096
```

Alter the nginx.conf file from:
```
include /etc/nginx/conf.d/*.conf;
```

to:
```
include /etc/nginx/conf.d/sites-enabled/*.conf;
```

...Or use the example in git.


In the conf.d folder delete: default.conf.

Inside conf.d, create two folders: sites-available and sites-enabled. 

Inside sites-available, add the nextcloud.conf file from git.

Inside the sites-enabled directory, and enter the following command:

ln -s ../sites-available/nextcloud.conf .

## Useful commands

On the host run a cron:

apt install curl
* * * * * /usr/bin/curl https://nextcloud.mydomain.com

Convert the database to use bigints

docker exec --user www-data containerID php occ db:convert-filecache-bigint

previews plugin - cannot if encryption

docker exec --user www-data containerID php occ preview:generate-all -vvv
docker exec --user www-data containerID php occ preview:pre-generate




