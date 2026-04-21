#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

load_env_file
validate_base_env

echo "[INFO] 当前环境摘要"
echo "PROFILE=${PROFILE}"
echo "DOMAIN=${DOMAIN}"
echo "UUID=${UUID}"
echo "WS_PATH=${WS_PATH}"
echo "NODE_NAME=${NODE_NAME}"
echo "XRAY_PORT=${XRAY_PORT}"
echo "TLS_MODE=${TLS_MODE}"
echo "TLS_EMAIL=${TLS_EMAIL}"
echo "TLS_CA=${TLS_CA}"
echo "CADDY_HTTP_PORT=${CADDY_HTTP_PORT}"
echo "CADDY_HTTPS_PORT=${CADDY_HTTPS_PORT}"
echo "CADDY_ADMIN_PORT=${CADDY_ADMIN_PORT}"
echo "XRAY_IMAGE=${XRAY_IMAGE}"
echo "CADDY_IMAGE=${CADDY_IMAGE}"
echo "XRAY_LOG_LEVEL=${XRAY_LOG_LEVEL}"
echo "ENABLE_FAKE_SITE=${ENABLE_FAKE_SITE}"
