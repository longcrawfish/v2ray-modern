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
echo "primary_service=${PRIMARY_SERVICE_NAME}"
echo "compose=${COMPOSE_CMD}"
echo

echo "[INFO] 关键配置路径"
show_runtime_paths
echo

echo "[INFO] 配置文件存在性"
for target in \
  "${RUNTIME_DIR}/transport-xray.json" \
  "${RUNTIME_DIR}/proxy-Caddyfile" \
  "${RUNTIME_DIR}/proxy-index.html"
do
  if [ -f "${target}" ]; then
    echo "[OK] ${target}"
  else
    echo "[WARN] 缺少 ${target}"
  fi
done
echo

echo "[INFO] 容器状态"
if ! compose ps; then
  log_warn "无法读取 compose 状态，请检查 Docker daemon 或当前用户的 Docker 权限。"
fi

echo
echo "[INFO] 日志目录"
echo "${LOG_DIR}"
find "${LOG_DIR}" -mindepth 1 -maxdepth 2 -type f | sort || true

echo "[INFO] 运行时目录"
find "${RUNTIME_DIR}" -maxdepth 1 -type f | sort || true

echo
echo "[INFO] 导出目录"
find "${EXPORT_DIR}" -maxdepth 2 -type f | sort || true

echo
echo "[INFO] 常用排障命令"
echo "查看 compose 日志:"
echo "  ${COMPOSE_CMD} -f ${COMPOSE_FILE} logs --tail=100 caddy xray"
echo "查看实时日志:"
echo "  ${COMPOSE_CMD} -f ${COMPOSE_FILE} logs -f caddy xray"
echo "查看环境变量:"
echo "  bash scripts/show-env.sh"
echo "查看渲染配置:"
echo "  bash scripts/show-config.sh"
echo "进入运行目录核对渲染文件:"
echo "  ls -la ${RUNTIME_DIR}"
echo "检查导出目录:"
echo "  ls -la ${EXPORT_DIR}"
echo "检查日志目录:"
echo "  ls -la ${LOG_DIR}"
echo
echo "[INFO] 常见问题定位建议"
echo "1. 若 TLS 未签发成功，先确认 DOMAIN 是否解析到当前服务器，且 80/443 未被防火墙拦截。"
echo "2. 若 WebSocket 无法连接，先确认 WS_PATH 与 ws-tls 导出的 clash.yaml / vless.txt 完全一致。"
echo "3. 若 reality 无法连接，先确认 REALITY_SERVER_NAME、REALITY_PUBLIC_KEY、REALITY_SHORT_ID、FLOW 与导出文件一致。"
echo "4. 若容器未启动，先运行 bash scripts/show-config.sh 检查渲染后的 Xray/Caddy 配置。"
