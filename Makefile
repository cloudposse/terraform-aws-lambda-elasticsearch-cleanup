SHELL           := /bin/bash
LAMBDA_DIR      := lambda
DEPS_CONTAINER  := alpine:3.11

-include $(shell curl -sSL -o .build-harness "https://cloudposse.tools/build-harness"; echo .build-harness)

readme/build:
	@atmos docs generate readme

readme: 
	@atmos docs generate readme

define docker
docker run -i -v $(PWD)/$(LAMBDA_DIR)/:/code -w /code $(DEPS_CONTAINER) /bin/sh -c '$(1)'
endef

## Install dependencies
dependencies:
	@echo "==> Installing Lambda function dependencies..."
	@$(call docker, apk add --update py-pip && \
	  pip install virtualenv && \
	  virtualenv venv --always-copy && \
	  source ./venv/bin/activate && \
	  ./venv/bin/pip install -qUr requirements.txt)

## Build Lambda function zip
build: dependencies
	@echo "==> Building Lambda function zip..."
	@mkdir -p artifacts
	@cd $(LAMBDA_DIR) && zip -r  ../artifacts/lambda.zip *
	@ls -l artifacts/lambda.zip
