FROM debian:buster

ARG user=user42
ARG password=user42
ARG database=wordpress

RUN apt-get update \
	&& apt-get install -y nginx \
						  mariadb-server \
						  wget \
						  php7.3-fpm \
						  php7.3-mysql \
						  php7.3-curl \
						  php7.3-gd \
						  php7.3-intl \
						  php7.3-mbstring \
						  php7.3-soap \
						  php7.3-xml \
						  php7.3-xmlrpc \
						  php7.3-zip \
						  sendmail \
	&& wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 -O mkcert

RUN service mysql start \
	&& mysql -e "CREATE USER IF NOT EXISTS '$user'@'localhost' IDENTIFIED BY '$password';" \
	&& mysql -e "CREATE DATABASE IF NOT EXISTS $database;" \
	&& mysql -e "GRANT ALL PRIVILEGES ON $database.* TO '$user'@'localhost' WITH GRANT OPTION;" \
	&& mysql -e "FLUSH PRIVILEGES;"

RUN chmod 755 mkcert \
	&& ./mkcert -install \
	&& ./mkcert -cert-file /etc/ssl/certs/localhost-selfsigned.pem -key-file /etc/ssl/certs/localhost-selfsigned.key localhost

COPY srcs/ .

RUN mkdir /var/www/localhost \
	&& mv localhost /etc/nginx/sites-available/localhost \
	&& ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

RUN service mysql start \
	&& tar xvzf wordpress.tar.gz -C /var/www/localhost/ \
	&& rm wordpress.tar.gz \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp \
	&& wp config create --path=/var/www/localhost/wordpress --dbname=$database --dbuser=$user --dbpass=$password --allow-root \
	&& wp core install --path=/var/www/localhost/wordpress --url=localhost/wordpress --title="lpassera's ft_server" --admin_user=admin --admin_password=admin --admin_email=admin@localhost.com --allow-root

RUN mkdir /var/www/localhost/phpmyadmin \
	&& tar xvzf phpmyadmin.tar.gz -C /var/www/localhost/phpmyadmin --strip-components 1 \
	&& cp /var/www/localhost/phpmyadmin/config.sample.inc.php /var/www/localhost/phpmyadmin/config.inc.php \
	&& sed -ri "s/cfg\['blowfish_secret'\] = ''/cfg['blowfish_secret'] = '`openssl rand -hex 32`'/" /var/www/localhost/phpmyadmin/config.inc.php \
	&& chown -R www-data:www-data /var/www/localhost/

EXPOSE 80 443

RUN nginx -t

ENTRYPOINT service nginx start \
		   && service mysql start \
		   && service php7.3-fpm start \
		   && service sendmail start \
		   && tail -f /dev/null
