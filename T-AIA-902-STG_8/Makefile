IMAGE_NAME  := taxi_rl
WORKDIR     := /app
HOST_DIR    := $(PWD)
BENCHMARK   := docker run --rm -it -e PYTHONPATH=$(WORKDIR)/app -v $(HOST_DIR):$(WORKDIR) -w $(WORKDIR)/app $(IMAGE_NAME) python -m benchmark.benchmark

.PHONY: docker-build docker-run docker-shell dev benchmark-quick benchmark-final benchmark-final-dqn help

## Build the Docker image
docker-build:
	docker build -t $(IMAGE_NAME) .

## Run the container (interactive)
docker-run:
	docker run --rm -it $(IMAGE_NAME)

## Open a shell inside the container
docker-shell:
	docker run --rm -it $(IMAGE_NAME) /bin/sh

## Build then run with live code reload (volume mount)
dev: docker-build
	docker run --rm -it \
		-v $(HOST_DIR):$(WORKDIR) \
		$(IMAGE_NAME)

## Run the quick benchmark in Docker
benchmark-quick: docker-build
	$(BENCHMARK) --profile quick

## Run the final benchmark in Docker
benchmark-final: docker-build
	$(BENCHMARK) --profile final

## Run the final benchmark with DQN included
benchmark-final-dqn: docker-build
	$(BENCHMARK) --profile final --include-dqn

## Show available targets
help:
	@grep -E '^##' Makefile | sed 's/## //'
