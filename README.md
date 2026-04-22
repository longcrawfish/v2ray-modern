# v2ray-modern（Phase 1A）

> 一个面向长期维护的部署系统重构项目。

项目目标不是继续叠加一键脚本，而是建立一个可维护、可扩展、支持多 transport 的部署框架。Phase 1A 通过三条分支分别承载公共底座、`ws-tls` 实现和 `reality` 实现。

---

## 项目定位

从：

- 单体脚本
- 单协议配置
- 长 `docker run` 启动

演进为：

- profile 驱动
- template 渲染
- compose-first
- 原子脚本
- transport 分离

---

## 分支关系

| 分支 | 定位 | 适用场景 |
|------|------|----------|
| `master` | 兼容基线，保留旧实现与迁移参考 | 需要对照老项目行为时 |
| `refactor-base` | 公共底座，只提供参数、模板、compose、脚本框架 | 做底座演进、准备新 transport 时 |
| `v2-ws-tls` | 基于底座实现 `Xray + VLESS + WS + TLS` | 需要“域名 + 443 + 反向代理”体验时 |
| `v2-reality` | 基于底座实现 `Xray + VLESS + REALITY` | 不希望依赖 WebSocket、反向代理和传统证书时 |

约束：

- `refactor-base` 不引入协议细节
- transport-specific logic 只进入对应分支
- `v2-reality` 不继承 `v2-ws-tls` 的 `ws path` 和证书依赖
- `v2-reality` 中的 Caddy 仅用于静态订阅导出，不参与 Reality 主入口转发

---

## 基础结构

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
│   ├── export/
│   ├── transport/
│   └── proxy/
├── data/
│   ├── runtime/
│   ├── exports/
│   └── logs/
└── doc/
```

公共约定：

- `scripts/`：原子脚本入口
- `templates/`：模板源文件
- `data/runtime/`：渲染结果
- `data/exports/`：导出结果
- `data/logs/`：日志目录

`v2-reality` 分支补充约定：

- `xray` 继续独占 `XRAY_PORT`
- `subscription-caddy` 只负责暴露 `data/exports/` 下的 Clash 订阅文件
- `subscription-caddy` 使用独立端口 `SUBSCRIPTION_CADDY_PORT`

---
## 前期准备
1. 一台 VPS
2. 开放 443 端口
3. 安装 docker
4. 域名，解析到该 VPS
5. 域名不要开启CDN/ CloudFlare 橙云不要打开

## 基础使用方式

### 1. 克隆仓库

```bash
git clone https://github.com/longcrawfish/v2ray-modern.git
cd v2ray-modern
```

### 2. 切换目标分支

```bash
git checkout refactor-base
# 或
git checkout v2-ws-tls
# 或
git checkout v2-reality
```

### 3. 准备环境变量

```bash
cp .env.example .env
```

### 4. 标准执行流程

```bash
bash scripts/preflight-check.sh
bash scripts/render-config.sh
bash scripts/export-client.sh
bash scripts/start.sh
bash scripts/status.sh
```

说明：

- `preflight-check.sh` 负责环境和参数检查
- `render-config.sh` 负责按 `PROFILE` 渲染模板
- `export-client.sh` 负责导出客户端 YAML、订阅说明和 `vless://` 链接
- `start.sh` 负责标准启动
- `status.sh` 负责状态与排障信息输出

如果你需要直接由项目内 Caddy 提供 Clash 订阅 URL，推荐流程是：

```bash
bash scripts/render-config.sh
bash scripts/export-client.sh
bash scripts/start.sh
```

---

## 分支适用场景

### `refactor-base`

适合：

- 做底座演进
- 调整参数系统
- 重构模板框架
- 引入新 transport 前先搭公共能力

不适合：

- 直接写 `ws-tls` 或 `reality` 的协议细节

### `v2-ws-tls`

适合：

- 需要域名入口
- 需要 443 暴露体验
- 接受反向代理层
- 需要常规 VLESS + WS + TLS 方案

### `v2-reality`

适合：

- 不想依赖 WebSocket
- 不想依赖反向代理层
- 不想依赖传统证书签发
- 希望使用独立的 Reality transport

---

## 文档索引

- [分支策略](doc/branch-strategy.md)
- [Profile 设计](doc/profile-design.md)
- [Phase 1A 范围](doc/phase1a-scope.md)
- [Phase 1A 流程](doc/phase1a-flow.md)
- [Phase 1A 审计结论](doc/phase1a-audit.md)
- [Phase 1A 重构备注](doc/phase1a-refactor-notes.md)
- [Phase 1A 底座结构说明](doc/phase1a-refactor-structure.md)
- [Phase 1A 参数系统与模板渲染框架](doc/phase1a-config-system.md)
- [Phase 1A 运行时与启动流程](doc/phase1a-runtime.md)
- [Phase 1A `v2-ws-tls` 分支说明](doc/phase1a-ws-tls.md)
- [Phase 1A `v2-reality` 分支说明](doc/phase1a-reality.md)

