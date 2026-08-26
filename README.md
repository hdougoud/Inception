*This project has been created as part of the 42 curriculum by hdougoud.*

# Inception

## Description

Inception is a system administration project whose goal is to set up a small
web infrastructure entirely with Docker. Every service is built from a
Dockerfile written from scratch (no ready-made images from Docker Hub, apart
from the base OS), runs in its own dedicated container, and the whole stack
is orchestrated with a single `docker-compose.yml`, launched through a
`Makefile`.

The mandatory stack reproduces a classic web architecture: a reverse proxy
terminating TLS, an application server running WordPress on PHP-FPM, and a
dedicated database container, all connected through a private Docker
network and backed by persistent named volumes.

| Service | Role | Base image | Exposed |
|---|---|---|---|
| NGINX | Reverse proxy, TLS termination, only entrypoint | debian:bookworm | 443 (host) |
| WordPress + php-fpm | Application server | debian:bookworm | 9000 (internal) |
| MariaDB | Database | debian:bookworm | 3306 (internal) |

### Bonus services

| Service | Role | Base image | Exposed |
|---|---|---|---|
| Redis | Object cache for WordPress | debian:bookworm | 6379 (internal) |
| Adminer | Lightweight web UI to inspect/manage the MariaDB database | debian:bookworm | via NGINX `/adminer` |
| vsftpd | FTP server giving access to the WordPress volume | debian:bookworm | 20, 21, 10090-10100 (host) |
| Portainer | Web UI to manage/monitor the whole Docker stack, built from source | debian:bookworm | 9443 (host) |
| static-website | Small static site to browse this README, `USER_DOC.md` and `DEV_DOC.md` as HTML pages | debian:bookworm | 8080 (host) |

## Instructions

### Prerequisites

- A virtual machine running Docker and Docker Compose
- `make` and `sudo` rights (needed once, to edit `/etc/hosts`)
- A `srcs/.env` file (versioned, see `srcs/.env`)

Neither the domain entry in `/etc/hosts` nor the files in `secrets/` need to
be created by hand: the `Makefile` generates both on first run (see below).

### Build and run

```bash
make          # first run: add the host entry, generate the secrets, build and start the stack
make build    # build the images only
make up       # start the stack (without touching /etc/hosts or the secrets)
make down     # stop the containers
make clean    # stop the stack and remove the images
make fclean   # clean + remove the named volumes
make re       # fclean + build + up
```

`make` (i.e. the `all` target) runs three steps in order: `host` (adds
`127.0.0.1 hdougoud.42.fr` to `/etc/hosts` via `sudo`, only if it's not
already there), `secrets` (fills `secrets/` with freshly generated random
passwords), then `up`.

> **Note:** `secrets` regenerates every password each time it runs, with no
> check for existing files. Use plain `make` only for the very first setup.
> For every subsequent start/stop, use `make up` / `make down` (or `make
> re`) instead of `make`/`make all`, otherwise the password files would be
> overwritten and no longer match the credentials already stored inside
> WordPress/MariaDB.

Once started, the site is available at `https://hdougoud.42.fr`. The
certificate is self-signed, so the browser will show a warning.

## Project description

### Why Docker

Docker lets every service (NGINX, WordPress/PHP, MariaDB, plus the bonus
services) be defined once as a Dockerfile and rebuilt identically on any
machine, instead of manually installing and configuring packages on a
shared OS. Each service is isolated in its own container with its own
filesystem and process space, containers can be restarted or rebuilt
independently, and the entire infrastructure is described declaratively in
`docker-compose.yml`, so the whole stack comes up (or down) with a single
command.

### Sources included

All the project sources live under `srcs/`:

- `srcs/docker-compose.yml` and `srcs/.env` — orchestration and non-sensitive
  configuration (domain name, database name, usernames, etc.).
- `srcs/requirements/nginx`, `srcs/requirements/wordpress`,
  `srcs/requirements/mariadb` — one directory per mandatory service, each
  containing its own `Dockerfile`, a `conf/` folder with the service
  configuration, and a `tools/` folder with the entrypoint script(s) used to
  initialize and start the service.
- `srcs/requirements/bonus/` — one directory per bonus service (`redis`,
  `adminer`, `vsftpd`, `portainer`, `static-website`), following the exact
  same layout. `static-website/tools/www/` holds the pre-built HTML/CSS
  pages served by that container (see "Main design choices" below).
- `secrets/` (git-ignored, only a `.gitkeep` is versioned) — one file per
  password, referenced as Docker secrets by the services that need them.
  These files don't exist in a fresh checkout; the `secrets` Makefile
  target creates them with randomly generated values.

### Main design choices

- **Base image**: `debian:bookworm`, the penultimate stable Debian release,
  used for every service to keep behavior and available packages consistent
  across containers.
