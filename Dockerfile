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
	&& wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 -O mkcert

RUN service mysql start \
	&& mysql -e "CREATE USER IF NOT EXISTS '$user'@'localhost' IDENTIFIED BY '$password';" \
	&& mysql -e "CREATE DATABASE IF NOT EXISTS $database;" \
	&& mysql -e "GRANT ALL PRIVILEGES ON $database.* TO '$user'@'localhost' WITH GRANT OPTION;" \
	&& mysql -e "FLUSH PRIVILEGES;"

RUN chmod 755 mkcert \
	&& ./mkcert -install \
	&& ./mkcert -cert-file /etc/ssl/certs/localhost-selfsigned.pem -key-file /etc/ssl/certs/localhost-selfsigned.key localhost

COPY srcs/localhost .

RUN mkdir /var/www/localhost \
	&& mv localhost /etc/nginx/sites-available/localhost \
	&& ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

COPY srcs/wordpress.tar.gz /var/www/localhost/

RUN tar xvzf /var/www/localhost/wordpress.tar.gz -C /var/www/localhost/ \
	&& rm /var/www/localhost/wordpress.tar.gz \
	&& chown -R www-data:www-data /var/www/localhost/wordpress

EXPOSE 80 443

RUN nginx -t

CMD service nginx start \
	&& service mysql start \
	&& service php7.3-fpm start \
	&& tail -f /dev/null
