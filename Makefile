# ============================================VARIABLES===========================================
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call check_defined_detail,$1,$(strip $(value 2)))))
check_defined_detail = \
    $(if $(value $1),, \
      $(error Undefined variable: $1$(if $2, ($2))))

docker_v2 = docker compose

docker_main = docker
compose_main = compose

docker_network = $(docker_main)/networks.yml

auth_module = auth
balance_module = balance
collection_module = collection
file_module = file

auth_service = $(auth_module)/$(docker_main)/$(compose_main)/app.yml -f $(auth_module)/$(docker_main)/$(compose_main)/db.yml -f $(docker_network)
balance_service = $(balance_module)/$(docker_main)/$(compose_main)/app.yml -f $(balance_module)/$(docker_main)/$(compose_main)/db.yml -f $(docker_network)
collection_service = $(collection_module)/$(docker_main)/$(compose_main)/app.yml -f $(collection_module)/$(docker_main)/$(compose_main)/db.yml -f $(docker_network)
file_service = $(file_module)/$(docker_main)/$(compose_main)/app.yml -f $(file_module)/$(docker_main)/$(compose_main)/db.yml -f $(docker_network)

services = $(auth_service)/$(docker_main)/$(compose_main)/app.yml -f $(auth_service)/$(docker_main)/$(compose_main)/db.yml -f $(balance_service)/$(docker_main)/$(compose_main)/app.yml -f $(balance_service)/$(docker_main)/$(compose_main)/db.yml -f $(collection_service)/$(docker_main)/$(compose_main)/app.yml -f $(collection_service)/$(docker_main)/$(compose_main)/db.yml -f $(file_service)/$(docker_main)/$(compose_main)/app.yml -f $(file_service)/$(docker_main)/$(compose_main)/db.yml

ifdef containers
	container = $(docker_v2) $(foreach var,$(containers),-f $(service)/$(docker_main)/$(compose_main)/$(var).yml) -f $(service)/$(docker_main)/$(compose_main)/main.yml -f $(docker_network) --env-file .env
		ifdef captures
			container = $(container) --abort-on-container-exit --exit-code-from $(captures)
		endif
else
	container = $(docker_v2) -f $(docker_main)/$(compose_main)/web.yml -f $(docker_network) -f $(auth_service) -f $(balance_service) -f $(collection_service) -f $(file_service) --env-file .env
endif

ifdef service:
	application_directory = $(service)/app
	tests_directory = $(service)/tests
	code_directory = $(application_directory) $(tests_directory)
endif
# ============================================VARIABLES===========================================

# =============================================SYSTEM=============================================
.PHONY: clean
clean:
	$(call check_defined, service)

	rm -f `find . -type f -name '$(service)/*.py[co]' `
	rm -f `find . -type f -name '$(service)/*~' `
	rm -f `find . -type f -name '$(service)/.*~' `
	rm -rf {$(service)/.cache,$(service)/.ruff_cache,$(service)/.mypy_cache,$(service)/.coverage,$(service)/htmlcov,$(service)/.pytest_cache, $(service)/cmake-build-debug}
# =============================================SYSTEM=============================================

# ==============================================CODE==============================================
.PHONY: lint
lint:
	$(call check_defined, service)

	isort --check-only $(code_directory)
	black --check --diff $(code_directory)
	ruff $(code_directory)
	mypy $(application_directory)

.PHONY: reformat
reformat:
	$(call check_defined, service)

	black $(code_directory)
	isort $(code_directory)
	ruff --fix $(code_directory)
# ==============================================CODE==============================================

# ======================================DOCKER====================================================
.PHONY: build
build:
	$(container) build

.PHONY: up
up:
	$(container) up -d

.PHONY: upd
upd:
	$(container) up

.PHONY: stop
stop:
	$(container) stop

.PHONY: down
down:
	$(container) down

.PHONY: destroy
destroy:
	$(container) down -v

.PHONY: logs
logs:
	$(container) logs -f
# ======================================DOCKER====================================================
