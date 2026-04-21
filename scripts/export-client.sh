#!/usr/bin/env bash

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
ENV_FILE="${ROOT_DIR}/.env"
EXPORT_FILE="${ROOT_DIR}/data/exports/client-placeholder.txt"

PROFILE=${PROFILE:-base}
DOMAIN=${DOMAIN:-example.com}
NODE_NAME=${NODE_NAME:-default-node}

if [ -f "${ENV_FILE}" ]; then
  # shellcheck disable=SC1090
  . "${ENV_FILE}"
fi

PROFILE=${PROFILE:-base}
DOMAIN=${DOMAIN:-example.com}
NODE_NAME=${NODE_NAME:-default-node}

mkdir -p "${ROOT_DIR}/data/exports"

cat > "${EXPORT_FILE}" <<EOF
Phase 1A refactor-base placeholder export
profile=${PROFILE}
domain=${DOMAIN}
node_name=${NODE_NAME}

当前分支只提供导出流程占位，不生成具体协议链接。
EOF

echo "[OK] 已生成占位导出文件: ${EXPORT_FILE}"
