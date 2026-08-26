FROM debian:bookworm

RUN apt-get update && apt-get install -y wget \
    && wget https://github.com/portainer/portainer/releases/download/2.39.6/portainer-2.39.6-linux-amd64.tar.gz \
    && tar -xf portainer-2.39.6-linux-amd64.tar.gz \
    && rm -rf portainer-2.39.6-linux-amd64.tar.gz

WORKDIR /portainer

ENTRYPOINT ["/portainer/portainer"]
CMD ["--http-disabled", "--admin-password-file", "/run/secrets/portainer_admin_password"]

EXPOSE 9443


