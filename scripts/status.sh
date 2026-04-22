#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib/common.sh"

ensure_directories
detect_compose_command
if ! load_env_if_present; then
  log_warn "未找到 .env，compose 状态可能出现变量默认值告警。"
fi

echo "[INFO] 服务信息"
echo "service=${SERVICE_NAME}"
echo "compose=${COMPOSE_CMD}"
echo

echo "[INFO] 容器状态"
if ! compose ps; then
  log_warn "无法读取 compose 状态，请检查 Docker daemon 或当前用户的 Docker 权限。"
fi

echo
echo "[INFO] 日志目录"
echo "${LOG_DIR}"
find "${LOG_DIR}" -maxdepth 1 -type f | sort || true

echo "[INFO] 运行时目录"
find "${RUNTIME_DIR}" -maxdepth 1 -type f | sort || true

echo
echo "[INFO] 导出目录"
find "${EXPORT_DIR}" -maxdepth 2 -type f | sort || true

echo
echo "[INFO] 常用排障命令"
echo "查看 compose 日志:"
echo "  ${COMPOSE_CMD} -f ${COMPOSE_FILE} logs --tail=100 ${SERVICE_NAME}"
echo "查看实时日志:"
echo "  ${COMPOSE_CMD} -f ${COMPOSE_FILE} logs -f ${SERVICE_NAME}"
echo "进入运行目录核对渲染文件:"
echo "  ls -la ${RUNTIME_DIR}"
echo "检查导出目录:"
echo "  ls -la ${EXPORT_DIR}"
echo "检查日志目录:"
echo "  ls -la ${LOG_DIR}"
