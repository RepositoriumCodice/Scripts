#!/bin/bash
# ---------------------------------------------------------------------------
#
# This bash script will find all the log group names in a specific AWS region.
# It will then delete ALL the log groups in the region if you answer yes.
#
# Note the following assumptions:
# This script assumes you have AWS CLI installed and configured.
#
# Revision history:
# 2019-05-29 Created (v0.1)
#
# Tested on:
# - Ubuntu Server 18.04 (Cloud (AWS)) - 2019-05-29
# - Ubuntu 18.04 on Windows Subsystem for Linux - 2019-12-21
#
# DISCLAIMER:
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.

read -p "Please enter the AWS region [ap-southeast-2]? " region
region=${region:-ap-southeast-2}

echo Getting group names for $region...

LOG_GROUPS=$(
	aws logs describe-log-groups --output table --region $region |
		awk '{print $6}' |
		grep -v ^$ |
		grep -v DescribeLogGroups
)

echo These log groups will be deleted:
printf "${LOG_GROUPS}\n"
echo Total $(wc -l <<<"${LOG_GROUPS}") log groups
echo

while true; do
    read -p "Proceed? [yn]" yn
    case $yn in
    [Yy]*) break ;;
    [Nn]*) exit ;;
    *) echo "Please answer yes or no." ;;
    esac
done

for name in ${LOG_GROUPS}; do
	printf "Delete group ${name}... "
	aws logs delete-log-group --log-group-name ${name} --region $region && echo OK || echo Fail
done