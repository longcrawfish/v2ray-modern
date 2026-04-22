#!/usr/bin/env bash

# Shared helpers for Phase 1A base scripts.

ROOT_DIR=$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
ENV_FILE="${ROOT_DIR}/.env"
RUNTIME_DIR="${ROOT_DIR}/data/runtime"
EXPORT_DIR="${ROOT_DIR}/data/exports"
LOG_DIR="${ROOT_DIR}/data/logs"
TEMPLATE_DIR="${ROOT_DIR}/templates"
EXPORT_TEMPLATE_DIR="${TEMPLATE_DIR}/export"
COMPOSE_FILE="${ROOT_DIR}/compose.yaml"
SERVICE_NAME="xray"
GENERATED_REALITY_ENV="${RUNTIME_DIR}/reality-generated.env"
RUNTIME_ENV_FILE="${RUNTIME_DIR}/core-base.env"

SUPPORTED_PROFILES="ws-tls reality"

ensure_directories() {
  mkdir -p "${RUNTIME_DIR}" "${EXPORT_DIR}" "${LOG_DIR}" "${LOG_DIR}/xray"
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

reality_material_missing() {
  material=$1

  case "${material}" in
    ""|REPLACE_WITH_*)
      return 0
      ;;
  esac

  return 1
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "缺少命令: $1"
  fi
}

docker_usable() {
  if ! command -v docker >/dev/null 2>&1; then
    return 1
  fi

  docker version >/dev/null 2>&1
}

can_generate_reality_material() {
  if command -v xray >/dev/null 2>&1; then
    return 0
  fi

  if command -v openssl >/dev/null 2>&1; then
    return 0
  fi

  if docker_usable; then
    return 0
  fi

  return 1
}

load_env_file() {
  if [ ! -f "${ENV_FILE}" ]; then
    fail "未找到 .env，请先执行 'cp .env.example .env' 并填写必要参数。"
  fi

  # shellcheck disable=SC1090
  . "${ENV_FILE}"
  load_generated_reality_env
  normalize_env
  export_loaded_env
}

load_generated_reality_env() {
  if [ -f "${GENERATED_REALITY_ENV}" ]; then
    # shellcheck disable=SC1090
    . "${GENERATED_REALITY_ENV}"
  fi
}

normalize_env() {
  PROFILE=${PROFILE:-}
  DOMAIN=${DOMAIN:-}
  UUID=${UUID:-}
  WS_PATH=${WS_PATH:-}
  NODE_NAME=${NODE_NAME:-}
  XRAY_PORT=${XRAY_PORT:-}
  TLS_MODE=${TLS_MODE:-}
  XRAY_IMAGE=${XRAY_IMAGE:-}
  XRAY_LOG_LEVEL=${XRAY_LOG_LEVEL:-}
  SERVER=${SERVER:-}
  PORT=${PORT:-}
  SUBSCRIPTION_SCHEME=${SUBSCRIPTION_SCHEME:-http}
  SUBSCRIPTION_HOST=${SUBSCRIPTION_HOST:-}
  SUBSCRIPTION_CADDY_IMAGE=${SUBSCRIPTION_CADDY_IMAGE:-caddy:2.8-alpine}
  SUBSCRIPTION_CADDY_PORT=${SUBSCRIPTION_CADDY_PORT:-18080}
  CLIENT_FINGERPRINT=${CLIENT_FINGERPRINT:-}
  SNI=${SNI:-}
  HOST=${HOST:-}
  REALITY_SERVER_NAME=${REALITY_SERVER_NAME:-}
  REALITY_DEST=${REALITY_DEST:-}
  REALITY_PRIVATE_KEY=${REALITY_PRIVATE_KEY:-}
  REALITY_PUBLIC_KEY=${REALITY_PUBLIC_KEY:-}
  REALITY_SHORT_ID=${REALITY_SHORT_ID:-}
  REALITY_FINGERPRINT=${REALITY_FINGERPRINT:-}
  REALITY_SPIDER_X=${REALITY_SPIDER_X:-}
  REALITY_FLOW=${REALITY_FLOW:-}
  FLOW=${FLOW:-}

  if [ -z "${CLIENT_FINGERPRINT}" ] && [ -n "${REALITY_FINGERPRINT}" ]; then
    CLIENT_FINGERPRINT=${REALITY_FINGERPRINT}
  fi

  if [ -z "${FLOW}" ] && [ -n "${REALITY_FLOW}" ]; then
    FLOW=${REALITY_FLOW}
  fi

  if [ -z "${REALITY_FINGERPRINT}" ] && [ -n "${CLIENT_FINGERPRINT}" ]; then
    REALITY_FINGERPRINT=${CLIENT_FINGERPRINT}
  fi

  if [ -z "${REALITY_FLOW}" ] && [ -n "${FLOW}" ]; then
    REALITY_FLOW=${FLOW}
  fi
}

