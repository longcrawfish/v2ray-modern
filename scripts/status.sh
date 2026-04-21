#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

echo "[INFO] 运行时目录"
find "${RUNTIME_DIR}" -maxdepth 1 -type f | sort || true

echo
echo "[INFO] 导出目录"
find "${EXPORT_DIR}" -maxdepth 1 -type f | sort || true

echo
echo "[INFO] compose 状态"
docker compose -f "${ROOT_DIR}/compose.yaml" ps
