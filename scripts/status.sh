#!/usr/bin/env bash

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)

echo "[INFO] 运行时目录"
find "${ROOT_DIR}/data/runtime" -maxdepth 1 -type f | sort || true

echo
echo "[INFO] 导出目录"
find "${ROOT_DIR}/data/exports" -maxdepth 1 -type f | sort || true

echo
echo "[INFO] compose 状态"
docker compose -f "${ROOT_DIR}/compose.yaml" ps
