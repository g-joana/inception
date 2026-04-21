COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	$(COMPOSE) up --build

down:
	$(COMPOSE) down

re: clean all

clean:
	$(COMPOSE) down --rmi all

fclean:
	$(COMPOSE) down --rmi all --volumes

.PHONY: all down re clean fclean