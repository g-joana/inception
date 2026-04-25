*This project has been created as part of the 42 curriculum by jgils.*

# Inception

## Description

Inception is a system administration exercise that builds a small web
infrastructure using Docker. Each service runs in its own container, built
from a custom Dockerfile based on Debian, and is wired together with
Docker Compose:

- **NGINX** — TLSv1.3 reverse proxy, the only entrypoint (port 443)
- **WordPress + php-fpm** — application server
- **MariaDB** — database

Two named Docker volumes persist the WordPress files and the database under
`/home/jgils/data`. A dedicated Docker network connects the containers, and
the domain `jgils.42.fr` resolves to the local machine.

## Instructions

Prerequisites: Docker, Docker Compose, `make`, and `jgils.42.fr` mapped to
`127.0.0.1` in `/etc/hosts`.

```bash
make        # build images and start the stack
make clean  # stop and remove images
make fclean # stop, remove images and wipe persistent data
make re     # clean rebuild
```

The site is then available at `https://jgils.42.fr`.

Secrets (`db_password.txt`, `db_root_password.txt`, `credentials.txt`) live
in a `secrets/` folder outside the repository and are mounted via Docker
secrets. Non-sensitive configuration sits in `srcs/.env`.

## Project description

The stack is split into one image per service, each built from the
penultimate stable Debian. NGINX terminates TLS and proxies PHP requests
to WordPress over the internal Docker network; WordPress talks to MariaDB
on the same network. Persistent state lives in named volumes bound to
`/home/jgils/data` on the host. Containers use `restart: on-failure` and run a
real foreground process as PID 1.

### Virtual Machines vs Docker

A VM virtualizes a full guest OS on top of a hypervisor; a Docker container
shares the host kernel and isolates a single process tree with namespaces
and cgroups. Containers boot in seconds and use a fraction of the
resources, which is why this stack runs as containers inside a single VM
rather than as several VMs.

### Secrets vs Environment Variables

Environment variables are convenient but end up visible in `docker inspect`,
process listings and image layers; fine for non-sensitive config (domain
name, usernames, hostnames). Docker secrets are mounted as files in
`/run/secrets/`, never written to the image, and not exposed via `inspect`,
so passwords and keys go there.

### Docker Network vs Host Network

With a user-defined Docker network, containers get their own IPs, resolve
each other by service name and are isolated from the host's interfaces.
Using `network: host` would drop that isolation and share the host's stack
directly, faster, but it breaks port boundaries between services and the
host, and the subject forbids it.

### Docker Volumes vs Bind Mounts

A bind mount maps an arbitrary host path into the container; a named volume
is managed by Docker, has a stable name, and is portable across hosts.
Named volumes are used here for the WordPress files and the database so
the data survives container rebuilds and stays decoupled from the host
filesystem layout.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [NGINX TLS configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [WordPress installation](https://wordpress.org/documentation/article/how-to-install-wordpress/)
- [MariaDB documentation](https://mariadb.org/documentation/)

### AI usage

AI assistants were used as a documentation lookup tool: clarifying Dockerfile syntax, php-fpm configuration options and `wp-cli` flags and to help understanding problems found along the way. Also to review and format README and docs.
