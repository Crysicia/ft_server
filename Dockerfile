FROM debian:buster

RUN apt-get update \
	&& apt-get install -y nginx \
	&& apt-get install -y mariadb-server \
	&& apt-get install -y php-fpm \
	&& apt-get install -y php-mysql

CMD bash service nginx start && tail -f /dev/null
