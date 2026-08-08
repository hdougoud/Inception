FROM debian:bookworm
WORKDIR /var/www/html

RUN apt-get update && apt-get upgrade -y && \
    apt-get install php php-mysql curl ca-certificates wget --no-install-recommends -y && \
    rm -rf /var/libs/apt/lists/*

ENV ADMINER_VERSION=6.0.0
ENV ADMINER_DOWNLOAD_SHA256=8181c9be10f290243724acb0e4dc930fe04440a343fb11dcc8ddb9821095e274

RUN	set -x \
    &&	curl -fsSL https://github.com/vrana/adminer/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION.php -o adminer.php \
    &&	echo "$ADMINER_DOWNLOAD_SHA256  adminer.php" | sha256sum -c \
    &&  wget https://dev.mysql.com/downloads/file/?id=551957


ENTRYPOINT ["php"]
CMD ["-S", "0.0.0.0:8080", "-t", "/var/www/html"]
EXPOSE 8080

