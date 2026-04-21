#!/usr/bin/env bash

# Shared helpers for Phase 1A base scripts.

ROOT_DIR=$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
ENV_FILE="${ROOT_DIR}/.env"
RUNTIME_DIR="${ROOT_DIR}/data/runtime"
EXPORT_DIR="${ROOT_DIR}/data/exports"
LOG_DIR="${ROOT_DIR}/data/logs"
TEMPLATE_DIR="${ROOT_DIR}/templates"
COMPOSE_FILE="${ROOT_DIR}/compose.yaml"
PRIMARY_SERVICE_NAME="caddy"
RUNTIME_ENV_FILE="${RUNTIME_DIR}/core-base.env"

SUPPORTED_PROFILES="ws-tls reality"

ensure_directories() {
  mkdir -p "${RUNTIME_DIR}" "${EXPORT_DIR}" "${LOG_DIR}"
}

log_info() {
  echo "[INFO] $*"
}

log_warn() {
  echo "[WARN] $*"
}

log_error() {
  echo "[ERROR] $*" >&2
}

fail() {
  log_error "$*"
  exit 1
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "缺少命令: $1"
  fi
}

load_env_file() {
  if [ ! -f "${ENV_FILE}" ]; then
    fail "未找到 .env，请先执行 'cp .env.example .env' 并填写必要参数。"
  fi

  # shellcheck disable=SC1090
  . "${ENV_FILE}"

  PROFILE=${PROFILE:-}
  DOMAIN=${DOMAIN:-}
  UUID=${UUID:-}
  WS_PATH=${WS_PATH:-}
  NODE_NAME=${NODE_NAME:-}
  XRAY_PORT=${XRAY_PORT:-}
  TLS_MODE=${TLS_MODE:-}
  XRAY_IMAGE=${XRAY_IMAGE:-}
  CADDY_IMAGE=${CADDY_IMAGE:-}
  TLS_EMAIL=${TLS_EMAIL:-}
  TLS_CA=${TLS_CA:-}
  CADDY_HTTP_PORT=${CADDY_HTTP_PORT:-}
  CADDY_HTTPS_PORT=${CADDY_HTTPS_PORT:-}
  CADDY_ADMIN_PORT=${CADDY_ADMIN_PORT:-}
  XRAY_LOG_LEVEL=${XRAY_LOG_LEVEL:-}
  ENABLE_FAKE_SITE=${ENABLE_FAKE_SITE:-}

  export PROFILE DOMAIN UUID WS_PATH NODE_NAME XRAY_PORT TLS_MODE XRAY_IMAGE CADDY_IMAGE TLS_EMAIL TLS_CA CADDY_HTTP_PORT CADDY_HTTPS_PORT CADDY_ADMIN_PORT XRAY_LOG_LEVEL ENABLE_FAKE_SITE
}

