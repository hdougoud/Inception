DOCKER_COMPOSE_DIR = srcs/docker-compose.yml

all: build up

build:
	docker compose -f $(DOCKER_COMPOSE_DIR) build

up:
	docker compose -f $(DOCKER_COMPOSE_DIR) up -d

down:
	docker compose -f $(DOCKER_COMPOSE_DIR) down


