run:
	mkdocs serve --dev-addr=0.0.0.0:8000

build:
	mkdocs build

docker.up:
	COMPOSE_PROJECT_NAME=coneshare-docs docker-compose -f docker-compose.yaml up

docker.sh:
	COMPOSE_PROJECT_NAME=coneshare-docs docker-compose -f docker-compose.yaml exec app sh

