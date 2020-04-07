IMAGE_NAME = ainoya/circleci-infra-tools

build:
	docker build -t $(IMAGE_NAME) .
run:
	docker run -it --rm ainoya/circleci-infra-tools bash
push: build
	$(eval DOCKER_TAG :=$(shell git --no-pager tag --points-at HEAD | sed -e 's/^v//'))
	docker tag $(IMAGE_NAME):latest $(IMAGE_NAME):${DOCKER_TAG}
	docker push $(IMAGE_NAME):${DOCKER_TAG}
