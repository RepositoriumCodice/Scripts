# Bash Script to Bulk Delete AWS CloudWatch Log Groups

The AWS Management Console does not allow you to bulk delete multiple AWS CloudWatch Log Groups. Use this bash script to bulk delete AWS CloudWatch log groups.

The bash script will do the following:

Ask the AWS region you want to access.
* Confirm the Cloud Watch Log Groups that it found in the specified AWS region.
* Ask if it should delete the mentioned Cloud Watch Log Groups.
* Delete each Cloud Watch Log Group, if you enter yes.

Visit my blog for more info: https://anto.online/bash-and-php-scripts/delete-aws-log-groups-bash-script/
