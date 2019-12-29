#!/bin/bash

# how to:

# run as root: 
#    sudo su

# download from git (if needed): 
#    curl -LJO https://raw.githubusercontent.com/RepositoriumCodice/Scripts/master/Linux/Docker-NextCloud/backupNextCloudConfig.sh

# download from git: 
#    curl -LJO https://raw.githubusercontent.com/RepositoriumCodice/Scripts/master/Linux/Docker-NextCloud/backupNextCloud.sh

# set permissions:
#    chmod 770 backupNextcloud.sh 

# edit the file and set the details as required

# run:
# ./backupNextCloud.sh 

# config
baseDir="$(dirname "$0")"
source $baseDir/backupNextCloudConfig.sh

mkdir -p $NC_BACKUP_DIR
# abort entire script if any command fails
set -e

# Make sure nextcloud is enabled when we are done
trap "docker exec -u www-data $NC_APP_CONTAINER php occ maintenance:mode --off" EXIT

# set nextcloud to maintenance mode
docker exec -u www-data $NC_APP_CONTAINER php occ maintenance:mode --on

# backup db
sudo docker exec $NC_DB_CONTAINER mysqldump --single-transaction -h localhost -u $NC_DB_USER -p$NC_DB_PASS $NC_DB_NAME > $NC_BACKUP_DIR/db_dump_$NC_DB_TYPE.sql
tar -zcvf $NC_BACKUP_DIR/dbDump.tar.gz $NC_BACKUP_DIR/db_dump_$NC_DB_TYPE.sql
aws s3 cp $NC_BACKUP_DIR/dbDump.tar.gz $S3_BUCKET --profile=$AWS_CLI_PROFILE

#backup files
#tar -zcvf $NC_BACKUP_DIR/userData.tar.gz $NC_DATA_DIR
#aws s3 cp $NC_BACKUP_DIR/userData.tar.gz $S3_BUCKET --profile=$AWS_CLI_PROFILE

# end maintenance mode
docker exec -u www-data $NC_APP_CONTAINER php occ maintenance:mode --off

# delete trap
trap "" EXIT
