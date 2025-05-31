ARCH := $(shell uname -m)
VAGRANT_FILE := Vagrantfile

ifeq ($(ARCH),arm64)
	VAGRANT_FILE := Vagrantfile.arm64
else
	VAGRANT_FILE := Vagrantfile.x86_64
endif
.PHONY: up down

up:
	VAGRANT_FILE=$(VAGRANT_FILE) vagrant up

down:
	VAGRANT_FILE=$(VAGRANT_FILE) vagrant halt

