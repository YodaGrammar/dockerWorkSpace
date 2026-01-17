.DEFAULT_GOAL=help
GROUPS=all
DOCKER_COMPOSE = docker compose

$(eval LAST_COMMIT = $(shell git log -1 --oneline --pretty=format:"%h - %an, %ar"))
$(eval LAST_RELEASE = $(shell git describe --abbrev=0 --tags 2>/dev/null || echo "No tags yet"))

help:
	@printf ""
	@printf "                              \033[1;34m Backend Work Kit \033[0m\n"
	@printf "                           \033[1;34m --------------------- \033[0m\n"
	@printf ""
	@grep -E '^[-a-z\:\\]+:.*?## .*$$|^##' $(MAKEFILE_LIST) | \
	   awk 'BEGIN {FS = ": .*?## "}; {gsub(/\\/, "", $$1); printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | \
	   sed -e 's/\[32m##/[33m/'
	@printf ""
	@printf "Last release: \033[32m$(LAST_RELEASE)\033[0m\n"
	@printf "Last commit : \033[32m$(LAST_COMMIT)\033[0m\n"
	@printf ""


##
##                                Setup
##---------------------------------------------------------------------------
##

ssl: ## Install SSL certificate in system trust store
	@bash script/generate_local_certificate.sh $(SERVICE)

##
##                                Launch
##---------------------------------------------------------------------------
##

start: up ## Start the stack

stop: down ## Stop the stack

up: ## Start containers
	@$(DOCKER_COMPOSE) up -d --build

down: ## Stop containers
	@$(DOCKER_COMPOSE) down --remove-orphans

test:  ## Run tests
	echo "Run tests here "$(SERVICE)
