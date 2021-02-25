isDocker := $(shell docker info > /dev/null 2>&1 && echo 1)

.DEFAULT_GOAL := help
STACK         := webcrawler
NETWORK       := proxynetwork

FRONT           := $(STACK)_front
FRONTFULLNAME   := $(FRONT).1.$$(docker service ps -f 'name=$(FRONT)' $(FRONT) -q --no-trunc | head -n1)
FRONTRUN       := docker run --rm -v ${PWD}/front:/app koromerzhin/nodejs:1.1.3-quasar

BACK           := $(STACK)_back
BACKFULLNAME   := $(BACK).1.$$(docker service ps -f 'name=$(BACK)' $(BACK) -q --no-trunc | head -n1)
BACKRUN       := docker run --rm -v ${PWD}/back:/app koromerzhin/nodejs:15.1.0-express

SUPPORTED_COMMANDS := contributors docker logs git linter update inspect ssh sleep
SUPPORTS_MAKE_ARGS := $(findstring $(firstword $(MAKECMDGOALS)), $(SUPPORTED_COMMANDS))
ifneq "$(SUPPORTS_MAKE_ARGS)" ""
  COMMAND_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(COMMAND_ARGS):;@:)
endif

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

back/node_modules: isdocker images back/package.json
	$(BACKRUN) npm install

front/node_modules: isdocker images front/package.json
	$(FRONTRUN) npm install

package-lock.json: package.json
	@npm install

.PHONY: isdocker
isdocker: ## Docker is launch
ifeq ($(isDocker), 0)
	@echo "Docker is not launch"
	exit 1
endif

node_modules: package-lock.json
	@npm install

build: ## build
	cd apps && npm run build

contributors: node_modules ## Contributors
ifeq ($(COMMAND_ARGS),add)
	@npm run contributors add
else ifeq ($(COMMAND_ARGS),check)
	@npm run contributors check
else ifeq ($(COMMAND_ARGS),generate)
	@npm run contributors generate
else
	@npm run contributors
endif

docker: isdocker ## Scripts docker
ifeq ($(COMMAND_ARGS),create-network)
	@docker network create --driver=overlay $(NETWORK)
else ifeq ($(COMMAND_ARGS),image-pull)
	@more docker-compose.yml | grep image: | sed -e "s/^.*image:[[:space:]]//" | while read i; do docker pull $$i; done
else ifeq ($(COMMAND_ARGS),deploy)
	@docker stack deploy -c docker-compose.yml $(STACK)
else ifeq ($(COMMAND_ARGS),ls)
	@docker stack services $(STACK)
else ifeq ($(COMMAND_ARGS),stop)
	@docker stack rm $(STACK)
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make docker ARGUMENT"
	@echo "---"
	@echo "create-network: create network"
	@echo "image-pull: Get docker image"
	@echo "deploy: deploy"
	@echo "ls: docker service"
	@echo "stop: docker stop"
endif

logs: isdocker ## Scripts logs
ifeq ($(COMMAND_ARGS),stack)
	@docker service logs -f --tail 100 --raw $(STACK)
else ifeq ($(COMMAND_ARGS),front)
	@docker service logs -f --tail 100 --raw $(FRONTFULLNAME)
else ifeq ($(COMMAND_ARGS),back)
	@docker service logs -f --tail 100 --raw $(BACKFULLNAME)
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make logs ARGUMENT"
	@echo "---"
	@echo "stack: logs stack"
	@echo "front: FRONT"
	@echo "back: BACK"
endif

git: node_modules ## Scripts GIT
ifeq ($(COMMAND_ARGS),status)
	@git status
else ifeq ($(COMMAND_ARGS),check)
	@make contributors check -i
	@make linter all -i
	@make git status -i
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make git ARGUMENT"
	@echo "---"
	@echo "check: CHECK before"
	@echo "status: status"
endif

.PHONY: sleep
sleep: ## sleep
	@sleep  $(COMMAND_ARGS)

install: node_modules back/node_modules front/node_modules ## Installation
	@make docker image-pull -i
	@make docker deploy -i

linter: node_modules ## Scripts Linter
ifeq ($(COMMAND_ARGS),all)
	@make linter readme -i
else ifeq ($(COMMAND_ARGS),readme)
	@npm run linter-markdown README.md
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make linter ARGUMENT"
	@echo "---"
	@echo "all: ## Launch all linter"
	@echo "readme: linter README.md"
endif

ssh: isdocker ## ssh
ifeq ($(COMMAND_ARGS),front)
	@docker exec -it $(FRONTFULLNAME) /bin/bash
else ifeq ($(COMMAND_ARGS),back)
	@docker exec -it $(BACKFULLNAME) /bin/bash
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make ssh ARGUMENT"
	@echo "---"
	@echo "front: FRONT"
	@echo "back: BACK"
endif

inspect: isdocker ## inspect
ifeq ($(COMMAND_ARGS),front)
	@docker service inspect $(FRONT)
else ifeq ($(COMMAND_ARGS),back)
	@docker service inspect $(BACK)
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make inspect ARGUMENT"
	@echo "---"
	@echo "front: FRONT"
	@echo "back: BACK"
endif

update: isdocker ## ssh
ifeq ($(COMMAND_ARGS),front)
	@docker service update $(FRONT)
else ifeq ($(COMMAND_ARGS),back)
	@docker service update $(BACK)
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make update ARGUMENT"
	@echo "---"
	@echo "front: FRONT"
	@echo "back: BACK"
endif