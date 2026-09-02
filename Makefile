CLUSTER_NAME ?= signaltrade-local
KIND_CONFIG ?= infrastructure/kind/kind-config.yaml
KUSTOMIZE_DIR ?= infrastructure/kubernetes/local
KUBE_CONTEXT ?= kind-$(CLUSTER_NAME)

.PHONY: create-cluster apply verify delete-cluster

create-cluster:
	kind create cluster --name $(CLUSTER_NAME) --config $(KIND_CONFIG)

apply:
	kubectl --context $(KUBE_CONTEXT) apply -k $(KUSTOMIZE_DIR)

verify:
	./scripts/verify-local.sh

delete-cluster:
	kind delete cluster --name $(CLUSTER_NAME)
