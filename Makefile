COMPOSE_CMD ?= COMPOSE_PROJECT_NAME=coneshare-docs docker-compose -f docker-compose.yaml

.PHONY: run
run:
	$(COMPOSE_CMD) up -d app
	$(COMPOSE_CMD) exec app mkdocs serve --dev-addr=0.0.0.0:8000

.PHONY: build
build:
	$(COMPOSE_CMD) up -d app
	$(COMPOSE_CMD) exec -T app mkdocs build

.PHONY: docker.up
docker.up:
	$(COMPOSE_CMD) up -d

.PHONY: docker.down
docker.down:
	$(COMPOSE_CMD) down

.PHONY: docker.sh
docker.sh:
	$(COMPOSE_CMD) exec app sh

