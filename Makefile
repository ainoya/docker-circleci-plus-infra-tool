IMAGE_NAME = ainoya/circleci-infra-tools
DOCKER_TAG :=$(shell git describe --tags --dirty | sed -e 's/^v//')

build:
	docker build -t $(IMAGE_NAME) .
	docker tag $(IMAGE_NAME):latest $(IMAGE_NAME):${DOCKER_TAG}
run:
	docker run -it --rm ainoya/circleci-infra-tools bash
push:
	docker push $(IMAGE_NAME):${DOCKER_TAG}
push_dev: build
	docker tag $(IMAGE_NAME):latest $(IMAGE_NAME):dev
	docker push $(IMAGE_NAME):dev
show_latest_tag:
	git describe --tags $(shell git rev-list --tags --max-count=1)
