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

if [ -f "${EXPORT_DIR}/vless-ws-tls.txt" ]; then
  echo
  echo "[INFO] 客户端导出"
  sed -n '1,20p' "${EXPORT_DIR}/vless-ws-tls.txt"
fi
