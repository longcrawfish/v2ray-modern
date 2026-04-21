# Phase 1A `v2-ws-tls` 分支说明

## 目标

本分支在 `refactor-base` 底座之上实现：

- Xray
- VLESS
- WebSocket
- TLS

同时保持新的模板化、脚本化、compose-first 结构，不回退到旧式单体启动脚本。

---

## 运行结构

### `xray`

- 负责 VLESS + WS 入站
- 配置来源：`data/runtime/transport-xray.json`
- 日志目录：`data/logs/xray/`

### `caddy`

- 负责 80/443 入口
- 负责自动 TLS
- 负责将 `WS_PATH` 请求反代到 `xray`
- 配置来源：`data/runtime/proxy-Caddyfile`
- 日志目录：`data/logs/caddy/`

---

## 模板文件

- `templates/transport/ws-tls/xray.json.tpl`
- `templates/transport/ws-tls/client.json.tpl`
- `templates/proxy/ws-tls/Caddyfile.tpl`
- `templates/proxy/ws-tls/index.html.tpl`

---

## 关键参数

| 变量 | 说明 |
|------|------|
| `PROFILE` | 固定为 `ws-tls` |
| `DOMAIN` | 域名，供 TLS 与 SNI 使用 |
| `UUID` | VLESS 客户端认证 UUID |
| `WS_PATH` | WebSocket 路径 |
| `NODE_NAME` | 节点名称，用于导出与标签 |
| `XRAY_PORT` | Xray 容器内部监听端口 |
| `TLS_MODE` | 当前用于 Caddy 全局 TLS 模式占位，建议 `acme` |
| `TLS_EMAIL` | Caddy ACME 邮箱 |
| `TLS_CA` | ACME CA 地址 |
| `CADDY_HTTP_PORT` | 外部 HTTP 端口 |
| `CADDY_HTTPS_PORT` | 外部 HTTPS 端口 |

---

## 启动流程

```bash
cp .env.example .env
bash scripts/start.sh
bash scripts/status.sh
```

启动时会依次执行：

1. 参数与端口检查
2. 配置模板渲染
3. `docker compose up -d`

---

## 导出

执行：

```bash
bash scripts/export-client.sh
```

会生成：

- `data/exports/vless-ws-tls.txt`

内容为基础 VLESS URL，便于一键复制。

---

## 已知限制

- 当前仅实现单节点、单入站
- TLS 由 Caddy 自动签发，要求域名已正确解析到服务器
- 尚未提供多客户端、多路由或管理面板能力
- `reality` 仍在独立分支实现，不应与本分支耦合
