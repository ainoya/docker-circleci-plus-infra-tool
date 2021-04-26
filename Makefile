IMAGE_NAME = ainoya/circleci-infra-tools
DOCKER_TAG :=$(shell git describe --tags --dirty | sed -e 's/^v//')

build:
	docker build -t $(IMAGE_NAME) .
	docker tag $(IMAGE_NAME):latest $(IMAGE_NAME):${DOCKER_TAG}
	docker tag $(IMAGE_NAME):latest ghcr.io/$(IMAGE_NAME):${DOCKER_TAG}
run:
	docker run -it --rm ainoya/circleci-infra-tools bash
push_ghcr:
	docker push ghcr.io/$(IMAGE_NAME):${DOCKER_TAG}
push: push_ghcr
	docker push $(IMAGE_NAME):${DOCKER_TAG}
	docker push ghcr.io/$(IMAGE_NAME):${DOCKER_TAG}
push_dev: build
	docker tag $(IMAGE_NAME):latest $(IMAGE_NAME):dev
	docker push $(IMAGE_NAME):dev
show_latest_tag:
	git describe --tags $(shell git rev-list --tags --max-count=1)
update_minor_version:
	npm version minor
