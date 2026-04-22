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
- 负责将 `/sub/*` 暴露为 Clash 订阅静态文件
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
| `SUBSCRIPTION_HOST` | 订阅说明中使用的域名，若复用内置 Caddy 建议与 `DOMAIN` 一致 |

---

## 启动流程

```bash
cp .env.example .env
bash scripts/show-env.sh
bash scripts/start.sh
bash scripts/status.sh
```

启动时会依次执行：

1. 参数与端口检查
2. 配置模板渲染
3. `docker compose up -d`

若 `SUBSCRIPTION_HOST=${DOMAIN}`，启动完成后可直接导入：

```text
https://${DOMAIN}/sub/ws-tls/clash.yaml
```

---

## 部署前检查事项

- `DOMAIN` 已经解析到目标服务器公网 IP
- `CADDY_HTTP_PORT` 和 `CADDY_HTTPS_PORT` 未被其他进程占用
- 防火墙和安全组已放行 80/443
- `UUID` 是合法 UUID
- `WS_PATH` 以 `/` 开头，且不要与网站其他路径冲突
- `TLS_EMAIL` 已填写可接收证书通知的邮箱
- `XRAY_IMAGE` 与 `CADDY_IMAGE` 可在当前环境拉取

---

## 自测建议

建议按以下顺序自测：

1. `bash scripts/preflight-check.sh`
2. `bash scripts/render-config.sh`
3. `bash scripts/show-config.sh`
4. `docker compose -f compose.yaml config`
5. `bash scripts/start.sh`
6. `bash scripts/status.sh`
7. `bash scripts/export-client.sh`

目标：

- 配置文件已渲染到 `data/runtime/`
- `xray` / `caddy` 的 volume 挂载路径与配置路径一致
- VLESS 导出链接与 `.env` 中的 `DOMAIN`、`WS_PATH`、`UUID` 一致
- `https://${DOMAIN}/sub/ws-tls/clash.yaml` 可由 Caddy 直接访问

---

## 常见错误

### 1. 域名填写成 URL

症状：
- Caddy 配置生成后站点地址异常

排查：
- `DOMAIN` 只能写 `example.com`
- 不能写 `https://example.com/path`

### 2. `WS_PATH` 没有以 `/` 开头

症状：
- 预检直接失败
- 或客户端连接路径错误

排查：
- 确保类似 `/ray`、`/transport-path`

### 3. 80/443 端口被占用

症状：
- `preflight-check.sh` 失败
- compose 启动后端口绑定失败

排查：
- 先释放端口
- 或调整 `.env` 中的 `CADDY_HTTP_PORT` / `CADDY_HTTPS_PORT`

### 4. TLS 未签发成功

症状：
- HTTPS 无法访问
- Caddy 日志出现 ACME 失败

排查：
- 检查域名解析
- 检查 80 端口是否可达
- 检查邮箱和 ACME CA 参数

### 5. WebSocket 连接失败

症状：
- 站点可打开，但代理连接失败

排查：
- `bash scripts/show-config.sh`
- 核对 `proxy-Caddyfile` 里的 `WS_PATH`
- 核对 `transport-xray.json` 里的 `wsSettings.path`
- 核对 `data/exports/ws-tls/vless.txt` 中的 `path`

### 6. Xray 容器报 `exec: "run": executable file not found`

症状：
- `bash scripts/start.sh` 在拉起 `xray` 容器时失败
- Docker 报错 `exec: "run": executable file not found in $PATH`

排查：
- 确认 `compose.yaml` 中 `xray` 服务显式使用 `xray run -c /etc/xray/config.json`
- 不要只把 `run` 当成容器启动命令传入，否则 Docker 会把它当成可执行文件

---

## 排障步骤

1. `bash scripts/show-env.sh`
确认实际载入的环境变量。

2. `bash scripts/show-config.sh`
确认 Xray 和 Caddy 渲染后的配置内容。

3. `bash scripts/status.sh`
确认容器状态、日志目录和关键路径。

4. `docker compose -f compose.yaml logs --tail=100 caddy xray`
查看最近日志。

5. `docker compose -f compose.yaml ps`
确认服务是否处于运行状态。

---

## 导出

执行：

```bash
bash scripts/export-client.sh
```

会生成：

- `data/exports/ws-tls/clash.yaml`
- `data/exports/ws-tls/vless.txt`
- `data/exports/ws-tls/clash-subscription-url.txt`

其中：

- `clash.yaml` 用于 Clash Verge Rev / ClashX Meta / Mihomo
- `vless.txt` 用于 v2rayNG 等支持 `vless://` 的客户端
- 若 `SUBSCRIPTION_HOST=${DOMAIN}`，可直接通过 `https://${DOMAIN}/sub/ws-tls/clash.yaml` 导入

---

## 已知限制

- 当前仅实现单节点、单入站
- TLS 由 Caddy 自动签发，要求域名已正确解析到服务器
- 尚未提供多客户端、多路由或管理面板能力
- `reality` 仍在独立分支实现，不应与本分支耦合
- 当前 healthcheck 仅检查配置文件存在，不代表完整链路已联通
