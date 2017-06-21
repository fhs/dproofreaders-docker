#!/bin/bash

DOCROOT=/var/www/html
SETUPDIR=${DOCROOT}/c/SETUP

mysqlrun(){
	mysql -h pgdp-sql --password=dp_password
}

# initialize database
cd $SETUPDIR
php -f install_db.php
mkdir /app/c
mv $SETUPDIR /app/c

echo 'CREATE DATABASE IF NOT EXISTS phpbb;' | mysqlrun

# for dp_db.users.postprocessor, and other tinytext fields
echo "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'STRICT_TRANS_TABLES',''));" | mysqlrun

if echo 'select 1 from phpbb.phpbb_config;' | mysqlrun
then
	echo phpBB already installed
	cp /app/config/phpbb_config.php /var/www/html/phpBB3/config.php
	mkdir /app/phpBB3
	mv $DOCROOT/phpBB3/install /app/phpBB3
else
	echo phpBB not installed
	chown www-data:www-data /var/www/html/phpBB3/config.php
fi

cd $DOCROOT
exec apache2-foreground
