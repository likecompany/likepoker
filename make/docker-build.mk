docker = docker
compose = compose

web = $(docker)/$(compose)/web.yml
networks = $(docker)/networks.yml

docker_v2 = docker compose

env = .env
names = .names

ifdef name
	ifdef run
		containers = $(docker_v2) $(foreach container,$(run),-f $(name)/$(docker)/$(compose)/$(container).yml) -f $(networks) --env-file $(env)

		ifdef captures
			containers += --abort-on-container-exit --exit-code-from $(captures)
		endif
	endif
else
	containers = $(docker_v2) -f $(web) $(foreach name,$(shell cat $(names)),-f $(name)/$(docker)/$(compose)/app.yml -f $(name)/$(docker)/$(compose)/db.yml) -f $(networks) --env-file $(env)
endif
