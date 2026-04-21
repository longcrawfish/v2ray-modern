#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

EXPORT_FILE="${EXPORT_DIR}/client-placeholder.txt"

ensure_directories
load_env_file
validate_base_env

if [ "${PROFILE}" = "reality" ]; then
  EXPORT_FILE="${EXPORT_DIR}/vless-reality.txt"
  cat > "${EXPORT_FILE}" <<EOF
vless://${UUID}@${DOMAIN}:${XRAY_PORT}?encryption=none&security=reality&pbk=${REALITY_PUBLIC_KEY}&fp=${REALITY_FINGERPRINT}&sni=${REALITY_SERVER_NAME}&sid=${REALITY_SHORT_ID}&type=tcp&flow=${REALITY_FLOW}&spx=${REALITY_SPIDER_X}#${NODE_NAME}
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
