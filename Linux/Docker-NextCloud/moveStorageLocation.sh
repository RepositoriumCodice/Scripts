#!/bin/bash

NC_APP_CONTAINER=nextcloud

# abort entire script if any command fails
set -e

# Make sure nextcloud is enabled when we are done
trap "docker exec -u www-data nextcloud php occ maintenance:mode --off" EXIT

# set nextcloud to maintenance mode
docker exec -u www-data nextcloud php occ maintenance:mode --on
 cp -a /mnt/containers/nextcoud/data/. /mnt/albus
# backup db
sudo docker exec $NC_DB_CONTAINER mysqldump --single-transaction -h localhost -u $NC_DB_USER -p$NC_DB_PASS $NC_DB_NAME > $NC_BACKUP_DIR/db_dump_$NC_DB_TYPE.sql
tar -zcvf $NC_BACKUP_DIR/dbDump.tar.gz $NC_BACKUP_DIR/db_dump_$NC_DB_TYPE.sql
aws s3 cp $NC_BACKUP_DIR/dbDump.tar.gz $S3_BUCKET --profile=$AWS_CLI_PROFILE

# backup data
tar -zcvf $NC_BACKUP_DIR/userData.tar.gz $NC_DATA_DIR
aws s3 cp $NC_BACKUP_DIR/userData.tar.gz $S3_BUCKET --profile=$AWS_CLI_PROFILE

# backup apps
tar -zcvf $NC_BACKUP_DIR/apps.tar.gz $NC_APPS_DIR
aws s3 cp $NC_BACKUP_DIR/apps.tar.gz $S3_BUCKET --profile=$AWS_CLI_PROFILE

# backup config
tar -zcvf $NC_BACKUP_DIR/config.tar.gz $NC_CONFIG_DIR
aws s3 cp $NC_BACKUP_DIR/config.tar.gz $S3_BUCKET --profile=$AWS_CLI_PROFILE

# end maintenance mode
docker exec -u www-data nextcloud php occ maintenance:mode --off

# delete trap
trap "" EXIT



