FROM debian:12
RUN apt-get update && apt-get install -y mariadb-server \
	&& mkdir -p /run/mysqld \
	&& chown mysql:mysql /run/mysqld \
	&& rm -rf /var/lib/apt/lists/*

COPY tools/entrypoint.sh /entrypoint.sh
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/60-inception.cnf
RUN chmod +x /entrypoint.sh

EXPOSE 3306
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql
ENTRYPOINT ["/entrypoint.sh"]