export_loaded_env() {
  export PROFILE DOMAIN UUID WS_PATH NODE_NAME XRAY_PORT TLS_MODE XRAY_IMAGE XRAY_LOG_LEVEL SERVER PORT SUBSCRIPTION_SCHEME SUBSCRIPTION_HOST SUBSCRIPTION_CADDY_IMAGE SUBSCRIPTION_CADDY_PORT CLIENT_FINGERPRINT SNI HOST REALITY_SERVER_NAME REALITY_DEST REALITY_PRIVATE_KEY REALITY_PUBLIC_KEY REALITY_SHORT_ID REALITY_FINGERPRINT REALITY_SPIDER_X REALITY_FLOW FLOW
}

load_env_if_present() {
  if [ -f "${ENV_FILE}" ]; then
    # shellcheck disable=SC1090
    . "${ENV_FILE}"
    load_generated_reality_env
    normalize_env
    export_loaded_env
    return 0
  fi

  if [ -f "${GENERATED_REALITY_ENV}" ]; then
    load_generated_reality_env
    normalize_env
    export_loaded_env
    return 0
  fi

  return 1
}

supplement_env_from_runtime_file() {
  if [ ! -f "${RUNTIME_ENV_FILE}" ]; then
    return 0
  fi

  while IFS='=' read -r raw_key raw_value; do
    case "${raw_key}" in
      ''|\#*)
        continue
        ;;
    esac

    eval "current_value=\${${raw_key}:-}"
    if [ -n "${current_value}" ]; then
      continue
    fi

    normalized_value=${raw_value}
    normalized_value=${normalized_value#\"}
    normalized_value=${normalized_value%\"}
    printf -v "${raw_key}" '%s' "${normalized_value}"
    export "${raw_key}"
  done < "${RUNTIME_ENV_FILE}"

  normalize_env
  export_loaded_env
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
      fail "DOMAIN 只能填写纯域名或 IP，不能包含协议头或路径。"
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
  validate_uuid_if_present
  validate_numeric_port "XRAY_PORT" "${XRAY_PORT}"

  case "${PROFILE}" in
    ws-tls)
      validate_ws_tls_env
      ;;
    reality)
      validate_reality_env
      ;;
  esac
}

validate_ws_tls_env() {
  require_non_empty "WS_PATH" "${WS_PATH}"
}

