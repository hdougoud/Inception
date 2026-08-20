FROM debian:bookworm AS downloader

ARG NODE_VERSION=v24.19.0-linux-arm64

ENV PATH="/usr/local/node/bin:${PATH}"

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
      wget \
      ca-certificates \
      xz-utils \
    && wget --progress=dot:giga https://go.dev/dl/go1.26.6.linux-amd64.tar.gz \
    && tar -xf go1.26.6.linux-amd64.tar.gz \
    && wget --progress=dot:giga https://nodejs.org/dist/v24.19.0/node-${NODE_VERSION}.tar.gz \
    && tar -xf node-${NODE_VERSION}.tar.gz \
    && mv node-${NODE_VERSION} /usr/local/node \
    && npm install --global yarn \
    && npm install --global pnpm

#------------------------------#

FROM debian:bookworm AS builder
WORKDIR /portainer

ENV PATH="/usr/local/node/bin:${PATH}"
ENV PATH="/usr/local/go/bin:${PATH}"
ENV SHELL=/bin/bash

COPY --from=downloader /go /usr/local/go
COPY --from=downloader /usr/local/node /usr/local/node

RUN node --version && npm --version && yarn --version && pnpm --version

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
      git \
      make \
      jq \
      libatomic1 \
      ca-certificates \
    && git clone --single-branch --branch "release/2.44" https://github.com/portainer/portainer.git /portainer \
    && make ENV=production all

#------------------------------#

FROM debian:bookworm
WORKDIR /portainer

COPY --from=builder /portainer/dist /portainer

ENTRYPOINT ["/portainer/portainer"]
CMD ["--http-disabled", "--admin-password-file", "/run/secrets/portainer_admin_password"]

EXPOSE 9443


