FROM debian:bookworm

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV PATH="/usr/local/go/bin:${PATH}"
ENV SHELL=/bin/bash

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
      git \
      make \
      wget \
      jq \
      npm \
      libatomic1 \
      gnupg \
      curl \
      ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && node --version \
    && rm -rf /var/lib/apt/lists/* \
    && npm install --global yarn \
    && npm install --global pnpm \
    && wget https://go.dev/dl/go1.26.6.linux-amd64.tar.gz \
    && tar -xf go1.26.6.linux-amd64.tar.gz \
    && mv go /usr/local/ \
    && go version \
    && git clone --single-branch --branch "release/2.44" https://github.com/portainer/portainer.git portainer \
    && cd portainer \
    && make ENV=production all

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/portainer/dist/portainer", "--http-disabled", "--admin-password-file", "/run/secrets/portainer_admin_password"]

EXPOSE 9443


