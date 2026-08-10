FROM debian:bookworm
WORKDIR /var/www/adminer

RUN apt-get update && apt-get upgrade -y && \
    apt-get install php php-mysql curl ca-certificates --no-install-recommends -y && \
    rm -rf /var/lib/apt/lists/*

ENV ADMINER_VERSION=6.0.0
ENV ADMINER_DOWNLOAD_SHA256=8181c9be10f290243724acb0e4dc930fe04440a343fb11dcc8ddb9821095e274

RUN	set -x \
    &&	curl -fsSL https://github.com/vrana/adminer/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION.php -o adminer.php \
    &&	echo "$ADMINER_DOWNLOAD_SHA256  adminer.php" | sha256sum -c \
    &&  mv adminer.php index.php


ENTRYPOINT ["php"]
CMD ["-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
EXPOSE 8080

