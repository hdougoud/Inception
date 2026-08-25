# User documentation

This document is for anyone who wants to **use or administer** the Inception
stack once it is deployed — it does not require any Docker or development
knowledge. If you want to build the project or modify its configuration,
see `DEV_DOC.md` instead.

## 1. What this stack provides

Starting the project brings up several independent services, all reachable
through a single web address, `https://hdougoud.42.fr`:

| Service | What it's for | How you reach it |
|---|---|---|
| Website (WordPress) | The public website | `https://hdougoud.42.fr` |
| WordPress admin panel | Manage pages, posts, users, plugins | `https://hdougoud.42.fr/wp-admin` |
| Adminer | Web page to inspect/edit the database directly | `https://hdougoud.42.fr/adminer` |
| Portainer | Web page to see and manage all the running containers | `https://<machine-ip-or-domain>:9443` |
| FTP server | Upload/download the WordPress site files | connect with any FTP client on port `21` |
| Redis | Speeds up the website (page/object cache) | internal only, nothing to open |

Behind the scenes, the website is served by NGINX, the WordPress
application runs in its own container, and its data lives in a MariaDB
database — but as a user you never need to talk to those directly.

## 2. Starting and stopping the project

All commands below are run from the root of the repository (where the
`Makefile` is), on the machine hosting the project.

**First time only:**

```bash
make          # add the domain to /etc/hosts, generate the passwords, build and start everything
```

This first run will ask for your `sudo` password once (to register the
`hdougoud.42.fr` domain locally) and creates the password files used by
every service — nothing needs to be prepared by hand beforehand.

**Every other time**, start and stop the stack without touching the domain
entry or the passwords again:

```bash
make up       # start every service
make down     # stop every service, keep all data
make clean    # stop every service and remove the built images
make fclean   # stop everything and also delete the stored data (volumes)
make re       # fclean + rebuild + start again (fresh install, keeps existing passwords)
```

> ⚠️ Don't run plain `make` (or `make all`) again after the first
> successful start: it would generate brand new random passwords and
> overwrite the ones already in use inside WordPress/MariaDB, locking you
> out. If you really want to reset everything including the passwords, you
> need to also wipe the current WordPress/database data (`make fclean`)
> before running `make` again.

Give the services a few seconds to initialize on first start (the database
and the website are being set up automatically). Once it's up, the site
stays available until you run `make down`, `make clean`, or `make fclean`,
or until the machine reboots — the containers are configured to restart
automatically if one of them crashes.

## 3. Accessing the website and the administration panel

- **Public website**: open `https://hdougoud.42.fr` in a browser.
  The connection uses a self-signed certificate, so the browser will show a
  security warning the first time — this is expected, you can proceed.
- **WordPress admin panel**: go to `https://hdougoud.42.fr/wp-admin` and log
  in with the administrator account (see below for how to set its
  password). From there you can write posts, manage plugins, and configure
  the site like any WordPress install.
- **Database viewer (Adminer)**: go to `https://hdougoud.42.fr/adminer` to
  browse the WordPress database. Use the database credentials described
  below.
- **Container manager (Portainer)**: go to `https://<host>:9443` to see the
  status of every container, view their logs, and restart them from a web
  UI. Log in with the Portainer admin password (see below).
- **FTP access**: connect any FTP client to the machine's address on port
  `21`, using the FTP account described below, to browse and edit the
  WordPress website files directly.

There are two WordPress accounts created automatically:

| Role | Username (env var) | Purpose |
|---|---|---|
| Administrator | `WP_ADMIN_USER` (see `srcs/.env`) | Full control of the site |
| Author | `WP_USER` (see `srcs/.env`) | Can write/edit its own content only |

## 4. Locating and managing credentials

No password is ever written in plain text in the project's configuration
files or committed to Git, and none of them exist in a fresh copy of the
repository — they are generated automatically the first time you run
`make` (see [Starting and stopping the project](#2-starting-and-stopping-the-project)).
Credentials live in two places:

- **`srcs/.env`** — non-sensitive settings only: domain name, database
  name, usernames, site title, email addresses. Safe to read, contains no
  passwords.
- **`secrets/` folder** — one plain-text file per password, created by
  `make` with a random value and mounted read-only inside the container
  that needs it:

  | File | Password for |
  |---|---|
  | `secrets/wp_admin_password.txt` | WordPress administrator account |
  | `secrets/wordpress_user_password.txt` | WordPress author account |
  | `secrets/user_db_password.txt` | Database user (`DB_USER`) |
  | `secrets/db_root_password.txt` | Database root account |
  | `secrets/ftp_password.txt` | FTP account (`FTP_USER`) |
  | `secrets/portainer_admin_password.txt` | Portainer admin account |

To find or change a credential:

1. Open the corresponding file in `secrets/` on the host machine to read
   the current password (it is created there automatically by `make` on
   first run — you don't need to create it yourself).
2. To change one, edit the file's content, then recreate the affected
   container(s) with `make down && make up` (a plain restart is not
   enough, since some passwords are only applied the very first time a
   service initializes its data). Do **not** use plain `make`/`make all`
   for this, as it would regenerate every other password too.

The `secrets/` folder is excluded from Git (only a placeholder file is
versioned), so these passwords never end up in the project's history.

## 5. Checking that the services are running correctly

From the host machine, in the project's root directory:

```bash
docker compose -f srcs/docker-compose.yml ps
```

This lists every service with its current status. A healthy stack shows
all containers as `Up` (MariaDB additionally shows `healthy` once its
startup check has passed).

To look at what a specific service is doing or to diagnose a problem, read
its logs:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

(replace the service name with `redis`, `adminer`, `vsftpd`, or `portainer`
for the bonus services). You can also open Portainer
(`https://<host>:9443`) to see the same status and logs from a web
interface instead of the command line.

If the website itself is unreachable, first confirm the domain resolves to
the right machine (e.g. `ping hdougoud.42.fr`), then check that the
`nginx` container is `Up` with the command above.
