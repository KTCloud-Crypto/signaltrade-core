CLUSTER_NAME ?= signaltrade-local
KIND_CONFIG ?= infrastructure/local/kind/kind-config.yaml
KUSTOMIZE_DIR ?= infrastructure/local/kind
KUBE_CONTEXT ?= kind-$(CLUSTER_NAME)
MIGRATION_IMAGE ?= signaltrade-migrations:local

.PHONY: test create-cluster apply build-migrations load-migrations migrate verify delete-cluster

test:
	python3 -m pytest packages/signaltrade-core/tests

create-cluster:
	kind create cluster --name $(CLUSTER_NAME) --config $(KIND_CONFIG)

apply:
	kubectl --context $(KUBE_CONTEXT) apply -k $(KUSTOMIZE_DIR)

build-migrations:
	docker build -t $(MIGRATION_IMAGE) database

load-migrations:
	kind load docker-image $(MIGRATION_IMAGE) --name $(CLUSTER_NAME)

migrate:
	kubectl --context $(KUBE_CONTEXT) delete job database-migration --namespace signaltrade --ignore-not-found
	kubectl --context $(KUBE_CONTEXT) apply -k database/kubernetes
	kubectl --context $(KUBE_CONTEXT) wait --for=condition=complete job/database-migration --namespace signaltrade --timeout=300s

verify:
	./scripts/verify-local.sh

delete-cluster:
	kind delete cluster --name $(CLUSTER_NAME)
