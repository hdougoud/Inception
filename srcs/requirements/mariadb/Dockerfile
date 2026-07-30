FROM debian:bookworm
WORKDIR /var/lib/mysql

#Add mariadb user and group first to make sure their IDs get assigned consistently
RUN groupadd -r mysql && useradd -r -g mysql mysql --home-dir /var/lib/mysql

RUN apt-get update && apt-get upgrade -y && apt-get install mariadb-server gosu -y && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld; \
	  chown -R mysql:mysql /var/lib/mysql /run/mysqld; \
	  chmod 1777 /run/mysqld

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mariadbd"]

EXPOSE 3306
