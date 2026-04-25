# Developer Documentation

## Layout

```
.
├── Makefile
├── secrets/                       # copied from home on make
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/   {Dockerfile, conf/my.cnf, tools/entrypoint.sh}
        ├── nginx/     {Dockerfile, conf/nginx.conf, tools/generate_cert.sh}
        └── wordpress/ {Dockerfile, conf/www.conf, tools/entrypoint.sh}
```

## Prerequisites

- A Linux VM with Docker Engine and Docker Compose v2 plugin
- `make`, `git`, `sudo`
- Host user `jgils` (the data directories and Makefile reference
  `/home/jgils/...`); update the Makefile, `docker-compose.yml`
  device paths, and `WP_HOST` in `.env` if cloning under another login
- `jgils.42.fr` mapped to `127.0.0.1` in `/etc/hosts`

## Configuration files

### `srcs/.env`

Non-sensitive configuration consumed by Compose and the entrypoint
scripts:

```
DB_NAME, DB_USER, DB_HOST, DB_PORT
WP_HOST, WP_TITLE
WP_ADMIN_USER, WP_ADMIN_EMAIL
WP_USER, WP_USER_EMAIL
```

`WP_ADMIN_USER` must not contain `admin` or `administrator` (subject rule).

### `secrets/`

Files mounted as Docker secrets at `/run/secrets/<name>` inside the
relevant containers:

| File                    | Used by             | Format                                 |
| ----------------------- | ------------------- | -------------------------------------- |
| `db_root_password.txt`  | mariadb             | raw password (`cat`-read)              |
| `db_password.txt`       | mariadb, wordpress  | raw password (`cat`-read)              |
| `credentials.txt`       | wordpress           | shell file (`. /run/secrets/credentials`) defining `WP_ADMIN_PASSWORD` and `WP_USER_PASSWORD` |

The folder is git-ignored. The Makefile runs `cp /home/jgils/secrets .`
before `docker compose up`, so the canonical copy must exist at
`/home/jgils/secrets/` on the host with the three files above.

## Building and launching

```bash
make        # mkdir data dirs, build images, docker compose up --build
make down   # docker compose down
make clean  # docker compose down --rmi all
make fclean # clean + sudo rm -rf /home/jgils/data/*
make re     # clean + all
```

The Makefile materialises the host data directories
(`/home/jgils/data/wordpress` and `/home/jgils/data/mariadb`) before
bringing the stack up — Compose's `local` driver with `o: bind` requires
them to exist.

## Managing containers and volumes

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f <service>
docker compose -f srcs/docker-compose.yml exec <service> sh

docker volume ls
docker volume inspect srcs_wordpress-data
docker network inspect srcs_inception
```

Useful one-offs:

```bash
# WP-CLI inside the wordpress container
docker exec -it wordpress wp --allow-root --path=/var/www/html plugin list

# MariaDB shell
docker exec -it mariadb mariadb -u root -p
```

## Where data lives

Two named volumes are declared in `docker-compose.yml` with the
`local`/`bind` driver, so they appear both as Docker-managed volumes
and as plain directories on the host:

| Volume            | Container path     | Host path                      |
| ----------------- | ------------------ | ------------------------------ |
| `wordpress-data`  | `/var/www/html`    | `/home/jgils/data/wordpress`   |
| `mariadb-data`    | `/var/lib/mysql`   | `/home/jgils/data/mariadb`     |

Persistence rules:

- `make down`, `make clean` and `make re` keep the host directories
  intact, so WordPress and MariaDB survive rebuilds.
- `make fclean` deletes `/home/jgils/data/*` — next `make` reinstalls
  WordPress and reinitialises the database from scratch.
- The NGINX container also mounts `wordpress-data` read-mostly to serve
  the WordPress files directly.

## Network

A single user-defined bridge network, `inception`, connects the three
services. Containers reach each other by container name (`mariadb`,
`wordpress`, `nginx`). Published host ports: `nginx` exposes `443`, and
`mariadb` currently also exposes `3306` (handy for local debugging; can
be dropped from `docker-compose.yml` for a stricter setup).

## Adding a service

1. Create `srcs/requirements/<name>/{Dockerfile, conf/, tools/}`.
2. Add a service block in `docker-compose.yml` with `build:`,
   `networks: [inception]`, `restart: on-failure`, and any volumes or
   secrets it needs.
3. Add new variables to `srcs/.env` (non-sensitive) or new files under
   `secrets/` wired through the top-level `secrets:` map (sensitive).
4. `make re` to rebuild from a clean slate.
