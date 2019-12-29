# edit this config as per your requirements

NC_DB_USER=nextcloud
NC_DB_PASS=password
NC_DB_NAME=nextcloud

NC_DB_TYPE=mysql

NC_BACKUP_DIR=/mnt/containers/nextcoud/backups #no ending /

NC_DATA_DIR=/mnt/containers/nextcoud/data #no ending /
NC_APPS_DIR=/mnt/containers/nextcoud/apps #no ending /
NC_CONFIG_DIR=/mnt/containers/nextcoud/config #no ending /

NC_APP_CONTAINER=nextcloud
NC_DB_CONTAINER=mysql

S3_BUCKET=s3://s3-backups/nextcloud/
AWS_CLI_PROFILE=default
