SHELL := /bin/bash

DOCKER_COMPOSE ?= docker compose
SERVICE ?= api
PROJECT_DIR ?= $(CURDIR)

ITEMTYPE_MODEL_PATH ?= artifacts/models/model_itemtype.pt
ITEMTYPE_CLASSES_PATH ?= artifacts/encoders/itemtype_classes.pkl
CSV_PATH ?= data/processed/deepfashion_parsed.csv
IMAGE_PATH ?= image.jpg
DATASET_ROOT ?= dataset/deepfashion

DOCKER_RUN = $(DOCKER_COMPOSE) run --rm --build -v $(PROJECT_DIR):/app $(SERVICE)

.PHONY: help install build api train-itemtype parse-deepfashion predict-itemtype predict-full docker-up docker-down docker-logs shell check clean

help:
	@echo "Available targets (Docker only):"
	@echo "  make install            Build Docker image (dependencies included)"
	@echo "  make build              Build Docker image"
	@echo "  make api                Run API via docker compose (foreground)"
	@echo "  make train-itemtype     Train itemtype model in container"
	@echo "  make parse-deepfashion  Build deepfashion CSV in container"
	@echo "  make predict-itemtype   Run itemtype inference in container"
	@echo "  make predict-full       Run full inference in container"
	@echo "  make shell              Open bash shell in container"
	@echo "  make docker-up          Start docker compose stack"
	@echo "  make docker-down        Stop docker compose stack"
	@echo "  make docker-logs        Follow docker logs"
	@echo "  make check              Python compile check in container"
	@echo "  make clean              Remove python cache files in container"

install: build

build:
	$(DOCKER_COMPOSE) build $(SERVICE)

api:
	$(DOCKER_COMPOSE) up --build $(SERVICE)

train-itemtype:
	$(DOCKER_RUN) env CSV_PATH=$(CSV_PATH) MODEL_PATH=$(ITEMTYPE_MODEL_PATH) ENCODER_PATH=$(ITEMTYPE_CLASSES_PATH) \
		python scripts/train/train_itemtype.py

parse-deepfashion:
	$(DOCKER_RUN) python scripts/data/parse_deepfashion.py --dataset-root $(DATASET_ROOT) --out $(CSV_PATH)

predict-itemtype:
	$(DOCKER_RUN) env MODEL_PATH=$(ITEMTYPE_MODEL_PATH) CLASSES_PATH=$(ITEMTYPE_CLASSES_PATH) IMAGE_PATH=$(IMAGE_PATH) \
		python scripts/inference/predict_itemtype.py

predict-full:
	$(DOCKER_RUN) env MODEL_PATH=$(ITEMTYPE_MODEL_PATH) CLASSES_PATH=$(ITEMTYPE_CLASSES_PATH) IMAGE_PATH=$(IMAGE_PATH) \
		python scripts/inference/predict_full.py

shell:
	$(DOCKER_RUN) bash

docker-up:
	$(DOCKER_COMPOSE) up --build

docker-down:
	$(DOCKER_COMPOSE) down

docker-logs:
	$(DOCKER_COMPOSE) logs -f $(SERVICE)

check:
	$(DOCKER_RUN) python -m compileall app scripts

clean:
	$(DOCKER_RUN) find . -type d -name '__pycache__' -prune -exec rm -rf {} +
	$(DOCKER_RUN) find . -type f -name '*.pyc' -delete
