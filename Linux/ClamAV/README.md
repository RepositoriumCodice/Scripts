# Setup ClamAV on Ubuntu

Install ClamAV:
```
sudo apt-get install clamav clamav-daemon
```

When the installation is complete:

Stop the clamav-freshclam service:

```
systemctl stop clamav-freshclam
```

Run the freshclam command to update the signatures database
```
freshclam
```

Start clamav service:
```
systemctl start clamav-freshclam
```

Some useful commands:

Check the version of clamav:
```
clamscan --version
```

Scan and remove infected files starting from root /.
```
sudo clamscan --infected --remove --recursive /
```

Remove clamav:
```
sudo apt-get remove clamav clamav-daemon
```

Update the sources and install the new clamav package:
```
sudo apt-get update 
sudo apt-get install clamav
```
