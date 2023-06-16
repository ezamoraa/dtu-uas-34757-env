.PHONY: image publish

DOCKER_IMAGE=ezamoraa/dtu_uas_34757
VERSION?=$(shell cat version)
REGISTRY=docker.io

image:
	docker build . -t ${DOCKER_IMAGE}:$(VERSION)
	docker tag ${DOCKER_IMAGE}:$(VERSION) ${DOCKER_IMAGE}:latest

publish: image
	docker tag ${DOCKER_IMAGE}:$(VERSION) ${REGISTRY}/${DOCKER_IMAGE}:$(VERSION)
	docker push ${REGISTRY}/${DOCKER_IMAGE}:$(VERSION)
