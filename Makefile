build:
	docker build -t ainoya/circleci-infra-tools .
push::
	docker push ainoya/circleci-infra-tools:latest
run:
	docker run -it --rm ainoya/circleci-infra-tools bash
