#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

tmp_output=$(mktemp)
trap 'rm -f "${tmp_output}"' EXIT

ensure_directories
load_env_file
require_command docker
require_command openssl

if ! docker run --rm "${XRAY_IMAGE}" x25519 > "${tmp_output}" 2>/dev/null; then
  fail "无法通过 ${XRAY_IMAGE} 生成 REALITY 密钥，请确认 Docker 可用且镜像可以正常拉取。"
fi

private_key=$(sed -n 's/^Private key: //p' "${tmp_output}")
public_key=$(sed -n 's/^Public key: //p' "${tmp_output}")
short_id=$(openssl rand -hex 8)

require_non_empty "REALITY_PRIVATE_KEY" "${private_key}"
require_non_empty "REALITY_PUBLIC_KEY" "${public_key}"
require_non_empty "REALITY_SHORT_ID" "${short_id}"

cat > "${GENERATED_REALITY_ENV}" <<EOF
REALITY_PRIVATE_KEY=${private_key}
REALITY_PUBLIC_KEY=${public_key}
REALITY_SHORT_ID=${short_id}
EOF

echo "[OK] 已生成 REALITY 密钥材料: ${GENERATED_REALITY_ENV}"
