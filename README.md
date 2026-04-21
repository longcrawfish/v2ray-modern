# v2ray-modern（Phase 1A）

> 面向长期维护的部署底座重构项目。

当前仓库处于 Phase 1A 第一轮底座重构阶段。目标不是直接扩展协议，而是先把老的一键部署项目拆成可维护的目录结构、参数系统、模板系统和 compose-first 启动链路。

---

## 分支策略

| 分支 | 角色 |
|------|------|
| `master` | 兼容基线，保留旧实现与迁移参考 |
| `refactor-base` | 公共底座分支，只做结构、参数、模板、compose、CLI |
| `v2-ws-tls` | 在底座之上实现 WS + TLS transport |
| `v2-reality` | 在底座之上实现 Reality transport |

约束：
- `refactor-base` 不引入 Xray / VLESS / REALITY 具体逻辑
- `refactor-base` 不写死 `ws`、`reality`、固定路径或代理依赖
- transport 相关实现只进入对应分支

当前建议的开发顺序：

1. 在 `refactor-base` 完成公共底座
2. 在 `v2-ws-tls` 填充 WS + TLS transport 实现
3. 在 `v2-reality` 填充 Reality transport 实现

---

## 当前结构

```text
.
├── compose.yaml
├── .env.example
├── scripts/
│   ├── preflight-check.sh
│   ├── render-config.sh
│   ├── start.sh
│   ├── status.sh
│   └── export-client.sh
├── templates/
│   ├── core/
│   ├── transport/
│   └── proxy/
├── data/
│   ├── runtime/
│   ├── exports/
│   └── logs/
└── doc/
```

说明：
- `scripts/` 只承载原子化流程，不直接写协议配置正文
- `templates/` 提供模板目录骨架，当前仅为占位内容
- `data/` 统一承接运行时产物、导出产物和日志目录
- `compose.yaml` 已替代旧式长 `docker run` 作为第一入口

---

## 从旧命令到 compose-first

旧项目依赖类似以下长命令直接拉起容器：

```bash
sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy pengchujin/v2ray_ws:0.11 YOURDOMAIN.COM V2RAY_WS
```

Phase 1A 第一轮改为：

```bash
cp .env.example .env
bash scripts/start.sh
```

这一步的意义是先统一启动入口、配置入口和目录契约。本轮不要求最终协议配置可用。

---

## 使用方式

### 1. 克隆并切换分支

```bash
git clone https://github.com/longcrawfish/v2ray-modern.git
cd v2ray-modern
git checkout v2-ws-tls
```

### 2. 初始化环境变量

```bash
cp .env.example .env
```

示例：

```env
PROFILE=ws-tls
DOMAIN=example.com
UUID=00000000-0000-4000-8000-000000000000
WS_PATH=/transport-path
NODE_NAME=default-node
XRAY_PORT=10000
TLS_MODE=acme
TLS_EMAIL=admin@example.com
TLS_CA=https://acme-v02.api.letsencrypt.org/directory
CADDY_HTTP_PORT=80
CADDY_HTTPS_PORT=443
CADDY_ADMIN_PORT=2019
XRAY_IMAGE=teddysun/xray:latest
CADDY_IMAGE=caddy:2.8-alpine
XRAY_LOG_LEVEL=warning
ENABLE_FAKE_SITE=true
```

### 3. 执行基础检查

```bash
bash scripts/preflight-check.sh
```

### 4. 渲染底座配置

```bash
bash scripts/render-config.sh
```

### 5. 启动 compose 服务

```bash
bash scripts/start.sh
```

启动脚本会自动执行：

1. 基础预检
2. 模板渲染
3. `docker compose up -d`

### 6. 查看状态

```bash
bash scripts/status.sh
```

状态命令会输出：

- 容器状态
- `data/logs/` 日志目录
- `data/runtime/` 渲染配置目录
- `data/exports/` 导出目录
- 常用排障命令提示

### 7. 生成导出占位文件

```bash
bash scripts/export-client.sh
```

对于 `v2-ws-tls`，该命令会导出可直接使用的 VLESS URL。

---

## 脚本职责

| 脚本 | 职责 |
|------|------|
| `scripts/preflight-check.sh` | 检查 Docker / Compose 和公共参数 |
| `scripts/render-config.sh` | 将模板渲染到 `data/runtime/` |
| `scripts/start.sh` | 串联检查、渲染和 compose 启动 |
| `scripts/status.sh` | 查看运行时文件与服务状态 |
| `scripts/export-client.sh` | 预留客户端导出流程 |

---

## 参数与模板系统

- 统一从 `.env` 加载参数，缺失时直接报错
- `PROFILE` 当前作为模板路由键，允许值为 `ws-tls`、`reality`
- `templates/core/` 存放公共模板
- `templates/transport/<profile>/` 存放 transport 插槽模板
- `templates/proxy/<profile>/` 存放 proxy 插槽模板
- `render-config.sh` 只负责变量注入和目录路由，不负责写协议实现

---

## `v2-ws-tls` 使用说明

适用场景：

- 希望保持“域名 + 443 + 一键启动”体验
- 可以使用反向代理层获取自动 TLS
- 需要基于 VLESS + WS + TLS 的常规部署方案

分支结构：

- `xray` 负责 VLESS + WS
- `caddy` 负责 TLS 和 WebSocket 反代
- 所有配置均由模板渲染到 `data/runtime/`

启动步骤：

```bash
cp .env.example .env
bash scripts/start.sh
bash scripts/status.sh
bash scripts/export-client.sh
```

关键输出：

- Xray 配置：`data/runtime/transport-xray.json`
- Caddy 配置：`data/runtime/proxy-Caddyfile`
- 静态站点：`data/runtime/proxy-index.html`
- 客户端导出：`data/exports/vless-ws-tls.txt`

---

## 当前边界

- 本轮只完成公共底座骨架
- 模板目录已建立，且支持按 profile 选择占位模板
- compose 已成为统一入口，服务名和日志目录已经标准化
- `v2-ws-tls` 分支已实现 Xray + VLESS + WS + TLS
- `reality` 仍留在独立分支实现
- 旧 `Dockerfile`、`caddy.sh`、`v2ray.json`、`v2ray.js` 仍保留用于迁移参考

---

## 文档

- [Phase 1A 审计结论](doc/phase1a-audit.md)
- [Phase 1A 重构备注](doc/phase1a-refactor-notes.md)
- [Phase 1A 底座结构说明](doc/phase1a-refactor-structure.md)
- [Phase 1A 参数系统与模板渲染框架](doc/phase1a-config-system.md)
- [Phase 1A 运行时与启动流程](doc/phase1a-runtime.md)
- [Phase 1A `v2-ws-tls` 分支说明](doc/phase1a-ws-tls.md)

---

## 后续方向

- 将旧脚本中的配置正文迁移为真正可复用模板
- 为底座补齐统一参数加载和错误提示
- 在 transport 分支中分别接入具体协议实现
