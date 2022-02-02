GITHUB_REF        ?= $(shell git symbolic-ref -q HEAD || git describe --tags --exact-match)
DOCKER_IMAGE_NAME ?= notify-telegram
DOCKER_IMAGE_TAG  ?= $(shell echo $(GITHUB_REF) | sed 's/refs\/heads\///g' | sed 's/refs\/tags\///g' | sed 's/\//-/g' | sed 's/_/-/g' | sed 's/master/latest/')

ifeq ($(DOCKER_REGISTRY_URL),)
	DOCKER_IMAGE := $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
else
	DOCKER_IMAGE := $(DOCKER_REGISTRY_URL)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
endif

PYTEST_ADDOPTS    ?= --maxfail=5 -sv --verbose --reuse-db
PYTEST_PATH       ?= tests

FAIL_COLOR := \033[31;01m
OK_COLOR   := \033[32;01m
NO_COLOR   := \033[0m

notify-telegram:
	@printf "$(OK_COLOR)==>$(NO_COLOR) Build app\n"
	@go build -v .
	@echo ""

build: notify-telegram
	@printf "$(OK_COLOR)==>$(NO_COLOR) Building $(DOCKER_IMAGE)\n"
	@docker build . --tag=$(DOCKER_IMAGE) --file=Dockerfile
	@echo ""
.PHONY: build

push:
	@printf "$(OK_COLOR)==>$(NO_COLOR) Pushing $(DOCKER_IMAGE)\n"
	@docker push $(DOCKER_IMAGE)
	@echo ""
.PHONY: push

clean:
	@printf "$(OK_COLOR)==>$(NO_COLOR) Cleanup $(DOCKER_IMAGE)\n"
	@docker rmi $(DOCKER_IMAGE) || :
	@echo ""
.PHONY: clean
