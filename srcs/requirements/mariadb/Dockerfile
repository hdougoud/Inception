FROM debian:bookworm
WORKDIR /var/lib/mysql

#Add mariadb user and group first to make sure their IDs get assigned consistently
RUN groupadd -r mysql && useradd -r -g mysql mysql --home-dir /var/lib/mysql; \
    apt-get update && apt-get upgrade -y && apt-get install mariadb-server mariadb-client gosu --no-install-recommends -y && rm -rf /var/lib/apt/lists/*; \
#Purge /var/lib/mysql
    rm -rf /var/lib/mysql; \
    mkdir -p /run/mysqld /var/lib/mysql; \
	  chown -R mysql:mysql /var/lib/mysql /run/mysqld; \
	  chmod 1777 /run/mysqld

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown mysql:mysql /etc/mysql/mariadb.conf.d/50-server.cnf

#Copy the official healthcheck script
COPY ./tools/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

#Init and start Mariadb
ENTRYPOINT ["/entrypoint.sh"]
CMD ["mariadbd"]

EXPOSE 3306
