FROM debian:12

RUN apt-get update && apt-get install -y mariadb-server \
	&& mkdir -p /run/mysqld \
	&& chown mysql:mysql /run/mysqld

EXPOSE 3306

CMD ["mysqld", "--user=root", "--bind-address=0.0.0.0"]
