# Setup NTP on Docker

This enables you to run your own NTP server using Docker-Compose.

See the original guide at: https://github.com/cturra/docker-ntp

**You must alter the .env file as per your requirements!**
The instructions below contains my personal defaults.

To setup (run as root):

```
sudo su
 
mkdir Docker-Compose-NTP

cd Docker-Compose-NTP 
 
curl -LJO https://raw.githubusercontent.com/RepositoriumCodice/Scripts/master/Linux/Docker-Compose-NTP/.env
curl -LJO https://raw.githubusercontent.com/RepositoriumCodice/Scripts/master/Linux/Docker-Compose-NTP/docker-compose.yml

docker-compose up --detach
```
