FROM debian:bookworm
WORKDIR /etc/redis

RUN apt-get update && apt-get upgrade -y && apt-get install lsb-release curl ca-certificates gpg --no-install-recommends -y  && \
    curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
    chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list && \
    apt-get update && \
    apt-get install redis -y

COPY ./conf/redis.conf /etc/redis/redis.conf

ENTRYPOINT ["redis-server"]
CMD ["/etc/redis/redis.conf"]

EXPOSE 6379
