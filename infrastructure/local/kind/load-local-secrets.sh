#!/bin/sh
set -eu

ENV_FILE=${1:-.env}
CLUSTER_NAME=${CLUSTER_NAME:-signaltrade-local}
CONTEXT="kind-${CLUSTER_NAME}"
NAMESPACE=${NAMESPACE:-signaltrade}
SECRET_NAME=${SECRET_NAME:-application-runtime-secret}

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

kubectl --context "$CONTEXT" get namespace "$NAMESPACE" >/dev/null

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing local environment file: $ENV_FILE" >&2
  exit 1
fi

# This helper is intentionally allowlisted. Compose DATABASE_URL, JWT and
# encryption keys must never overwrite the independent kind environment.
set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

: "${TELEGRAM_BOT_TOKEN:?TELEGRAM_BOT_TOKEN is required in $ENV_FILE}"
: "${TELEGRAM_BOT_USERNAME:?TELEGRAM_BOT_USERNAME is required in $ENV_FILE}"

encode() {
  printf %s "$1" | base64 | tr -d '\n'
}

TOKEN_B64=$(encode "$TELEGRAM_BOT_TOKEN")
USERNAME_B64=$(encode "$TELEGRAM_BOT_USERNAME")
PATCH=$(printf '{"data":{"TELEGRAM_BOT_TOKEN":"%s","TELEGRAM_BOT_USERNAME":"%s"}}' "$TOKEN_B64" "$USERNAME_B64")

kubectl --context "$CONTEXT" patch secret "$SECRET_NAME" \
  --namespace "$NAMESPACE" \
  --type merge \
  --patch "$PATCH" >/dev/null

kubectl --context "$CONTEXT" rollout restart deployment/identity-api deployment/notification-worker \
  --namespace "$NAMESPACE" >/dev/null
kubectl --context "$CONTEXT" rollout status deployment/identity-api \
  --namespace "$NAMESPACE" --timeout=180s
kubectl --context "$CONTEXT" rollout status deployment/notification-worker \
  --namespace "$NAMESPACE" --timeout=180s

echo "Telegram settings loaded into $CONTEXT / $NAMESPACE/$SECRET_NAME"
