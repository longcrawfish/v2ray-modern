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
git checkout refactor-base
```

### 2. 初始化环境变量

```bash
cp .env.example .env
```

示例：

```env
PROFILE=base
DOMAIN=example.com
UUID=00000000-0000-4000-8000-000000000000
WS_PATH=/replace-me
NODE_NAME=default-node
XRAY_PORT=443
TLS_MODE=auto
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

### 6. 查看状态

```bash
bash scripts/status.sh
```

### 7. 生成导出占位文件

```bash
bash scripts/export-client.sh
```

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

## 当前边界

- 本轮只完成公共底座骨架
- 模板目录已建立，但内容仍为占位
- compose 已成为统一入口，但当前服务仍是底座占位容器
- 旧 `Dockerfile`、`caddy.sh`、`v2ray.json`、`v2ray.js` 仍保留用于迁移参考

---

## 文档

- [Phase 1A 审计结论](doc/phase1a-audit.md)
- [Phase 1A 重构备注](doc/phase1a-refactor-notes.md)
- [Phase 1A 底座结构说明](doc/phase1a-refactor-structure.md)

---

## 后续方向

- 将旧脚本中的配置正文迁移为真正可复用模板
- 为底座补齐统一参数加载和错误提示
- 在 transport 分支中分别接入具体协议实现
