#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

tmp_output=$(mktemp)
tmp_error=$(mktemp)
tmp_dir=
trap 'rm -f "${tmp_output}" "${tmp_error}"; if [ -n "${tmp_dir}" ]; then rm -rf "${tmp_dir}"; fi' EXIT

ensure_directories
load_env_file
require_command openssl

generate_with_xray_binary() {
  xray x25519 > "${tmp_output}" 2>"${tmp_error}"
}

generate_with_docker() {
  docker run --rm "${XRAY_IMAGE}" x25519 > "${tmp_output}" 2>"${tmp_error}"
}

generate_with_openssl() {
  tmp_dir=$(mktemp -d)

  private_der="${tmp_dir}/private.der"
  public_der="${tmp_dir}/public.der"
  private_pem="${tmp_dir}/private.pem"

  openssl genpkey -algorithm X25519 -out "${private_pem}" >/dev/null 2>"${tmp_error}"
  openssl pkey -in "${private_pem}" -outform DER -out "${private_der}" >/dev/null 2>>"${tmp_error}"
  openssl pkey -in "${private_pem}" -pubout -outform DER -out "${public_der}" >/dev/null 2>>"${tmp_error}"

  private_key=$(tail -c 32 "${private_der}" | openssl base64 -A | tr '+/' '-_' | tr -d '=')
  public_key=$(tail -c 32 "${public_der}" | openssl base64 -A | tr '+/' '-_' | tr -d '=')

  cat > "${tmp_output}" <<EOF
Private key: ${private_key}
Public key: ${public_key}
EOF
}

generation_method=
error_message=

if command -v xray >/dev/null 2>&1; then
  if generate_with_xray_binary; then
    generation_method="local xray"
  else
    error_message=$(cat "${tmp_error}")
  fi
fi

if [ -z "${generation_method}" ]; then
  if generate_with_openssl; then
    generation_method="openssl"
  else
    error_message=$(cat "${tmp_error}")
  fi
fi

if [ -z "${generation_method}" ] && docker_usable; then
  if generate_with_docker; then
    generation_method="docker image ${XRAY_IMAGE}"
  else
    error_message=$(cat "${tmp_error}")
  fi
fi

if [ -z "${generation_method}" ]; then
  if [ -z "${error_message}" ] && ! docker_usable && ! command -v xray >/dev/null 2>&1; then
    error_message="未检测到可用的本地 xray，且 Docker 不可访问。"
  fi

  fail "无法生成 REALITY 密钥。可用方式依次为: 本地 xray、openssl、Docker(${XRAY_IMAGE})。${error_message}"
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

echo "[OK] 已通过 ${generation_method} 生成 REALITY 密钥材料: ${GENERATED_REALITY_ENV}"
