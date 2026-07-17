FROM debian:bookworm

WORKDIR /var/www/html

RUN apt-get update && apt-get upgrade -y && apt-get install wget php-fpm -y
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

RUN rm -rf /var/lib/apt/lists/*
#TODO: remove the "wget" paquet ?

EXPOSE 9000
