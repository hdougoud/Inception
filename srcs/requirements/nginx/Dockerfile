FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists
WORKDIR /etc/nginx

COPY ./conf/inception_ssl.cnf inception_ssl.cnf
RUN openssl req -x509 -nodes -days 365 \
 -newkey rsa:2048 \
 -keyout /etc/ssl/inception.key \
 -out /etc/ssl/inception.crt \
 -config inception_ssl.cnf \
 -extensions ext && rm -rf inception_ssl.cnf

#According to the Docker documentation, it is best practice to declare the command using the ENTRYPOINT and CMD keywords for the flags
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]

EXPOSE 443
