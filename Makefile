COMPOSE_FILE = srcs/docker-compose.yml

all: up

build:
	docker compose -f $(COMPOSE_FILE) build

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) down --rmi all

fclean:
	docker compose -f $(COMPOSE_FILE) down --rmi all --volumes --remove-orphans

re: fclean build up

.PHONY: all build up down clean fclean re

