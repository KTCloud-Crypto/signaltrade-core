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

kubectl --context "$CONTEXT" rollout status \
  statefulset/postgres --namespace signaltrade --timeout=180s
kubectl --context "$CONTEXT" rollout status \
  deployment/redis --namespace signaltrade --timeout=180s
kubectl --context "$CONTEXT" rollout status \
  deployment/localstack --namespace signaltrade --timeout=180s

if kubectl --context "$CONTEXT" get job database-migration \
  --namespace signaltrade >/dev/null 2>&1; then
  kubectl --context "$CONTEXT" wait --for=condition=complete \
    job/database-migration --namespace signaltrade --timeout=30s
fi

echo "local platform is ready: $CONTEXT / signaltrade"
