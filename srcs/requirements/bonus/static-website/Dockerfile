FROM debian:bookworm
WORKDIR /app

COPY ./tools/app.py /app/app.py
COPY ./tools/www/* /app/

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    python3

ENTRYPOINT ["python3"]
CMD ["app.py"]

EXPOSE 8080

