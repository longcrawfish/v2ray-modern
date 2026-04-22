#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

common_template_vars='PROFILE NODE_NAME NODE_NAME_URLENCODED SERVER PORT UUID CLIENT_FINGERPRINT EXPORT_DIR SUBSCRIPTION_HOST'
ws_template_vars='PROFILE NODE_NAME NODE_NAME_URLENCODED SERVER PORT UUID CLIENT_FINGERPRINT EXPORT_DIR SUBSCRIPTION_HOST SNI HOST WS_PATH WS_PATH_URLENCODED'
reality_template_vars='PROFILE NODE_NAME NODE_NAME_URLENCODED SERVER PORT UUID CLIENT_FINGERPRINT EXPORT_DIR SUBSCRIPTION_HOST REALITY_SERVER_NAME REALITY_PUBLIC_KEY REALITY_SHORT_ID FLOW'

set_default_if_empty() {
  target_var=$1
  target_value=$2

  eval "current_value=\${${target_var}:-}"
  if [ -z "${current_value}" ] && [ -n "${target_value}" ]; then
    printf -v "${target_var}" '%s' "${target_value}"
    export "${target_var}"
  fi
}

require_template_file() {
  template_path=$1
  [ -f "${template_path}" ] || fail "缺少导出模板: ${template_path}"
}

resolve_common_export_vars() {
  require_non_empty "NODE_NAME" "${NODE_NAME}"
  require_non_empty "UUID" "${UUID}"

  set_default_if_empty "SERVER" "${DOMAIN}"
  set_default_if_empty "SUBSCRIPTION_HOST" "${DOMAIN}"

  require_non_empty "SERVER" "${SERVER}"
  require_non_empty "SUBSCRIPTION_HOST" "${SUBSCRIPTION_HOST}"
  require_non_empty "CLIENT_FINGERPRINT" "${CLIENT_FINGERPRINT}"

  NODE_NAME_URLENCODED=$(urlencode_utf8 "${NODE_NAME}")
  export NODE_NAME_URLENCODED
}

resolve_ws_tls_vars() {
  set_default_if_empty "PORT" "443"
  set_default_if_empty "SNI" "${DOMAIN}"
  set_default_if_empty "HOST" "${DOMAIN}"

  require_non_empty "PORT" "${PORT}"
  require_non_empty "SNI" "${SNI}"
  require_non_empty "HOST" "${HOST}"
  require_non_empty "WS_PATH" "${WS_PATH}"

  WS_PATH_URLENCODED=$(urlencode_utf8 "${WS_PATH}")
  export WS_PATH_URLENCODED
}

resolve_reality_vars() {
  set_default_if_empty "PORT" "${XRAY_PORT}"

  require_non_empty "PORT" "${PORT}"
  require_non_empty "REALITY_SERVER_NAME" "${REALITY_SERVER_NAME}"
  require_non_empty "REALITY_PUBLIC_KEY" "${REALITY_PUBLIC_KEY}"
  require_non_empty "REALITY_SHORT_ID" "${REALITY_SHORT_ID}"
  require_non_empty "FLOW" "${FLOW}"
}

render_export_files() {
  profile_template_dir="${EXPORT_TEMPLATE_DIR}/${PROFILE}"
  clash_template="${profile_template_dir}/clash.yaml.tpl"
  vless_template="${profile_template_dir}/vless.link.tpl"
  subscription_template="${profile_template_dir}/clash-subscription-url.txt.tpl"

  require_template_file "${clash_template}"
  require_template_file "${vless_template}"
  require_template_file "${subscription_template}"

  render_dollar_template_file "${clash_template}" "${EXPORT_DIR}/clash.yaml" ${template_vars}
  render_dollar_template_file "${vless_template}" "${EXPORT_DIR}/vless.txt" ${template_vars}
  render_dollar_template_file "${subscription_template}" "${EXPORT_DIR}/clash-subscription-url.txt" ${common_template_vars}

  assert_no_dollar_placeholders "${EXPORT_DIR}/clash.yaml"
  assert_no_dollar_placeholders "${EXPORT_DIR}/vless.txt"
  assert_no_dollar_placeholders "${EXPORT_DIR}/clash-subscription-url.txt"
}

ensure_directories
load_env_file
supplement_env_from_runtime_file
validate_profile
validate_domain
validate_uuid_if_present
validate_numeric_port "PORT" "${PORT:-}"
validate_numeric_port "XRAY_PORT" "${XRAY_PORT:-}"
resolve_common_export_vars

export_root_dir="${EXPORT_DIR}"
export_dir="${export_root_dir}/${PROFILE}"
mkdir -p "${export_root_dir}/ws-tls" "${export_root_dir}/reality" "${export_dir}"
find "${export_dir}" -maxdepth 1 -type f ! -name '.gitkeep' -delete

EXPORT_DIR="${export_dir}"
export EXPORT_DIR

case "${PROFILE}" in
  ws-tls)
    validate_ws_tls_env
    resolve_ws_tls_vars
    template_vars="${ws_template_vars}"
    ;;
  reality)
    resolve_reality_vars
    template_vars="${reality_template_vars}"
    ;;
esac

render_export_files

log_info "已导出 profile=${PROFILE} 客户端配置"
echo "[OK] 导出目录: ${EXPORT_DIR}"
find "${EXPORT_DIR}" -maxdepth 1 -type f | sort
