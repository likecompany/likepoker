application = $(name)/app
tests = $(name)/tests
code = $(application) $(tests)

.PHONY: clean
clean:
	rm -f `find . -type f -wholename '$(name)/*.py[co]' `
	rm -f `find . -type f -wholename '$(name)/*~' `
	rm -f `find . -type f -wholename '$(name)/.*~' `
	rm -rf $(name)/.cache $(name)/.ruff_cache $(name)/.mypy_cache $(name)/.coverage $(name)/htmlcov $(name)/.pytest_cache $(name)/cmake-build-debug

.PHONY: lint
lint:
	isort --check-only $(code)
	black --check --diff $(code)
	ruff $(code)
	mypy $(application)

.PHONY: reformat
reformat:
	black $(code)
	isort $(code)
	ruff --fix $(code)