---

## 核心概念

### profile

用于选择 transport 实现的配置槽位，例如 `ws-tls`、`reality`。

### template

位于 `templates/` 的源配置文件，通过变量渲染生成运行时配置。

### runtime

位于 `data/runtime/` 的渲染产物，是容器启动时真正使用的配置文件。

### export

位于 `data/exports/` 的导出结果，例如 Clash YAML、订阅说明和 `vless://` 链接。

## 客户端导出说明

项目会同时导出两类客户端配置：

1. Clash / Mihomo YAML
   - 用于 Clash Verge Rev、ClashX Meta、Mihomo 等客户端
   - 推荐通过 URL 方式导入 `clash.yaml`

2. `vless://` 链接
   - 用于 v2rayNG 等支持 Xray/VLESS 的客户端
   - 可直接复制导入

在 `v2-reality` 分支中，项目会额外启动一个 `subscription-caddy` 容器，把 `data/exports/` 暴露为静态订阅地址。
默认示例：

```text
http://sub.example.com:18080/sub/reality/clash.yaml
http://sub.example.com:18080/sub/ws-tls/clash.yaml
```

如果你想复用同一个域名，也可以使用“同域名不同端口”：

```env
DOMAIN=reality.example.com
SERVER=reality.example.com
SUBSCRIPTION_HOST=reality.example.com:18080
SUBSCRIPTION_CADDY_PORT=18080
```

此时：

- Reality 连接走 `reality.example.com:443`
- Clash 订阅走 `http://reality.example.com:18080/sub/reality/clash.yaml`

注意：

- `SUBSCRIPTION_HOST` 需要显式带上端口
- `SUBSCRIPTION_CADDY_PORT` 不能与 `XRAY_PORT` 相同

导出目录约定：

```text
data/exports/<profile>/
├── clash.yaml
├── clash-subscription-url.txt
└── vless.txt
```

其中：

- `ws-tls` 导出 `network: ws`、`ws-opts.path`、`Host`、`servername`
- `reality` 导出 `network: tcp`、`flow`、`reality-opts.public-key`、`reality-opts.short-id`
- `reality` 不会生成 `ws-opts`

完整说明见 [doc/client-export.md](doc/client-export.md)。

## 导出示例

`ws-tls`：

```bash
cp .env.example .env
# 编辑 .env
# PROFILE=ws-tls
# DOMAIN=example.com
# UUID=00000000-0000-4000-8000-000000000000
# NODE_NAME=ws-node
# WS_PATH=/transport-path
# SERVER=example.com
# PORT=443
# SNI=example.com
# HOST=example.com
# CLIENT_FINGERPRINT=chrome
# SUBSCRIPTION_SCHEME=http
# SUBSCRIPTION_HOST=sub.example.com:18080
# SUBSCRIPTION_CADDY_PORT=18080
bash scripts/render-config.sh
bash scripts/export-client.sh
find data/exports/ws-tls -maxdepth 1 -type f | sort
```

`reality`：

```bash
cp .env.example .env
# 编辑 .env
# PROFILE=reality
# DOMAIN=example.com
# UUID=00000000-0000-4000-8000-000000000000
# NODE_NAME=reality-node
# SERVER=example.com
# PORT=443
# CLIENT_FINGERPRINT=chrome
# REALITY_SERVER_NAME=www.cloudflare.com
# SUBSCRIPTION_SCHEME=http
# SUBSCRIPTION_HOST=example.com:18080
# SUBSCRIPTION_CADDY_PORT=18080
# REALITY_PUBLIC_KEY=<your-public-key>
# REALITY_SHORT_ID=0123abcd
# FLOW=xtls-rprx-vision
bash scripts/render-config.sh
bash scripts/export-client.sh
find data/exports/reality -maxdepth 1 -type f | sort
```

### transport-specific logic

仅属于某个 transport 分支的逻辑，例如 WebSocket 路径、Reality 密钥、Caddy 依赖、客户端导出格式等。

---

## 当前边界

- `refactor-base` 负责公共框架
- `v2-ws-tls` 与 `v2-reality` 各自独立实现 transport
- 旧 `Dockerfile`、`caddy.sh`、`v2ray.json`、`v2ray.js` 仍保留用于迁移参考
