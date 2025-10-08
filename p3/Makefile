
K3D = $(shell command -v k3d 2>/dev/null)

VAGRANT := $(shell command -v vagrant 2>/dev/null)

all: $(K3D)

$(K3D):
	bash scripts/install_k3d.sh

extra: $(VAGRANT)

$(VAGRANT):
	bash scripts/install_vagrant.sh

.PHONY: all
