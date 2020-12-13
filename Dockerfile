FROM debian:buster

ARG user=user42
ARG password=user42
ARG database=wordpress

RUN apt-get update \
	&& apt-get install -y nginx \
	&& apt-get install -y mariadb-server \
	&& apt-get install -y php7.3-fpm \
	&& apt-get install -y php7.3-mysql

RUN service mysql start \
	&& mysql -e "CREATE USER IF NOT EXISTS '$user'@'localhost' IDENTIFIED BY '$password';" \
	&& mysql -e "CREATE DATABASE IF NOT EXISTS $database;" \
	&& mysql -e "GRANT ALL PRIVILEGES ON $database.* TO '$user'@'localhost' WITH GRANT OPTION;" \
	&& mysql -e "FLUSH PRIVILEGES;"

COPY srcs/localhost .

RUN mkdir /var/www/localhost \
	&& mv localhost /etc/nginx/sites-available/localhost \
	&& ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

COPY srcs/info.php /var/www/localhost/

EXPOSE 80 443

CMD service nginx start \
	&& service mysql start \
	&& service php7.3-fpm start \
	&& tail -f /dev/null
