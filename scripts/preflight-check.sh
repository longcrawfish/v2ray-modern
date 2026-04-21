#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

ensure_directories
require_command docker
detect_compose_command
load_env_file
validate_base_env
check_port_available "${CADDY_HTTP_PORT}"
check_port_available "${CADDY_HTTPS_PORT}"
assert_profile_templates

log_info "docker compose 可用: ${COMPOSE_CMD}"
log_info "PROFILE=${PROFILE}"
log_info "DOMAIN=${DOMAIN}"
log_info "端口 ${CADDY_HTTP_PORT}/${CADDY_HTTPS_PORT} 空闲"
echo "[OK] 基础检查完成"
