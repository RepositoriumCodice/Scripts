# Setup MySQL on Docker/Portainer

This will download the latest MySQL image and configure it.

Note the following line in the compose.yml file:
* command: --default-authentication-plugin=mysql_native_password
** This will avoid the following error when attempting to login for the first time: Unable to load authentication plugin 'caching_sha2_password'.

## Requirements:

* Root access
* Installed Docker