load_env_if_present() {
  if [ -f "${ENV_FILE}" ]; then
    # shellcheck disable=SC1090
    . "${ENV_FILE}"
    PROFILE=${PROFILE:-}
    DOMAIN=${DOMAIN:-}
    UUID=${UUID:-}
    WS_PATH=${WS_PATH:-}
    NODE_NAME=${NODE_NAME:-}
    XRAY_PORT=${XRAY_PORT:-}
    TLS_MODE=${TLS_MODE:-}
    XRAY_IMAGE=${XRAY_IMAGE:-}
    CADDY_IMAGE=${CADDY_IMAGE:-}
    TLS_EMAIL=${TLS_EMAIL:-}
    TLS_CA=${TLS_CA:-}
    CADDY_HTTP_PORT=${CADDY_HTTP_PORT:-}
    CADDY_HTTPS_PORT=${CADDY_HTTPS_PORT:-}
    CADDY_ADMIN_PORT=${CADDY_ADMIN_PORT:-}
    XRAY_LOG_LEVEL=${XRAY_LOG_LEVEL:-}
    ENABLE_FAKE_SITE=${ENABLE_FAKE_SITE:-}
    export PROFILE DOMAIN UUID WS_PATH NODE_NAME XRAY_PORT TLS_MODE XRAY_IMAGE CADDY_IMAGE TLS_EMAIL TLS_CA CADDY_HTTP_PORT CADDY_HTTPS_PORT CADDY_ADMIN_PORT XRAY_LOG_LEVEL ENABLE_FAKE_SITE
    return 0
  fi

  if [ -f "${RUNTIME_ENV_FILE}" ]; then
    # shellcheck disable=SC1090
    . "${RUNTIME_ENV_FILE}"
    PROFILE=${PROFILE:-}
    DOMAIN=${DOMAIN:-}
    UUID=${UUID:-}
    WS_PATH=${WS_PATH:-}
    NODE_NAME=${NODE_NAME:-}
    XRAY_PORT=${XRAY_PORT:-}
    TLS_MODE=${TLS_MODE:-}
    XRAY_IMAGE=${XRAY_IMAGE:-}
    CADDY_IMAGE=${CADDY_IMAGE:-}
    TLS_EMAIL=${TLS_EMAIL:-}
    TLS_CA=${TLS_CA:-}
    CADDY_HTTP_PORT=${CADDY_HTTP_PORT:-}
    CADDY_HTTPS_PORT=${CADDY_HTTPS_PORT:-}
    CADDY_ADMIN_PORT=${CADDY_ADMIN_PORT:-}
    XRAY_LOG_LEVEL=${XRAY_LOG_LEVEL:-}
    ENABLE_FAKE_SITE=${ENABLE_FAKE_SITE:-}
    export PROFILE DOMAIN UUID WS_PATH NODE_NAME XRAY_PORT TLS_MODE XRAY_IMAGE CADDY_IMAGE TLS_EMAIL TLS_CA CADDY_HTTP_PORT CADDY_HTTPS_PORT CADDY_ADMIN_PORT XRAY_LOG_LEVEL ENABLE_FAKE_SITE
    return 0
  fi

  return 1
}

require_non_empty() {
  var_name=$1
  var_value=$2

  if [ -z "${var_value}" ]; then
    fail "变量 ${var_name} 不能为空。"
  fi
}

profile_supported() {
  expected=$1

  for candidate in ${SUPPORTED_PROFILES}; do
    if [ "${candidate}" = "${expected}" ]; then
      return 0
    fi
  done

  return 1
}

validate_profile() {
  require_non_empty "PROFILE" "${PROFILE}"

  if ! profile_supported "${PROFILE}"; then
    fail "PROFILE 必须是以下值之一: ${SUPPORTED_PROFILES}"
  fi
}

validate_domain() {
  require_non_empty "DOMAIN" "${DOMAIN}"

  case "${DOMAIN}" in
    http://*|https://*|*/*)
      fail "DOMAIN 只能填写纯域名，不能包含协议头或路径。"
      ;;
  esac
}