validate_reality_env() {
  require_non_empty "REALITY_SERVER_NAME" "${REALITY_SERVER_NAME}"
  require_non_empty "REALITY_DEST" "${REALITY_DEST}"
  require_non_empty "REALITY_FINGERPRINT" "${REALITY_FINGERPRINT}"
  require_non_empty "REALITY_FLOW" "${REALITY_FLOW}"
  require_non_empty "XRAY_IMAGE" "${XRAY_IMAGE}"

  case "${REALITY_DEST}" in
    *:*)
      ;;
    *)
      fail "REALITY_DEST 必须为 host:port 格式。"
      ;;
  esac

  if [ -n "${REALITY_SHORT_ID}" ]; then
    case "${REALITY_SHORT_ID}" in
      REPLACE_WITH_*)
        ;;
      *[!0-9a-fA-F]*)
        fail "REALITY_SHORT_ID 必须是十六进制字符串。"
        ;;
    esac

    short_id_length=${#REALITY_SHORT_ID}
    if [ $((short_id_length % 2)) -ne 0 ]; then
      fail "REALITY_SHORT_ID 长度必须为偶数。"
    fi

    if [ "${short_id_length}" -gt 16 ]; then
      fail "REALITY_SHORT_ID 长度不能超过 16 个十六进制字符。"
    fi
  fi

  if reality_material_missing "${REALITY_PRIVATE_KEY}" || reality_material_missing "${REALITY_PUBLIC_KEY}" || reality_material_missing "${REALITY_SHORT_ID}"; then
    if can_generate_reality_material; then
      log_warn "REALITY 密钥材料不完整，将在渲染阶段尝试生成。"
      return 0
    fi

    fail "REALITY_PRIVATE_KEY / REALITY_PUBLIC_KEY / REALITY_SHORT_ID 缺失，且当前环境无法自动生成。可用生成方式: 本地 xray、openssl 或可访问的 Docker。"
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
s|{{XRAY_LOG_LEVEL}}|${XRAY_LOG_LEVEL}|g
s|{{SERVER}}|${SERVER}|g
s|{{PORT}}|${PORT}|g
s|{{SUBSCRIPTION_SCHEME}}|${SUBSCRIPTION_SCHEME}|g
s|{{SUBSCRIPTION_HOST}}|${SUBSCRIPTION_HOST}|g
s|{{SUBSCRIPTION_CADDY_IMAGE}}|${SUBSCRIPTION_CADDY_IMAGE}|g
s|{{SUBSCRIPTION_CADDY_PORT}}|${SUBSCRIPTION_CADDY_PORT}|g
s|{{CLIENT_FINGERPRINT}}|${CLIENT_FINGERPRINT}|g
s|{{SNI}}|${SNI}|g
s|{{HOST}}|${HOST}|g
s|{{REALITY_SERVER_NAME}}|${REALITY_SERVER_NAME}|g
s|{{REALITY_DEST}}|${REALITY_DEST}|g
s|{{REALITY_PRIVATE_KEY}}|${REALITY_PRIVATE_KEY}|g
s|{{REALITY_PUBLIC_KEY}}|${REALITY_PUBLIC_KEY}|g
s|{{REALITY_SHORT_ID}}|${REALITY_SHORT_ID}|g
s|{{REALITY_FINGERPRINT}}|${REALITY_FINGERPRINT}|g
s|{{REALITY_SPIDER_X}}|${REALITY_SPIDER_X}|g
s|{{REALITY_FLOW}}|${REALITY_FLOW}|g
s|{{FLOW}}|${FLOW}|g
EOF
}

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'
}

render_dollar_template_file() {
  template_path=$1
  output_path=$2
  shift 2

  sed_script=$(
    for var_name in "$@"; do
      eval "var_value=\${${var_name}:-}"
      escaped_value=$(escape_sed_replacement "${var_value}")
      printf 's|\\${%s}|%s|g\n' "${var_name}" "${escaped_value}"
    done
  )

  printf '%s\n' "${sed_script}" | sed -f - "${template_path}" > "${output_path}"
}

assert_no_dollar_placeholders() {
  target_file=$1

  if grep -n '\${[A-Z0-9_][A-Z0-9_]*}' "${target_file}" >/dev/null 2>&1; then
    log_error "模板渲染后仍存在未替换占位符: ${target_file}"
    grep -n '\${[A-Z0-9_][A-Z0-9_]*}' "${target_file}" >&2 || true
    exit 1
  fi
}

urlencode_utf8() {
  encoded=""

  for byte in $(printf '%s' "$1" | od -An -tx1 -v); do
    decimal=$((16#${byte}))

    if { [ "${decimal}" -ge 48 ] && [ "${decimal}" -le 57 ]; } ||
      { [ "${decimal}" -ge 65 ] && [ "${decimal}" -le 90 ]; } ||
      { [ "${decimal}" -ge 97 ] && [ "${decimal}" -le 122 ]; } ||
      [ "${decimal}" -eq 45 ] || [ "${decimal}" -eq 46 ] ||
      [ "${decimal}" -eq 95 ] || [ "${decimal}" -eq 126 ]; then
      printf -v chr '%b' "\\x${byte}"
      encoded="${encoded}${chr}"
    else
      upper_byte=$(printf '%s' "${byte}" | tr '[:lower:]' '[:upper:]')
      encoded="${encoded}%${upper_byte}"
    fi
  done

  printf '%s' "${encoded}"
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
