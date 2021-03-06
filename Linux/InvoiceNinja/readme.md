# Setup Invoice Ninja #

Invoice Ninja is a open-source invoice platform. You can install Invoice Ninja via Docker or manually. You can use the formal install method from here: https://github.com/invoiceninja/dockerfiles.

I use the following method to install Invoice Ninja - due to Docker issues from the official site.

Step 1:

Setup your Docker using the compose file. Note: that I use 'php:7.2.30-apache-buster' and my scripts have been adjusted accordingly.

Step 2: 

Run your container and then enter it.

Step 3:

Run the following command:

```bash <(curl -s https://raw.githubusercontent.com/RepositoriumCodice/Scripts/master/Linux/InvoiceNinja/setup.sh)```

Step 4:

Get the new app keys and update the .env files.

```
php /var/www/invoice-ninja/artisan key:generate --show
```

Once complete, then open the site in your browser and configure the details. Invoice Ninja will then generate the various APP KEYS and create a .env file. All the files are stored on your local mount. 
