CLUSTER_NAME ?= signaltrade-local
KIND_CONFIG ?= infrastructure/local/kind/kind-config.yaml
KUSTOMIZE_DIR ?= infrastructure/local/kind
KUBE_CONTEXT ?= kind-$(CLUSTER_NAME)

.PHONY: test create-cluster apply verify delete-cluster

test:
	python3 -m pytest packages/signaltrade-core/tests

create-cluster:
	kind create cluster --name $(CLUSTER_NAME) --config $(KIND_CONFIG)

apply:
	kubectl --context $(KUBE_CONTEXT) apply -k $(KUSTOMIZE_DIR)

verify:
	./scripts/verify-local.sh

delete-cluster:
	kind delete cluster --name $(CLUSTER_NAME)
