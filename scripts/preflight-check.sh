#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

ensure_directories
require_command docker
detect_compose_command
load_env_file
validate_base_env
check_port_available "${XRAY_PORT}"
check_port_available "${SUBSCRIPTION_CADDY_PORT}"
assert_profile_templates

log_info "docker compose 可用: ${COMPOSE_CMD}"
log_info "PROFILE=${PROFILE}"
log_info "DOMAIN=${DOMAIN}"
log_info "端口 ${XRAY_PORT} 空闲"
log_info "订阅服务端口 ${SUBSCRIPTION_CADDY_PORT} 空闲"
if [ "${PROFILE}" = "reality" ]; then
  log_info "REALITY_SERVER_NAME=${REALITY_SERVER_NAME}"
  log_info "REALITY_DEST=${REALITY_DEST}"
fi
echo "[OK] 基础检查完成"
