FROM debian:bookworm
WORKDIR /etc/vsftpd

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends vsftpd \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/vsftpd/empty


COPY ./conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]

EXPOSE 20 21
