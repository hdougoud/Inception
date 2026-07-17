FROM debian:bookworm

WORKDIR /usr/share/wordpress

RUN apt-get update && apt-get upgrade -y && apt-get install wordpress php-fpm -y && rm -rf /var/lib/apt/lists/*

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
EXPOSE 9000
