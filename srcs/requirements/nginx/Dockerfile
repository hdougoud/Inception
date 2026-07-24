FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists
WORKDIR /etc/nginx

#According to the Docker documentation, it is best practice to declare the command using the ENTRYPOINT and CMD keywords for the flags
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
#TODO: use a entrypoint.sh to get the certificate ssl and start nginx
#INFO: It is possible to use a self-signed certificate

EXPOSE 443
