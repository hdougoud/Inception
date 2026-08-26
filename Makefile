COMPOSE_FILE	= srcs/docker-compose.yml
SECRETS_DIR		= secrets
HOSTNAME 			= hdougoud.42.fr
VOLUMES_DIR 	= /home/hdougoud/data

all: host directory secrets up

host:
	@if ! grep -qE "127.0.0.1 $(HOSTNAME)" /etc/hosts; then \
		echo "add 127.0.0.1 $(HOSTNAME) to /etc/hosts"; \
		echo "127.0.0.1 $(HOSTNAME)" | sudo tee -a /etc/hosts > /dev/null; \
	fi

directory:
	@mkdir -p $(VOLUMES_DIR)/wordpress
	@mkdir -p $(VOLUMES_DIR)/mariadb
	@mkdir -p $(VOLUMES_DIR)/portainer

secrets:
	@openssl rand -base64 32 | tr -dc 'A-Za-z0-9@%^*_+=-' | head -c 16 > $(SECRETS_DIR)/db_root_password.txt
	@openssl rand -base64 32 | tr -dc 'A-Za-z0-9@%^*_+=-' | head -c 16 > $(SECRETS_DIR)/ftp_password.txt
	@openssl rand -base64 32 | tr -dc 'A-Za-z0-9@%^*_+=-' | head -c 16 > $(SECRETS_DIR)/portainer_admin_password.txt
	@openssl rand -base64 32 | tr -dc 'A-Za-z0-9@%^*_+=-' | head -c 16 > $(SECRETS_DIR)/user_db_password.txt
	@openssl rand -base64 32 | tr -dc 'A-Za-z0-9@%^*_+=-' | head -c 16 > $(SECRETS_DIR)/wordpress_user_password.txt
	@openssl rand -base64 32 | tr -dc 'A-Za-z0-9@%^*_+=-' | head -c 16 > $(SECRETS_DIR)/wp_admin_password.txt

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

.PHONY: host secrets directory all build up down clean fclean re
