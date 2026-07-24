FROM debian:bookworm
WORKDIR /var/www/wordpress

RUN apt-get update && apt-get upgrade -y && apt-get install curl gpg php-fpm php-mysql -y && rm -rf /var/lib/apt/lists/*
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar >/dev/null 2>&1

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/php-fpm8.2" ,"-F"]

EXPOSE 9000
