#!/usr/bin/env bash

# Upgrade Envoy Gateway using the NodePort settings in values.yaml.
# Run from this folder with: ./upgrade.sh

set -euo pipefail

# Default variables (can be overridden via environment variables or flags if needed)
RELEASE_NAME="${RELEASE_NAME:-eg}"
NAMESPACE="${NAMESPACE:-envoy-gateway-system}"
CHART="${CHART:-oci://docker.io/envoyproxy/gateway-helm}"
CHART_VERSION="${CHART_VERSION:-}"

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="$SCRIPT_DIR/values.yaml"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Error: Helm was not found on PATH. Install Helm and retry." >&2
    exit 1
fi

# Check if values.yaml exists
if [ ! -f "$VALUES_FILE" ]; then
    echo "Error: Values file not found: $VALUES_FILE" >&2
    exit 1
fi

# Build helm upgrade arguments
HELM_ARGS=(
    "upgrade"
    "$RELEASE_NAME"
    "$CHART"
    "--namespace" "$NAMESPACE"
    "--create-namespace"
    "--values" "$VALUES_FILE"
    "--wait"
)

# Add version if provided
if [ -n "$CHART_VERSION" ]; then
    HELM_ARGS+=("--version" "$CHART_VERSION")
fi

echo "Upgrading Envoy Gateway release '$RELEASE_NAME' in namespace '$NAMESPACE'..."
helm "${HELM_ARGS[@]}"

echo "Upgrade completed. Check the Gateway Service NodePorts with:"
echo "kubectl get svc -n $NAMESPACE"