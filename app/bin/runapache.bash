#!/bin/bash

set -e

DOCROOT=/var/www/html
SETUPDIR=${DOCROOT}/c/SETUP

sql(){
	mysql -h pgdp-sql --password=dp_password
}

echo waiting for mysql server...
while ! mysqladmin ping -h pgdp-sql --password=dp_password --silent; do
	sleep 1
done
echo got ping back from mysql

# configure PD & initialize database
# Note: remove SETUP directory in production
cd $SETUPDIR
./configure /app/config/dproofreads_config.sh $DOCROOT
php -f install_db.php

echo 'CREATE DATABASE IF NOT EXISTS phpbb;' | sql

# for dp_db.users.postprocessor, and other tinytext fields
echo "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'STRICT_TRANS_TABLES',''));" | sql


cd $DOCROOT
apache2-foreground &


# Set up phpBB
sleep 3	# wait for apache to start up
if echo 'select 1 from phpbb.phpbb_config;' | sql
then
	echo phpBB already set up
	if [ ! -e "${DOCROOT}/phpBB3/config.php" ]
	then
		cp /app/config/phpbb_config.php ${DOCROOT}/phpBB3/config.php
	fi
else
	echo setting up phpBB for first time
	chown www-data:www-data ${DOCROOT}/phpBB3/config.php
	/app/bin/phpbb-setup.bash >/dev/null
fi
if echo 'select 1 from phpbb.phpbb_config;' | sql
then
	echo moving phpBB install directory
	mkdir -p /app/phpBB3
	mv $DOCROOT/phpBB3/install /app/phpBB3
fi

if ! /app/bin/create-admin.bash > /dev/null; then
	echo creating admin user failed
fi

wait # apache2-foreground
