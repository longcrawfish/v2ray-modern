#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

core_dir="${TEMPLATE_DIR}/core"
transport_dir=""
proxy_dir=""

ensure_directories
load_env_file
validate_base_env
assert_profile_templates

transport_dir=$(template_profile_dir transport)
proxy_dir=$(template_profile_dir proxy)

mkdir -p "${LOG_DIR}/xray" "${LOG_DIR}/caddy" "${LOG_DIR}/caddy/data" "${LOG_DIR}/caddy/config"
find "${RUNTIME_DIR}" -maxdepth 1 -type f ! -name '.gitkeep' -delete

render_template_dir "${core_dir}" "core"
render_template_dir "${transport_dir}" "transport"
render_template_dir "${proxy_dir}" "proxy"

log_info "已根据 PROFILE=${PROFILE} 选择模板目录"
log_info "transport: ${transport_dir}"
log_info "proxy: ${proxy_dir}"
echo "[OK] 已生成运行时配置:"
find "${RUNTIME_DIR}" -maxdepth 1 -type f | sort
