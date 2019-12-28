#!/bin/bash

NC_DB_USER=nextcloud
NC_DB_PASS=password
NC_DB_NAME=nextcloud
NC_DB_TYPE=mysql
NC_DB_DUMP_DIR=/mnt/containers/nextcoud/backups #no ending /
NC_APP_CONTAINER=nextcloud
NC_DB_CONTAINER=mysql

mkdir -p $NC_DB_DUMP_DIR
# abort entire script if any command fails
set -e

# Make sure nextcloud is enabled when we are done
trap "docker exec -u www-data $NC_APP_CONTAINER php occ maintenance:mode --off" EXIT

# set nextcloud to maintenance mode
docker exec -u www-data $NC_APP_CONTAINER php occ maintenance:mode --on

# backup db
sudo docker exec $NC_DB_CONTAINER mysqldump --single-transaction -h localhost -u $NC_DB_USER -p$NC_DB_PASS $NC_DB_NAME > $NC_DB_DUMP_DIR/db_dump_$NC_DB_TYPE"_nextcloud.sql"

# end maintenance mode
docker exec -u www-data $NC_APP_CONTAINER php occ maintenance:mode --off

# delete trap
trap "" EXIT
