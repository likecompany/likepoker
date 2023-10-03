ifdef name
	ifdef run
		containers = $(foreach container,$(run),-f $(name)/$(shell cat $(name)/.docker)/$(container).yml) -f $(name)/$(shell cat $(name)/.docker-networks) --env-file .env

		ifdef captures
			containers += --abort-on-container-exit --exit-code-from $(captures)
		endif
	endif
else
	containers = $(foreach name,$(shell cat .names),$(foreach compose,$(shell cat $(name)/.docker-rule),-f $(name)/$(compose))) --env-file .env
endif
