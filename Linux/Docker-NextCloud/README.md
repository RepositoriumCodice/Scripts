# Setup Nextcloud on Docker

The following steps will setup Nextcloud using MySQL/AWS Route 53/Lets Encrypt/NGINX Reverse Proxy.

This guide assumes that you have:
* Registered a domain with AWS Route 53 Domains
* Have a Static IP to forward the domain too
* Configured an A Record in AWS to point to the static IP

Source:

https://www.freecodecamp.org/news/docker-nginx-letsencrypt-easy-secure-reverse-proxy-40165ba3aee2/

https://medium.com/faun/docker-letsencrypt-dns-validation-75ba8c08a0d?

Enhancements:
* Enable reverse to support multiple domains
* Script the full install using bash
* Automatically copy certs or get the setup to use the symlinks


## Step 1 - Create a database

Login into your MySQL server as root.

Run the following command to create the database and user with password.

```
CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'passwordThatMustBeSecure';
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES on nextcloud.* to 'nextcloud'@'%';
FLUSH privileges;
```

## Step 2 - Setup an IAM API user

Create aan IAM user for route 53 and note the access key and secret.

Access key ID AKIA2OYVEXAMPLE
Secret access key 3t7GBOUx/ddDzaEXAMPLE

## Step 3 - Setup Nextcloud

Use the docker-compose.yml example:

```
  nextcloud:
    container_name: nextcloud
    image: nextcloud
    ports:
      - 8080:80
    volumes:
      - /mnt/containers/nextcoud/data:/var/www/html/data
      - /mnt/containers/nextcoud/config:/var/www/html/config
      - /mnt/containers/nextcoud/apps:/var/www/html/apps
    restart: always
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



