# User Documentation

## What this stack provides

Three services running in dedicated Docker containers, exposed as a single
HTTPS website:

- **NGINX** — TLSv1.3 entrypoint on port `443`
- **WordPress + php-fpm** — the website itself
- **MariaDB** — the database backing WordPress

Persistent data lives on the host under `/home/jgils/data/wordpress` and
`/home/jgils/data/mariadb`.

## Starting and stopping

From the project root:

```bash
make        # build images and start the stack
make down   # stop the containers
make clean  # stop and remove the images
make fclean # stop, remove images and wipe persistent data
make re     # full clean rebuild
```

The first `make` may take a few minutes while images are built.

## Accessing the site

Make sure `jgils.42.fr` resolves to the host running Docker (add it to
`/etc/hosts` if needed):

```
127.0.0.1   jgils.42.fr
```

- Website: <https://jgils.42.fr>
- Admin panel: <https://jgils.42.fr/wp-admin>

The site uses a self-signed certificate, so the browser will show a
security warning the first time — accept it to continue.

## Credentials

Credentials are **not** stored in the repository. They live in a
`secrets/` folder kept outside the repo (in this setup, copied from
`/home/jgils/secrets` into the project root by the Makefile on each
`make`):

- `secrets/db_root_password.txt` — MariaDB root password
- `secrets/db_password.txt` — password of the WordPress database user
- `secrets/credentials.txt` — shell-sourced file exporting
  `WP_ADMIN_PASSWORD` and `WP_USER_PASSWORD`

Non-sensitive identifiers (database name, usernames, admin email, site
title, domain) are defined in `srcs/.env`.

To rotate a password, edit the matching file in `/home/jgils/secrets`
and run `make re`. Two WordPress accounts are created on first boot:
an administrator (`WP_ADMIN_USER` in `.env`) and a regular editor user
(`WP_USER`).

## Checking that everything is running

```bash
docker ps                     # all three containers should be Up
docker logs nginx             # TLS / proxy logs
docker logs wordpress         # php-fpm + wp-cli setup logs
docker logs mariadb           # database startup logs
curl -kI https://jgils.42.fr  # should return HTTP/1.1 200 OK
```

If a container is missing or restarting, inspect its logs first — the
most common causes are an empty `secrets/` file or a stale data volume
left over from a previous run (fixed by `make fclean && make`).
