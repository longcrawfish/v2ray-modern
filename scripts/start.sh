#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

"${ROOT_DIR}/scripts/preflight-check.sh"
"${ROOT_DIR}/scripts/render-config.sh"

compose up -d

echo "[OK] compose 服务已启动"
echo "主服务: ${SERVICE_NAME}"
echo "订阅服务: ${SUBSCRIPTION_SERVICE_NAME}"
echo "运行目录: ${RUNTIME_DIR}"
echo "日志目录: ${LOG_DIR}"
echo "使用以下命令查看状态:"
echo "  bash scripts/status.sh"
