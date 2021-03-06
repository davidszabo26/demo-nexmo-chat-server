.PHONY: docker
docker: build_docker

IMAGENAME=virgil-demo-nexmo-server
DOCKER_REGISTRY=virgilsecurity-docker-core.bintray.io

define tag_docker
  @if [ "$(GIT_TAG)" != "" ]; then \
    docker tag $(IMAGENAME) $(DOCKER_REGISTRY)/services/$(IMAGENAME):$(GIT_TAG); \
    docker tag $(IMAGENAME) $(DOCKER_REGISTRY)/services/$(IMAGENAME):latest; \
  else \
    docker tag $(IMAGENAME) $(DOCKER_REGISTRY)/services-dev/$(IMAGENAME):$(GIT_BRANCH); \
  fi
endef

define push_docker
  @if [ "$(GIT_TAG)" != "" ]; then \
    docker push $(DOCKER_REGISTRY)/services/$(IMAGENAME):$(GIT_TAG); \
  else \
    docker push $(DOCKER_REGISTRY)/services-dev/$(IMAGENAME):$(GIT_BRANCH); \
  fi
endef

build_docker:
	docker build -t $(IMAGENAME) --build-arg git_commit=$(GIT_COMMIT) .

docker_registry_tag:
	$(call tag_docker)

docker_registry_push:
	$(call push_docker)

docker_inspect:
	docker inspect -f '{{index .ContainerConfig.Labels "git-commit"}}' $(IMAGENAME)
	docker inspect -f '{{index .ContainerConfig.Labels "git-branch"}}' $(IMAGENAME)

clean_docker_registry:
	@echo ">>> Cleaning Bintray registry"
	docker run --rm -e "REGISTRY_USERNAME=${REGISTRY_USERNAME}" -e "REGISTRY_PASSWORD=${REGISTRY_PASSWORD}" \
	virgilsecurity-docker-core.bintray.io/utils/bintraymgr:latest \
	clean -t 10 core services-dev/$(IMAGENAME)

	docker run --rm -e "REGISTRY_USERNAME=${REGISTRY_USERNAME}" -e "REGISTRY_PASSWORD=${REGISTRY_PASSWORD}" \
	virgilsecurity-docker-core.bintray.io/utils/bintraymgr:latest \
	clean -t 10 core services/$(IMAGENAME)
