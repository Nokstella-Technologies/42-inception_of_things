
K3D = $(shell command -v k3d 2>/dev/null)

all: run

$(K3D):
	bash scripts/install_tools.sh
	
cluster: $(K3D)
	bash scripts/setup_argocd.sh

run: cluster
	bash scripts/deploy_app.sh


clean:
	bash scripts/clean_and_test.sh

re: clean run

.PHONY: all clean re run
