#!/usr/bin/env bash

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
ENV_FILE="${ROOT_DIR}/.env"
RUNTIME_DIR="${ROOT_DIR}/data/runtime"

PROFILE=${PROFILE:-base}
DOMAIN=${DOMAIN:-example.com}
UUID=${UUID:-00000000-0000-4000-8000-000000000000}
WS_PATH=${WS_PATH:-/replace-me}
NODE_NAME=${NODE_NAME:-default-node}
XRAY_PORT=${XRAY_PORT:-443}
TLS_MODE=${TLS_MODE:-auto}

if [ -f "${ENV_FILE}" ]; then
  # shellcheck disable=SC1090
  . "${ENV_FILE}"
fi

PROFILE=${PROFILE:-base}
DOMAIN=${DOMAIN:-example.com}
UUID=${UUID:-00000000-0000-4000-8000-000000000000}
WS_PATH=${WS_PATH:-/replace-me}
NODE_NAME=${NODE_NAME:-default-node}
XRAY_PORT=${XRAY_PORT:-443}
TLS_MODE=${TLS_MODE:-auto}

mkdir -p "${RUNTIME_DIR}"

render_template() {
  template_path=$1
  output_path=$2

  sed \
    -e "s|{{PROFILE}}|${PROFILE}|g" \
    -e "s|{{DOMAIN}}|${DOMAIN}|g" \
    -e "s|{{UUID}}|${UUID}|g" \
    -e "s|{{WS_PATH}}|${WS_PATH}|g" \
    -e "s|{{NODE_NAME}}|${NODE_NAME}|g" \
    -e "s|{{XRAY_PORT}}|${XRAY_PORT}|g" \
    -e "s|{{TLS_MODE}}|${TLS_MODE}|g" \
    "${template_path}" > "${output_path}"
}

render_template "${ROOT_DIR}/templates/core/base.env.tpl" "${RUNTIME_DIR}/base.env"
render_template "${ROOT_DIR}/templates/core/manifest.json.tpl" "${RUNTIME_DIR}/manifest.json"
render_template "${ROOT_DIR}/templates/transport/transport-placeholder.tpl" "${RUNTIME_DIR}/transport.conf"
render_template "${ROOT_DIR}/templates/proxy/proxy-placeholder.tpl" "${RUNTIME_DIR}/proxy.conf"

echo "[OK] 已生成运行时占位配置:"
echo "  - ${RUNTIME_DIR}/base.env"
echo "  - ${RUNTIME_DIR}/manifest.json"
echo "  - ${RUNTIME_DIR}/transport.conf"
echo "  - ${RUNTIME_DIR}/proxy.conf"
