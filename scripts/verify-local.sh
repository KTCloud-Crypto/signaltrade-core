#!/bin/sh
set -eu

CLUSTER_NAME=${CLUSTER_NAME:-signaltrade-local}
CONTEXT="kind-${CLUSTER_NAME}"

command -v kind >/dev/null 2>&1 || {
  echo "kind is required" >&2
  exit 1
}
command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl is required" >&2
  exit 1
}

kind get clusters | grep -Fx "$CLUSTER_NAME" >/dev/null || {
  echo "kind cluster not found: $CLUSTER_NAME" >&2
  exit 1
}

kubectl --context "$CONTEXT" get namespace signaltrade >/dev/null
kubectl --context "$CONTEXT" wait \
  --for=jsonpath='{.status.phase}'=Active \
  namespace/signaltrade \
  --timeout=30s

echo "local platform is ready: $CONTEXT / signaltrade"

