COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	mkdir -p /home/jgils/data/wordpress /home/jgils/data/mariadb
	$(COMPOSE) up --build

down:
	$(COMPOSE) down

re: clean all

clean:
	$(COMPOSE) down --rmi all

fclean:
	$(COMPOSE) down --rmi all --volumes
	sudo rm -rf /home/jgils/data/*

.PHONY: all down re clean fclean
