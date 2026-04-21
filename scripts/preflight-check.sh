#!/usr/bin/env bash

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
ENV_FILE="${ROOT_DIR}/.env"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] 缺少命令: $1" >&2
    exit 1
  fi
}

load_env() {
  if [ -f "${ENV_FILE}" ]; then
    # shellcheck disable=SC1090
    . "${ENV_FILE}"
  else
    echo "[WARN] 未找到 .env，将使用环境变量或脚本默认值。"
  fi
}

validate_uuid() {
  case "${UUID:-}" in
    "" )
      echo "[WARN] UUID 未设置，当前仅保留占位值。"
      ;;
    ????????-????-????-????-????????????)
      ;;
    * )
      echo "[ERROR] UUID 格式不符合 8-4-4-4-12 约定。" >&2
      exit 1
      ;;
  esac
}

validate_domain() {
  if [ -z "${DOMAIN:-}" ]; then
    echo "[WARN] DOMAIN 未设置，后续 transport 分支可能无法正常工作。"
  fi
}

validate_port() {
  case "${XRAY_PORT:-}" in
    "" )
      echo "[WARN] XRAY_PORT 未设置，将由 compose 使用默认值。"
      ;;
    *[!0-9]* )
      echo "[ERROR] XRAY_PORT 必须是数字。" >&2
      exit 1
      ;;
    * )
      :
      ;;
  esac
}

mkdir -p "${ROOT_DIR}/data/runtime" "${ROOT_DIR}/data/exports" "${ROOT_DIR}/data/logs"

require_command docker
load_env
validate_domain
validate_uuid
validate_port

if docker compose version >/dev/null 2>&1; then
  echo "[OK] docker compose 可用"
elif command -v docker-compose >/dev/null 2>&1; then
  echo "[WARN] 检测到 docker-compose，建议升级到 docker compose"
else
  echo "[ERROR] 缺少 docker compose / docker-compose" >&2
  exit 1
fi

echo "[OK] 基础检查完成"
