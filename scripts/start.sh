#!/usr/bin/env bash

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)

"${ROOT_DIR}/scripts/preflight-check.sh"
"${ROOT_DIR}/scripts/render-config.sh"

if [ ! -f "${ROOT_DIR}/.env" ]; then
  cp "${ROOT_DIR}/.env.example" "${ROOT_DIR}/.env"
  echo "[WARN] 未找到 .env，已从 .env.example 生成默认副本。"
fi

docker compose -f "${ROOT_DIR}/compose.yaml" up -d

echo "[OK] compose 服务已启动"
echo "使用以下命令查看状态:"
echo "  bash scripts/status.sh"
