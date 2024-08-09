DATE := $(shell date +%Y-%m-%d)

.PHONY: help build-and-push-images connect delete-all-users delete-user list-users create-user

# Affiche la liste des commandes disponibles si "make" est exécuté sans arguments
help:
	@echo "Usage: make <command> [args]"
	@echo
	@echo "Commands:"
	@echo "  create-user <username> <dir>     - Creates a user with specified username and home directory (should start with a /)."
	@echo "  list-users                       - List all currently configured users."
	@echo "  delete-user <username>           - Delete the specified user."
	@echo "  delete-all-users                 - Delete all currently configured users."
	@echo "  connect                          - Connect to the container."
	@echo "  build-and-push-images <version>  - Build image and push images on docker hub."
	@echo "  help                             - Displays this help message."

build-and-push-images:
	@if [ -z "$(word 2, $(MAKECMDGOALS))" ]; then \
		echo "Error: version is not provided. Usage: make build-and-push-images <version>"; \
		exit 1; \
	fi
	@version=$(word 2, $(MAKECMDGOALS)); \
	sed -i "s/^LABEL version=\"[^\"]*\"/LABEL version=\"$$version\"/" Dockerfile; \
	sed -i "s/^LABEL date=\"[^\"]*\"/LABEL date=\"$(DATE)\"/" Dockerfile; \
	docker login --username librasoftfr && \
	docker build --file ./Dockerfile -t proftpd-sftp:$$version . && \
	docker tag proftpd-sftp:$$version librasoftfr/proftpd-sftp:$$version && \
    docker tag proftpd-sftp:$$version librasoftfr/proftpd-sftp:latest && \
	docker push librasoftfr/proftpd-sftp:latest && \
	docker push librasoftfr/proftpd-sftp:$$version && \
	echo "done";

connect:
	@docker exec -ti sftp sh;

delete-all-users:
	@docker exec -ti sftp sh -c "rm /etc/proftpd/sftp/ftppasswd && touch /etc/proftpd/sftp/ftppasswd && chmod 0600 /etc/proftpd/sftp/ftppasswd";

delete-user:
	@if [ -z "$(word 2, $(MAKECMDGOALS))" ]; then \
		echo "Error: username is not provided. Usage: make create-user <username> <dir>"; \
		exit 1; \
	fi
	@username=$(word 2, $(MAKECMDGOALS)); \
	if docker exec sftp sh -c "ftpasswd --passwd --file=/etc/proftpd/sftp/ftppasswd --delete-user --name $$username"; then \
		echo ""; \
	fi

list-users:
	@docker exec -ti sftp cat /etc/proftpd/sftp/ftppasswd;

create-user:
	@if [ -z "$(word 2, $(MAKECMDGOALS))" ]; then \
		echo "Error: username is not provided. Usage: make create-user <username> <dir>"; \
		exit 1; \
	fi
	@if [ -z "$(word 3, $(MAKECMDGOALS))" ]; then \
		echo "Error: directory is not provided. Usage: make create-user <username> <dir>"; \
		exit 1; \
	fi
	@username=$(word 2, $(MAKECMDGOALS)); \
	dir=$(word 3, $(MAKECMDGOALS)); [ "${dir:0:1}" != "/" ] && dir="/$$dir"; \
	docker exec -ti sftp sh -c "mkdir -p /data$$dir && chown 1000:1000 /data$$dir && ftpasswd --passwd --file=/etc/proftpd/sftp/ftppasswd --name $$username --uid=1000 --gid=1000 --home=/data$$dir --shell=/sbin/nologin"

%:
	@:

.DEFAULT_GOAL := help
