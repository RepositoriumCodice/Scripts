#!/bin/bash

NC_APP_CONTAINER=nextcloud

# abort entire script if any command fails
set -e

# Make sure nextcloud is enabled when we are done
trap "docker exec -u www-data nextcloud php occ maintenance:mode --off" EXIT

# set nextcloud to maintenance mode
docker exec -u www-data nextcloud php occ maintenance:mode --on

#source: https://help.nextcloud.com/t/thumbnails-previews-loading-slow-on-files-and-gallery-app/58749
docker exec -u www-data $NC_APP_CONTAINER php occ config:app:set previewgenerator squareSizes --value="32 256"
docker exec -u www-data $NC_APP_CONTAINER php occ config:app:set previewgenerator widthSizes  --value="256 384"
docker exec -u www-data $NC_APP_CONTAINER php occ config:app:set previewgenerator heightSizes --value="256"
docker exec -u www-data $NC_APP_CONTAINER php occ config:app:set preview jpeg_quality --value="60"
docker exec -u www-data $NC_APP_CONTAINER php occ config:system:set preview_max_x --value 512
docker exec -u www-data $NC_APP_CONTAINER php occ config:system:set preview_max_y --value 512
docker exec -u www-data $NC_APP_CONTAINER php occ config:system:set jpeg_quality --value 60

# end maintenance mode
docker exec -u www-data nextcloud php occ maintenance:mode --off

# delete trap
trap "" EXIT
