FROM debian:bookworm
WORKDIR /etc/vsftpd

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

ENTRYPOINT ["/usr/sbin/vsftpd"]
CMD ["/etc/vsftpd/vsftpd.conf"]
