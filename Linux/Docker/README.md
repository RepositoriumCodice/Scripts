# Setup Docker 

Update the local database of software:
sudo apt-get update

To install Docker on Ubuntu:
sudo apt install docker.io

The Docker service needs to be setup to run at startup:
sudo systemctl start docker
sudo systemctl enable docker

Optional
docker --version

Remove Docker
sudo apt-get remove docker docker-engine docker.io
