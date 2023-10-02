include make/check-defined.mk
include make/docker-build.mk

.PHONY: start
start:
	$(check_defined, command)

	$(containers) $(command)
