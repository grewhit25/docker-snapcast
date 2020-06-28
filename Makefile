install:
	mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
	curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx

prepare: install
	docker buildx create --use

prepare-old: install
	docker context create old-style
	docker buildx create old-style --use

build-push:
	docker buildx build --push \
		--build-arg CI_NAME=${CI_NAME} \
		--platform ${DOCKER_PLATFORMS} \
		-t ${IMAGE_NAME}:${VERSION} \
		-f ${DOCKERFILE} .

build-manifest:
	$(call create-push-manifest)

define create-push-manifest
	echo "Create manifest and push image"
  MANIFESTS=""
  for arch in ${BUILD_ARCH}; do MANIFESTS="${MANIFESTS} ${DOCKER_BASE}:${arch}"; done
  docker manifest create --amend ${DOCKER_BASE} ${MANIFESTS};
  for arch in ${BUILD_ARCH}; do
    if [ ${arch} == "arm" ]; then
      ARCH="arm --variant v7"
		elif [ ${arch} == "arm64" ]; then
      ARCH="arm64 --variant v8"
    else
      ARCH="${arch}"
    fi
  docker manifest annotate ${DOCKER_BASE} ${DOCKER_BASE}:${arch} \
    --os 'linux' --arch ${ARCH}
  done
  docker manifest push ${DOCKER_BASE}
endef
