#!/usr/bin/make -f

#-------------------------------------------------------------------------------
# Docker variables
#-------------------------------------------------------------------------------
DOCKER_USERNAME=fbarmes
DOCKER_IMAGE_NAME=ansible-tf-toolset
DOCKER_IMAGE_VERSION=$(shell cat VERSION)

DOCKER_TAGNAME_VERSION=${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}
DOCKER_TAGNAME_LATEST=${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:latest

#-------------------------------------------------------------------------------
# echo
#-------------------------------------------------------------------------------
.PHONY: echo
echo:
	@echo "-- Image coordinates"
	@echo DOCKER_TAGNAME_VERSION=[${DOCKER_TAGNAME_VERSION}]
	@echo VERSION=[${DOCKER_IMAGE_VERSION}]
	#
	@echo "-- Image tags"
	@echo DOCKER_TAGNAME_VERSION=${DOCKER_TAGNAME_VERSION}
	@echo DOCKER_TAGNAME_LATEST=${DOCKER_TAGNAME_LATEST}
	#
	@echo "-- Registry Credentials"
	@echo DOCKER_USERNAME=[${DOCKER_USERNAME}]
	@echo DOCKER_PASSWORD=[${DOCKER_PASSWORD}]


#-------------------------------------------------------------------------------
# Build
#-------------------------------------------------------------------------------
.PHONY: build
build:
	#-- build image
	docker build \
		-t ${DOCKER_TAGNAME_VERSION} \
		-f Dockerfile \
		.

.PHONY: tag-latest
tag-latest:
	docker tag ${DOCKER_TAGNAME_VERSION} ${DOCKER_TAGNAME_LATEST}

#-------------------------------------------------------------------------------
# Docker publish
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
.PHONY: docker-login
docker-login:
	docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)


#-------------------------------------------------------------------------------
.PHONY: docker-push
docker-push:
	docker push ${DOCKER_TAGNAME_VERSION}
	#

#-------------------------------------------------------------------------------
.PHONY: docker-push-latest
docker-push-latest: docker-push
	#
	docker tag ${DOCKER_TAGNAME_VERSION} ${DOCKER_TAGNAME_LATEST}
	#
	docker push ${DOCKER_TAGNAME_LATEST}
	#

#-------------------------------------------------------------------------------
# pull
#-------------------------------------------------------------------------------
.PHONY: pull
pull:
	docker pull ${DOCKER_REGISTRY}${DOCKER_TAGNAME_VERSION}


#-------------------------------------------------------------------------------
.PHONY: run
run:
	docker run \
		-it --rm \
		--name "k8s-toolset" \
		-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
		-v ${PWD}/workdir/:/workdir \
		-e DOCKER_USER_ID=$(shell id -u) \
	  -e DOCKER_GROUP_ID=$(shell id -g) \
		${DOCKER_TAGNAME_VERSION}
