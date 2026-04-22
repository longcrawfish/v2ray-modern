#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

load_env_file
validate_base_env

echo "[INFO] 关键配置路径"
show_runtime_paths

echo
echo "[INFO] Xray 配置"
sed -n '1,220p' "${RUNTIME_DIR}/transport-xray.json"

echo
echo "[INFO] Caddy 配置"
sed -n '1,220p' "${RUNTIME_DIR}/proxy-Caddyfile"

if [ -d "${EXPORT_DIR}/${PROFILE}" ]; then
  echo
  echo "[INFO] 客户端导出目录"
  find "${EXPORT_DIR}/${PROFILE}" -maxdepth 1 -type f | sort
fi
