FROM php:5.6-apache

# libpng12-dev for php gd extension
# libyaz4-dev for php yaz extension
# unzip is for c/tools/project_manager/add_files.php
# aspell is for WordCheck
# mysql-client, vim, less are just for debugging
RUN apt-get update && \
	apt-get install -y libpng12-dev libyaz4-dev unzip aspell mysql-client vim less
	
# mysql is for dproofreaders
# mysqli is for phpBB3 (note: things break if mysql is used instead of mysqli)
RUN docker-php-ext-install mysql mysqli gd && \
	pecl install yaz-1.2.1

COPY app /app
RUN mkdir -p /var/www/html/ && \
	cd /var/www/html/ && \
	tar xzf /app/src/dproofreaders.R201701.tgz

RUN /var/www/html/c/SETUP/configure /app/config/dproofreads_config.sh /var/www/html

RUN cd /var/www/html/ && \
	tar xjf  /app/src/phpBB-3.0.14.tar.bz2

# TODO: chmod
RUN cd /var/www/html && \
	cp /app/lib/index.html /var/www/html/index.html && \
	mkdir -p \
		/tmp/sp_check \
		projects \
		d/locale \
		d/stats/automodify_logs \
		d/teams/avatar \
		d/teams/icon \
		d/pg \
		d/xmlfeeds \
		/home/dpscans && \
	chown -R www-data:www-data /tmp/sp_check projects d /home/dpscans

RUN cp /app/config/php.ini /usr/local/etc/php/


CMD ["/app/bin/runapache.bash"]
