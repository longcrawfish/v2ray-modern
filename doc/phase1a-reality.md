# Phase 1A `v2-reality` 分支说明

## 目标

本分支在 `refactor-base` 底座之上实现：

- Xray
- VLESS
- REALITY

该分支被视为独立 transport profile，不继承 `ws-tls` 的 WebSocket、Caddy 或传统 TLS 证书依赖。

---

## 运行结构

### `xray`

- 唯一运行服务
- 负责 VLESS + REALITY 入站
- 配置来源：`data/runtime/transport-xray.json`
- 日志目录：`data/logs/xray/`

### 代理层

- 本分支不依赖反向代理层
- 不需要 Caddy
- 不需要传统 TLS 证书签发流程

---

## 模板文件

- `templates/transport/reality/xray.json.tpl`
- `templates/transport/reality/client.json.tpl`
- `templates/proxy/reality/runtime-note.tpl`

---

## 关键参数

| 变量 | 说明 |
|------|------|
| `PROFILE` | 固定为 `reality` |
| `DOMAIN` | 客户端连接用的服务器域名或 IP |
| `UUID` | VLESS 客户端认证 UUID |
| `NODE_NAME` | 节点名称 |
| `XRAY_PORT` | Xray 对外监听端口 |
| `REALITY_SERVER_NAME` | Reality 使用的目标域名 |
| `REALITY_DEST` | Reality 目标地址，格式 `host:port` |
| `REALITY_PRIVATE_KEY` | 服务端私钥 |
| `REALITY_PUBLIC_KEY` | 提供给客户端的公钥 |
| `REALITY_SHORT_ID` | 客户端 short id |
| `REALITY_FINGERPRINT` | 客户端指纹，默认可用 `chrome` |
| `REALITY_SPIDER_X` | Reality spiderX |
| `REALITY_FLOW` | 通常为 `xtls-rprx-vision` |

---

## 密钥生成

如果 `.env` 中没有填写完整的：

- `REALITY_PRIVATE_KEY`
- `REALITY_PUBLIC_KEY`
- `REALITY_SHORT_ID`

可以执行：

```bash
bash scripts/generate-reality-keys.sh
```

脚本会使用 `XRAY_IMAGE` 调用 `xray x25519` 生成密钥，并把结果写入：

- `data/runtime/reality-generated.env`

随后 `render-config.sh` 会自动加载该文件。

---

## 启动流程

```bash
cp .env.example .env
bash scripts/preflight-check.sh
bash scripts/render-config.sh
bash scripts/start.sh
bash scripts/status.sh
bash scripts/export-client.sh
```

---

## 与 `v2-ws-tls` 的差异

- `v2-reality` 不使用 WebSocket
- `v2-reality` 不需要 `WS_PATH`
- `v2-reality` 不依赖 Caddy 或其他反向代理
- `v2-reality` 不依赖传统 TLS 证书申请
- `v2-reality` 的关键材料是 Reality 密钥和目标站点参数

---

## 已知限制

- 当前为单节点、单入站实现
- 密钥自动生成依赖 Docker 和 `XRAY_IMAGE`
- 尚未覆盖多用户、多入站、多路由策略
