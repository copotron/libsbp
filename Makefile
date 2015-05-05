# Convenience Makefile for generating and releasing SBP client
# libraries. Please read and understand the contents of this file
# before using it to do Crazy Things.

SWIFTNAV_ROOT := $(shell pwd)
MAKEFLAGS += SWIFTNAV_ROOT=$(SWIFTNAV_ROOT)
SBP_SPEC_DIR := $(SWIFTNAV_ROOT)/spec/yaml/swiftnav/sbp/
SBP_GEN_BIN := python sbpg/generator.py
CHANGELOG_GITHUB_TOKEN := CHANGELOG_GITHUB_TOKEN

.PHONY: help all c python docs pdf html test release dist

help:
	@echo
	@echo "Helper for generating and releasing SBP client libraries."
	@echo
	@echo "(Please read before using!)"
	@echo
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  help      to display this help message"
	@echo "  all       to make SBP clients across all languages"
	@echo "  c         to make C headers"
	@echo "  dist      to distribute packages"
	@echo "  docs      to make HTML and pdf documentation"
	@echo "  html      to make all HTML language docs"
	@echo "  pdf       to make SBP LaTeX datasheet"
	@echo "  python    to make Python bindings"
	@echo "  release   to handle some release tasks"
	@echo "  test      to run all tests"
	@echo

all: c python test docs

c:
	@echo
	@echo "Generating C headers..."
	@echo
	cd $(SWIFTNAV_ROOT)/generator; \
	$(SBP_GEN_BIN) -i $(SBP_SPEC_DIR) \
		       -o $(SWIFTNAV_ROOT)/c/include/libsbp \
	               --c;\
	cd $(SWIFTNAV_ROOT);
	@echo
	@echo "Finished. Please check $(SWIFTNAV_ROOT)/c/include/libsbp."

python:
	@echo
	@echo "Generating Python bindings..."
	@echo
	cd $(SWIFTNAV_ROOT)/generator; \
	$(SBP_GEN_BIN) -i $(SBP_SPEC_DIR) \
		       -o $(SWIFTNAV_ROOT)/python/sbp/ \
		       --python;\
	cd $(SWIFTNAV_ROOT);
	@echo
	@echo "Finished! Please check $(SWIFTNAV_ROOT)/python/sbp."

dist:
	@echo
	@echo "Deploy packages ..."
	@echo
	cd $(SWIFTNAV_ROOT)/python; \
	python setup.py sdist upload -r pypi; \
	cd $(SWIFTNAV_ROOT);
	@echo
	@echo "Finished! Please check $(SWIFTNAV_ROOT)/python/sbp."

docs: pdf html

pdf:
	@echo
	@echo "Generating datasheet documentation..."
	@echo
	cd $(SWIFTNAV_ROOT)/generator; \
	$(SBP_GEN_BIN) -i $(SBP_SPEC_DIR) \
		       -o $(SWIFTNAV_ROOT)/latex/ \
	               --latex;\
	cd $(SWIFTNAV_ROOT);
	@echo
	@echo "Finished!"
	@echo "Please check $(SWIFTNAV_ROOT)/latex and $(SWIFTNAV_ROOT)/docs."

html:
	@echo
	@echo "Generating bindings documentation..."
	@echo
	@echo "Generating C documentation..."
	@echo
	cd $(SWIFTNAV_ROOT)/c; \
	mkdir -p build/ && cd build/; \
	cmake ../; \
	make docs;
	@echo
	@echo "Generating Python documentation..."
	@echo
	cd $(SWIFTNAV_ROOT)/python/docs/ && make html
	cd $(SWIFTNAV_ROOT);
	@echo
	@echo "Finished!"

test:
	@echo
	@echo "Run tests..."
	@echo
	@echo "Running C tests..."
	@echo
	cd $(SWIFTNAV_ROOT)/c; \
	mkdir -p build/ && cd build/; \
	cmake ../; \
	make test;
	@echo
	@echo "Running Python tests..."
	@echo
	cd $(SWIFTNAV_ROOT)/python/ && tox
	cd $(SWIFTNAV_ROOT);
	@echo
	@echo "Finished!"

release:
	@echo
	@echo "Run release boilerplate..."
	@echo
	github_changelog_generator --no-author \
				   -t $(CHANGELOG_GITHUB_TOKEN)$ \
				   -o DRAFT_CHANGELOG.md \
				   swift-nav/libsbp
	@echo
	@echo "Added CHANGELOG details to DRAFT_CHANGELOG.md!"
