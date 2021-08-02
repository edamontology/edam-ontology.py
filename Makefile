# Default environment for make tox
ENV?=py27
# Extra arguments supplied to tox command
ARGS?=
# Open resource on Mac OS X or Linux
OPEN_RESOURCE=bash -c 'open $$0 || xdg-open $$0'
IN_VENV=if [ -f $(VENV)/bin/activate ]; then . $(VENV)/bin/activate; fi;
VENV?=.venv
# TODO: add this upstream as a remote if it doesn't already exist.
UPSTREAM?=edamontology
SOURCE_DIR?=edam_ontology
BUILD_SCRIPTS_DIR=scripts
VERSION?=$(shell python $(BUILD_SCRIPTS_DIR)/print_version_for_release.py $(SOURCE_DIR))
PROJECT_URL?=https://github.com/edamontology/edam-ontology.py
PROJECT_NAME?=edam_ontology
TEST_DIR?=tests

.PHONY: clean-pyc clean-build docs clean

help:
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr *.egg-info

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/

install: ## install into Python envirnoment
	python setup.py install

setup-venv: ## setup a development virtualenv in current directory
	if [ ! -d $(VENV) ]; then virtualenv $(VENV); exit; fi;
	$(IN_VENV) pip install --upgrade pip && pip install -r dev-requirements.txt -r requirements.txt

lint: ## check style using tox and flake8
	$(IN_VENV) tox -e lint
	$(IN_VENV) tox -e mypy

test: ## run tests with the default Python (faster than tox)
	$(IN_VENV) tox -e unit

tox: ## run tests with tox in the specified ENV, defaults to py27
	$(IN_VENV) tox -e $(ENV) -- $(ARGS)

open-project: ## open project on github
	$(OPEN_RESOURCE) $(PROJECT_URL)

dist: clean ## create and check packages
	$(IN_VENV) python setup.py sdist bdist_wheel
	$(IN_VENV) twine check dist/*
	ls -l dist

commit-version: ## Update version and history, commit and add tag
	$(IN_VENV) python $(BUILD_SCRIPTS_DIR)/commit_version.py $(SOURCE_DIR) $(VERSION)

new-version: ## Mint a new version
	$(IN_VENV) python $(BUILD_SCRIPTS_DIR)/new_version.py $(SOURCE_DIR) $(VERSION)

release-local: commit-version new-version

push-release: ## Push a tagged release to github
	git push $(UPSTREAM) master
	git push --tags $(UPSTREAM)

release: release-local push-release ## package, review, and upload a release
