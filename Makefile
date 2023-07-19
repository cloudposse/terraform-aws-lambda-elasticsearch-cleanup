SHELL           := /bin/bash
LAMBDA_DIR      := lambda
DEPS_CONTAINER  := alpine:3.11

# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md docs/terraform.md

-include $(shell curl -sSL -o .build-harness "https://cloudposse.tools/build-harness"; echo .build-harness)

## Lint terraform code
lint:
	$(SELF) terraform/install terraform/get-modules terraform/get-plugins terraform/lint terraform/validate

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

## Run tests
terratest::
	# This project runs `git` externally, so it needs extra permissions when run by a GitHub Action
	[[ -n "$$GITHUB_WORKSPACE" ]] && git config --global --add safe.directory "$$GITHUB_WORKSPACE" || true
