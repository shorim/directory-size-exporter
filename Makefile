
APP_NAME = directory-size-exporter
APP_PATH = components/$(APP_NAME)

PROJECT_DIR := $(shell pwd)
OS := $(shell uname)


# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifneq (,$(shell which go))
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif
endif

# Setting SHELL to bash allows bash commands to be executed by recipes.
# This is a requirement for 'setup-envtest.sh' in the test target.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: fmt
fmt: ## Run go fmt against code.
	go fmt ./...

.PHONY: vet
vet: ## Run go vet against code.
	go vet ./...

.PHONY: tidy
tidy: ## Check if there any dirty change for go mod tidy.
	go mod tidy
	git diff --exit-code go.mod
	git diff --exit-code go.sum

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

resolve:
	GO111MODULE=on go mod vendor -v

ensure:
	@echo "Go modules present in component - omitting."

dep-status:
	@echo "Go modules present in component - omitting."

mod-verify:
	GO111MODULE=on go mod verify

 ## Run tests.
test: fmt vet tidy
	go test ./... -coverprofile cover.out

build: fmt vet tidy ## Build manager binary.
	go build -o bin/manager main.go

lint: ## Run various linters
	go version
	golangci-lint version
	GO111MODULE=on golangci-lint run

run: fmt vet tidy ## Run a controller from your host.
	go run ./main.go




##@ Dynamic Function Build
$(eval $(call buildpack-cp-ro,resolve))
$(eval $(call buildpack-mount,mod-verify))
$(eval $(call buildpack-mount,test))
