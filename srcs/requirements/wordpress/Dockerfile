FROM debian:bookworm
WORKDIR /var/www/wordpress

#Fail the build if any command in a pipeline fails
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get upgrade -y && apt-get install curl ca-certificates gpg gpg-agent php-fpm php-mysql php-redis -y --no-install-recommends && rm -rf /var/lib/apt/lists/* && \
    curl -Of https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    #Import GPG key and verify wp-cli signature
    curl -Of https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar.asc && \
    curl -Lf https://raw.githubusercontent.com/wp-cli/builds/gh-pages/wp-cli.pgp | gpg --import -q && \
    gpg --verify wp-cli.phar.asc wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/php-fpm8.2" ,"-F"]
