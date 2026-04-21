# v2ray-modern（Phase 1A）

> 面向长期维护的部署底座重构项目。

当前仓库处于 Phase 1A transport 分支落地阶段。目标是在 `refactor-base` 公共底座之上，分别实现独立的 `ws-tls` 与 `reality` transport。

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
git checkout v2-reality
```

### 2. 初始化环境变量

```bash
cp .env.example .env
```

示例：

```env
PROFILE=reality
DOMAIN=example.com
UUID=00000000-0000-4000-8000-000000000000
NODE_NAME=default-node
XRAY_PORT=443
TLS_MODE=reality
XRAY_IMAGE=teddysun/xray:latest
XRAY_LOG_LEVEL=warning
REALITY_SERVER_NAME=www.cloudflare.com
REALITY_DEST=www.cloudflare.com:443
REALITY_PRIVATE_KEY=REPLACE_WITH_PRIVATE_KEY
REALITY_PUBLIC_KEY=REPLACE_WITH_PUBLIC_KEY
REALITY_SHORT_ID=0123abcd
REALITY_FINGERPRINT=chrome
REALITY_SPIDER_X=/
REALITY_FLOW=xtls-rprx-vision
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

对于 `v2-reality`，该命令会导出可直接使用的 VLESS REALITY 链接。

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

## `v2-reality` 使用说明

适用场景：

- 不希望依赖反向代理层
- 不希望依赖传统 TLS 证书签发
- 需要单端口、较直接的 Reality 部署方式

与 `v2-ws-tls` 的定位差异：

- `v2-ws-tls` 面向“域名 + 443 + 反向代理 + TLS”体验
- `v2-reality` 面向“无反向代理、无 WebSocket、无传统证书”的独立 transport

运行结构：

- 仅使用 `xray` 服务
- 配置渲染到 `data/runtime/transport-xray.json`
- 不使用 `WS_PATH`
- 不依赖 Caddy

关键输出：

- Xray 配置：`data/runtime/transport-xray.json`
- 客户端配置摘要：`data/runtime/transport-client.json`
- 客户端导出：`data/exports/vless-reality.txt`
- 生成密钥文件：`data/runtime/reality-generated.env`

Reality 密钥生成：

```bash
bash scripts/generate-reality-keys.sh
```

---

## 当前边界

- `v2-reality` 已实现 Xray + VLESS + REALITY
- 不继承 `ws-tls` 的 WS 路径、Caddy 和证书依赖
- 配置体系仍复用 `refactor-base` 的参数加载、模板渲染和脚本框架
- 旧 `Dockerfile`、`caddy.sh`、`v2ray.json`、`v2ray.js` 仍保留用于迁移参考

---

## 文档

- [Phase 1A 审计结论](doc/phase1a-audit.md)
- [Phase 1A 重构备注](doc/phase1a-refactor-notes.md)
- [Phase 1A 底座结构说明](doc/phase1a-refactor-structure.md)
- [Phase 1A 参数系统与模板渲染框架](doc/phase1a-config-system.md)
- [Phase 1A 运行时与启动流程](doc/phase1a-runtime.md)
- [Phase 1A `v2-reality` 分支说明](doc/phase1a-reality.md)

---

## 后续方向

- 将旧脚本中的配置正文迁移为真正可复用模板
- 为底座补齐统一参数加载和错误提示
- 在 transport 分支中分别接入具体协议实现