validate_ws_path() {
  require_non_empty "WS_PATH" "${WS_PATH}"

  case "${WS_PATH}" in
    /*)
      ;;
    *)
      fail "WS_PATH 必须以 / 开头。"
      ;;
  esac
}

validate_uuid_if_present() {
  if [ -z "${UUID}" ]; then
    return 0
  fi

  case "${UUID}" in
    ????????-????-????-????-????????????)
      ;;
    *)
      fail "UUID 格式非法，必须符合 8-4-4-4-12 约定。"
      ;;
  esac
}

validate_numeric_port() {
  var_name=$1
  var_value=$2

  if [ -n "${var_value}" ]; then
    case "${var_value}" in
      *[!0-9]*)
        fail "${var_name} 必须是数字。"
        ;;
    esac
  fi
}

port_busy() {
  port=$1

  if command -v ss >/dev/null 2>&1; then
    ss -ltn "( sport = :${port} )" 2>/dev/null | tail -n +2 | grep -q .
    return
  fi

  if command -v lsof >/dev/null 2>&1; then
    lsof -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1
    return
  fi

  if command -v netstat >/dev/null 2>&1; then
    netstat -ltn 2>/dev/null | awk '{print $4}' | grep -Eq "[.:]${port}$"
    return
  fi

  fail "无法检查端口占用，请安装 ss、lsof 或 netstat。"
}

check_port_available() {
  port=$1

  if port_busy "${port}"; then
    fail "端口 ${port} 已被占用。"
  fi
}

detect_compose_command() {
  if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    export COMPOSE_CMD
    return 0
  fi

  if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
    export COMPOSE_CMD
    return 0
  fi

  fail "缺少 docker compose / docker-compose。"
}

compose() {
  detect_compose_command
  ${COMPOSE_CMD} -f "${COMPOSE_FILE}" "$@"
}

validate_base_env() {
  validate_profile
  validate_domain
  validate_ws_path
  validate_uuid_if_present
  validate_numeric_port "XRAY_PORT" "${XRAY_PORT}"
  validate_numeric_port "CADDY_HTTP_PORT" "${CADDY_HTTP_PORT}"
  validate_numeric_port "CADDY_HTTPS_PORT" "${CADDY_HTTPS_PORT}"
  validate_numeric_port "CADDY_ADMIN_PORT" "${CADDY_ADMIN_PORT}"

  if [ "${PROFILE}" = "ws-tls" ]; then
    require_non_empty "TLS_EMAIL" "${TLS_EMAIL}"
    require_non_empty "XRAY_IMAGE" "${XRAY_IMAGE}"
    require_non_empty "CADDY_IMAGE" "${CADDY_IMAGE}"
  fi
}

template_profile_dir() {
  template_kind=$1
  echo "${TEMPLATE_DIR}/${template_kind}/${PROFILE}"
}

assert_profile_templates() {
  transport_dir=$(template_profile_dir transport)
  proxy_dir=$(template_profile_dir proxy)

  [ -d "${transport_dir}" ] || fail "缺少 transport 模板目录: ${transport_dir}"
  [ -d "${proxy_dir}" ] || fail "缺少 proxy 模板目录: ${proxy_dir}"
}

template_vars_sed_args() {
  cat <<EOF
s|{{PROFILE}}|${PROFILE}|g
s|{{DOMAIN}}|${DOMAIN}|g
s|{{UUID}}|${UUID}|g
s|{{WS_PATH}}|${WS_PATH}|g
s|{{NODE_NAME}}|${NODE_NAME}|g
s|{{XRAY_PORT}}|${XRAY_PORT}|g
s|{{TLS_MODE}}|${TLS_MODE}|g
s|{{XRAY_IMAGE}}|${XRAY_IMAGE}|g
s|{{CADDY_IMAGE}}|${CADDY_IMAGE}|g
s|{{TLS_EMAIL}}|${TLS_EMAIL}|g
s|{{TLS_CA}}|${TLS_CA}|g
s|{{CADDY_HTTP_PORT}}|${CADDY_HTTP_PORT}|g
s|{{CADDY_HTTPS_PORT}}|${CADDY_HTTPS_PORT}|g
s|{{CADDY_ADMIN_PORT}}|${CADDY_ADMIN_PORT}|g
s|{{XRAY_LOG_LEVEL}}|${XRAY_LOG_LEVEL}|g
s|{{ENABLE_FAKE_SITE}}|${ENABLE_FAKE_SITE}|g
EOF
}

render_template_file() {
  template_path=$1
  output_path=$2

  sed -f - "${template_path}" > "${output_path}" <<EOF
$(template_vars_sed_args)
EOF
}

render_template_dir() {
  source_dir=$1
  output_prefix=$2

  find "${source_dir}" -maxdepth 1 -type f -name '*.tpl' | sort | while read -r template; do
    base_name=$(basename "${template}" .tpl)
    render_template_file "${template}" "${RUNTIME_DIR}/${output_prefix}-${base_name}"
  done
}

show_runtime_paths() {
  echo "runtime_dir=${RUNTIME_DIR}"
  echo "xray_config=${RUNTIME_DIR}/transport-xray.json"
  echo "caddy_config=${RUNTIME_DIR}/proxy-Caddyfile"
  echo "site_index=${RUNTIME_DIR}/proxy-index.html"
  echo "client_export=${EXPORT_DIR}/vless-ws-tls.txt"
  echo "xray_logs=${LOG_DIR}/xray"
  echo "caddy_logs=${LOG_DIR}/caddy"
}
