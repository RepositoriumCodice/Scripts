# Setup MySQL on Docker

This will download the latest MySQL image and configure it.

Note the following line in the docker-compose file:
* command: --default-authentication-plugin=mysql_native_password
This will avoid the following error when attempting to login for the first time: Unable to load authentication plugin 'caching_sha2_password'.

**You must alter the .env file as per your requirements!**
The instructions below contains my personal defaults.

To setup (run as root):
```
sudo su
 
mkdir Docker-Compose-MySQL

cd Docker-Compose-MySQL
 
curl -LJO https://raw.githubusercontent.com/RepositoriumCodice/Scripts/master/Linux/Docker-Compose-MySQL/.env
curl -LJO https://raw.githubusercontent.com/RepositoriumCodice/Scripts/master/Linux/Docker-Compose-MySQL/docker-compose.yml

docker-compose up --detach
```
