# travis-ci

install:
	mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
	curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx

prepare: install
	# docker buildx create --use
	# Instantiate docker buildx builder with multi-architecture support.
	docker buildx create --name mybuilder
	docker buildx use mybuilder
	# Start up buildx and verify that all is OK.
	docker buildx inspect --bootstrap

prepare-old: install
	docker context create old-style
	docker buildx create old-style --use

build-push:
	docker buildx build --push \
		--build-arg CI_NAME=${CI_NAME} \
		--platform ${DOCKER_PLATFORMS} \
		-t ${IMAGE_NAME}:${VERSION} \
		-f ${DOCKERFILE} .

