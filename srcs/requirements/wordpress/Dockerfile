FROM debian:bookworm

WORKDIR /var/www/html

RUN apt-get update && apt-get upgrade -y && apt-get install wget php-fpm php-mysql -y
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
ENTRYPOINT [ "/entrypoint.sh" ]

RUN rm -rf /var/lib/apt/lists/*
#TODO: remove the "wget" paquet ?

EXPOSE 9000
