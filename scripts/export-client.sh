#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

EXPORT_FILE="${EXPORT_DIR}/client-placeholder.txt"

ensure_directories
load_env_file
validate_base_env

cat > "${EXPORT_FILE}" <<EOF
Phase 1A refactor-base placeholder export
profile=${PROFILE}
domain=${DOMAIN}
node_name=${NODE_NAME}

当前分支只提供导出流程占位，不生成具体协议链接。
EOF

echo "[OK] 已生成占位导出文件: ${EXPORT_FILE}"
