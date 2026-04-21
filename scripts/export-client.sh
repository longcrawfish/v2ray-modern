#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

EXPORT_FILE="${EXPORT_DIR}/client-placeholder.txt"

ensure_directories
load_env_file
validate_base_env

url_encode() {
  value=$1
  encoded=""
  i=0

  while [ "${i}" -lt "${#value}" ]; do
    ch=${value:${i}:1}
    case "${ch}" in
      [a-zA-Z0-9.~_-])
        encoded="${encoded}${ch}"
        ;;
      *)
        printf -v hex '%02X' "'${ch}"
        encoded="${encoded}%${hex}"
        ;;
    esac
    i=$((i + 1))
  done

  printf '%s' "${encoded}"
}

if [ "${PROFILE}" = "reality" ]; then
  EXPORT_FILE="${EXPORT_DIR}/vless-reality.txt"
  reality_link="vless://${UUID}@${DOMAIN}:${XRAY_PORT}?encryption=none&security=reality&pbk=$(url_encode "${REALITY_PUBLIC_KEY}")&headerType=none&fp=$(url_encode "${REALITY_FINGERPRINT}")&sni=$(url_encode "${REALITY_SERVER_NAME}")&sid=$(url_encode "${REALITY_SHORT_ID}")&type=tcp&flow=$(url_encode "${REALITY_FLOW}")&spx=$(url_encode "${REALITY_SPIDER_X}")#$(url_encode "${NODE_NAME}")"
  cat > "${EXPORT_FILE}" <<EOF
${reality_link}
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
