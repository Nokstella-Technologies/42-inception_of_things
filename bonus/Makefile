K3D = $(shell command -v k3d 2>/dev/null)

# Returns empty string if cluster does NOT exist
CLUSTER = $(shell k3d cluster list 2>/dev/null | grep -q "iot-p3" || echo "no-cluster")

VAGRANT := $(shell command -v vagrant 2>/dev/null)

all: run

$(K3D):
	bash scripts/install_tools.sh
	
cluster: $(K3D)
	bash scripts/setup_argocd.sh

gitlab: cluster
	bash scripts/setup_gitlab.sh
	bash scripts/push_to_gitlab.sh

run: gitlab
	bash scripts/deploy_app.sh

clean:
	bash scripts/clean_and_test.sh

re: clean run

.PHONY: all clean re run cluster gitlab
