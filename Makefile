PACKAGE = which
ORG = amylum

BUILD_DIR = /tmp/$(PACKAGE)-build
RELEASE_DIR = /tmp/$(PACKAGE)-release
RELEASE_FILE = /tmp/$(PACKAGE).tar.gz

PACKAGE_VERSION = 2.21
PATCH_VERSION = $$(cat version)
VERSION = $(PACKAGE_VERSION)-$(PATCH_VERSION)

SOURCE_URL = https://ftp.gnu.org/gnu/$(PACKAGE)/$(PACKAGE)-$(PACKAGE_VERSION).tar.gz
SOURCE_PATH = /tmp/source
SOURCE_TARBALL = /tmp/source.tar.gz

.PHONY : default source manual container build version push local

default: source container

source:
	rm -rf $(SOURCE_PATH) $(SOURCE_TARBALL)
	mkdir $(SOURCE_PATH)
	curl -sLo $(SOURCE_TARBALL) $(SOURCE_URL)
	tar -x -C $(SOURCE_PATH) -f $(SOURCE_TARBALL)

manual: source
	./meta/launch /bin/bash || true

container:
	./meta/launch

build: source
	rm -rf $(BUILD_DIR)
	cp -R $(SOURCE_PATH) $(BUILD_DIR)
	TODO
	cd $(RELEASE_DIR) && tar -czvf $(RELEASE_FILE) *

version:
	@echo $$(($(PATCH_VERSION) + 1)) > version

push: version
	git commit -am "$(VERSION)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "$(VERSION)"
	git push --tags origin master
	targit -a .github -c -f $(ORG)/$(PACKAGE) $(VERSION) $(RELEASE_FILE)

local: build push

