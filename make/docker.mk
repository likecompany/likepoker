include make/check-defined.mk
include make/docker-build.mk

docker = docker compose

.PHONY: start
start:
	$(check_defined, command)

	$(docker) $(containers) $(command)
