#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

EXPORT_FILE="${EXPORT_DIR}/client-placeholder.txt"

ensure_directories
load_env_file
validate_base_env

if [ "${PROFILE}" = "ws-tls" ]; then
  EXPORT_FILE="${EXPORT_DIR}/vless-ws-tls.txt"
  cat > "${EXPORT_FILE}" <<EOF
vless://${UUID}@${DOMAIN}:${CADDY_HTTPS_PORT}?encryption=none&security=tls&type=ws&host=${DOMAIN}&path=${WS_PATH}&sni=${DOMAIN}#${NODE_NAME}
EOF
else
  cat > "${EXPORT_FILE}" <<EOF
Phase 1A placeholder export
profile=${PROFILE}
domain=${DOMAIN}
node_name=${NODE_NAME}

当前 profile 暂未实现具体客户端导出格式。
EOF
fi

echo "[OK] 已生成占位导出文件: ${EXPORT_FILE}"
