IMAGE_NAME := php-coverage
DOCKERFILE := tools/docker/php/Dockerfile.coverage
CODE_DIR := $(shell pwd)
CONTAINER_WORKDIR := /app

.PHONY: coverage

coverage:
	docker build -t $(IMAGE_NAME) -f $(DOCKERFILE) . && \
	docker run --rm \
		-v $(CODE_DIR):$(CONTAINER_WORKDIR) \
		-w $(CONTAINER_WORKDIR) \
		-e XDEBUG_MODE=coverage \
		$(IMAGE_NAME) \
		bash -c "php artisan test --coverage"

dev:
	docker compose -f docker-compose.dev.yml up --build -dd

lint:
	./vendor/bin/phpstan analyse --memory-limit=512M

up:
	docker compose -f .\docker-compose.dev.yml up -d
