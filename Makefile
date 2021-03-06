# ezPAARSE's Makefile

SHELL:=/bin/bash

# Doc section
# # # # # # # # #

DOC_DIR:=$(shell pwd)/doc
DOC_MD=$(DOC_DIR)
DOC=$(wildcard $(DOC_MD)/*.md)
DOC_OUTPUT=$(shell pwd)/public/doc
DOC_HTML=$(DOC_OUTPUT)/index.html

# Run every steps needed to start ezpaarse
all: build pkb-update checkconfig

# Application section
# # # # # # # # # # # #

checkconfig:
	@. ./bin/env; if which node > /dev/null; then ./bin/checkconfig; else echo "Node.js was not found" >&2; fi

start:
	@./bin/ezpaarse start
stop:
	@./bin/ezpaarse stop
restart:
	@./bin/ezpaarse restart
status:
	@./bin/ezpaarse status

# Doc section
# # # # # # # # # # # #

# Generate doc with beautiful-docs
$(DOC_HTML): $(DOC)
	@. ./bin/env; bfdocs --base-url='.' $(DOC_MD)/manifest.json $(DOC_OUTPUT)

doc: $(DOC_HTML)

docclean:
	@rm -rf $(DOC_OUTPUT)

docopen: doc $(DOC_HMTL)
	@google-chrome file://$(DOC_HTML) 2>/dev/null &

# Tests section
# # # # # # # # #

EZPATH = $(shell pwd)
JSFILES=$(wildcard $(EZPATH)/*.js) $(wildcard $(EZPATH)/test/*.js)  $(wildcard $(EZPATH)/routes/*.js)

# Runs all tests (*-test.js) in the test folder
test:
	@if test -d test; \
	then . ./bin/env; mocha; \
	else echo 'No test folder found'; \
	fi

test-verbose:
	@if test -d test; \
	then . ./bin/env; mocha -R list; \
	else echo 'No test folder found'; \
	fi

test-platforms:
	@if test -d test; \
	then . ./bin/env; mocha -g parser; \
	else echo 'No test folder found'; \
	fi

test-platforms-verbose:
	@if test -d test; \
	then . ./bin/env; mocha -R list -g parser; \
	else echo 'No test folder found'; \
	fi

jshint:
	@. ./bin/env; jshint $(JSFILES) --config .jshintrc

# Benchmarks section
# # # # # # # # # # # #

# example: make bench duration=30
bench:
	@test -f /usr/bin/pidstat || sudo apt-get install --yes sysstat
	@test -f /usr/bin/pstree  || sudo apt-get install --yes psmisc
	@test -f /usr/bin/gnuplot || sudo apt-get install --yes gnuplot
	@./bin/runbench

# Build section
# # # # # # # # # # # #

build:
	@test -f /usr/bin/git || sudo apt-get install --yes git
	@./bin/buildnode
	@./build/nvm/bin/latest/npm rebuild >/dev/null
	$(MAKE) doc

# make deb v=0.0.3
deb:
	@test -f /usr/bin/dpkg-deb || sudo apt-get install --yes dpkg
	@test -f /usr/bin/fakeroot || sudo apt-get install --yes fakeroot
	./bin/builddeb

# make rpm v=0.0.3
rpm:
	@test -f /usr/bin/alien || sudo apt-get install --yes alien
	@test -f /usr/bin/fakeroot || sudo apt-get install --yes fakeroot
	./bin/buildrpm

# zip and tar.gz archives are generated
# make zip v=0.0.3
zip:
	./bin/buildrelease

clean-for-release:
	test -f ./clean-for-release-flag || ( echo "Warning: do no run this command on your ezpaarse used for devlopements" ; exit 1 )	
	rm -rf ./.git/
	rm -f ./test/injection-test.js
	mv ./test/dataset/sd.wrong-first-line.log /tmp/ ; echo -n ""
	mv ./test/dataset/sd.mini.log* /tmp/            ; echo -n ""
	rm -f ./test/dataset/*
	mv /tmp/sd.wrong-first-line.log ./test/dataset/ ; echo -n ""
	mv /tmp/sd.mini.log*            ./test/dataset/ ; echo -n ""
	rm -rf ./build/
	rm -rf ./misc/
	rm -rf ./ezpaarse-*/
	find ./node_modules/ -name "tests"     -type d -exec rm -rf {} \; 2>/dev/null || true
	find ./node_modules/ -name "test"      -type d -exec rm -rf {} \; 2>/dev/null || true
	find ./node_modules/ -name "dist"      -type d -exec rm -rf {} \; 2>/dev/null || true
	find ./node_modules/ -name "build"     -type d -exec rm -rf {} \; 2>/dev/null || true
	find ./node_modules/ -name "example"   -type d -exec rm -rf {} \; 2>/dev/null || true
	find ./node_modules/ -name "examples"  -type d -exec rm -rf {} \; 2>/dev/null || true
	find ./node_modules/ -name "benchmark" -type d -exec rm -rf {} \; 2>/dev/null || true
	rm -f ./clean-for-release-flag

# example: make version v=0.0.3
version:
	./bin/patch-version-number --version $(v)

tag:
	./bin/tagversion

# example: make upload v=0.0.4 o=--force
upload:
	./bin/uploadversion

update: pkb-update pull restart

# Clone or update pkb folder
pkb-update:
	@if test -d platforms-kb; \
	then cd platforms-kb; git pull; \
	else git clone https://github.com/ezpaarse-project/ezpaarse-pkb.git platforms-kb; \
	fi

pull:
	git pull

.PHONY: test checkconfig build pkb-update deb rpm release clean-for-release version tag update pull start restart status stop