- **PID 1 / foreground processes**: every container's entrypoint ends up
  executing its main daemon in the foreground (`nginx -g "daemon off;"`,
  `php-fpm -F`, `mariadbd`, `redis-server`, `vsftpd`, ...) so that it runs as
  PID 1 and receives signals directly. No `tail -f`, `sleep infinity` or
  similar hacks are used to keep a container alive.
- **Startup order**: WordPress waits for MariaDB to be reported healthy
  (`depends_on: condition: service_healthy`, backed by a MariaDB
  healthcheck) before running its own initialization, so the database is
  guaranteed to be ready before WordPress tries to configure itself.
- **No `latest` tag**: every image is built locally from an explicit
  Dockerfile and tagged with the service name, so there is no ambiguity
  about which version is running and no silent upgrade on rebuild.
- **Secrets never baked into images**: passwords are never written in a
  Dockerfile or committed to the repository; they are only injected at
  runtime through Docker secrets (see below).
- **static-website is a plain snapshot, not a converter**: `README.md`,
  `USER_DOC.md` and `DEV_DOC.md` were converted to HTML by hand once, and
  the resulting pages live directly under
  `srcs/requirements/bonus/static-website/tools/www/`. The container just
  serves those files as-is (Python's built-in `http.server`), with no
  Markdown parsing at build or run time. If the three `.md` files change,
  the HTML pages must be regenerated and committed again to stay in sync.

### Virtual Machines vs Docker

A virtual machine virtualizes an entire hardware stack and runs a full guest
kernel and OS, which gives strong isolation but costs more resources and
takes longer to start. Docker containers share the host kernel and only
isolate the userland (processes, filesystem, network) through Linux
namespaces and cgroups, which makes them much lighter and faster to start,
at the cost of slightly weaker isolation than a full VM. In this project the
two are complementary: the subject requires the whole exercise to be
performed inside a VM, and Docker is then used inside that VM to isolate
and orchestrate each service.

### Secrets vs Environment Variables

Environment variables (declared in `srcs/.env` and passed via `env_file`)
are convenient for non-sensitive configuration, but they are visible to
anyone who can run `docker inspect`, read `/proc/<pid>/environ` in the
container, or inspect the image history, and they can easily leak into
logs. Docker secrets are mounted as read-only files under `/run/secrets/`
inside the container, are never stored in the image layers, and are not
exposed through `docker inspect`. For this reason, `srcs/.env` only holds
non-sensitive values (domain name, database name, usernames, ...), while
every password (root DB password, WordPress DB user password, WordPress
admin/user passwords, FTP password, Portainer admin password) is stored as
a Docker secret, sourced from a dedicated file in `secrets/`, which is
excluded from version control.

### Docker Network vs Host Network

With `network: host`, a container shares the host's network stack directly,
which removes network isolation and lets any process in the container bind
any host port. A dedicated Docker network (`ft-network` here, a bridge
network declared in `docker-compose.yml`) instead gives each container its
own network namespace, isolates the containers from the host network, and
provides automatic DNS resolution between containers by service name (e.g.
WordPress reaches the database simply as `mariadb`). This is why the
subject forbids `network: host`/`--link` and requires an explicit network
block, which is used here to connect NGINX, WordPress, MariaDB and every
bonus service.

### Docker Volumes vs Bind Mounts

A bind mount maps an arbitrary path on the host filesystem directly into a
container, which ties the setup to the host's directory layout and gives
the container access to (and dependency on) that specific path. A named
volume is instead managed entirely by Docker: it has its own lifecycle,
independent of any particular host path, and is portable across machines
using the same Docker setup. This project uses two named volumes,
`mariadb` (the WordPress database files) and `wordpress` (the WordPress
website files), both configured with a local `driver_opts` bind so that
their data is physically stored under `/home/hdougoud/data` on the host,
which satisfies the subject's requirement of using named volumes rather
than bind mounts while still keeping the data at a known, predictable
location.

## Resources

- Docker documentation — https://docs.docker.com/
- Docker Compose file reference — https://docs.docker.com/reference/compose-file/
- Docker secrets — https://docs.docker.com/engine/swarm/secrets/
- NGINX documentation — https://nginx.org/en/docs/
- MariaDB server documentation — https://mariadb.com/kb/en/documentation/
- WordPress `wp-cli` — https://wp-cli.org/
- PHP-FPM configuration — https://www.php.net/manual/en/install.fpm.configuration.php
- Redis documentation — https://redis.io/docs/latest/
- Adminer — https://www.adminer.org/
- vsftpd documentation — https://security.appspot.com/vsftpd.html
- Portainer documentation — https://docs.portainer.io/

### Use of AI

AI was used as a writing and troubleshooting aid, not as a code generator.
It helped draft and structure the project documentation (this README), and
it was used to get explanations for specific, unusual error messages and
edge cases encountered while configuring the services (for example
understanding a particular Docker/NGINX/PHP-FPM/MariaDB error in context).
The Dockerfiles, the `docker-compose.yml` and the configuration/entrypoint
scripts were written by hand; every explanation obtained from AI was
verified against the official documentation before being applied.
