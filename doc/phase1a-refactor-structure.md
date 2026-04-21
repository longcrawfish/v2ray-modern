# Phase 1A 底座结构说明

## 目标

本轮在 `refactor-base` 分支落地公共底座骨架，只处理目录、参数、模板、compose 和脚本职责拆分，不引入任何具体 transport 实现。

---

## 目录结构

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

---

## 脚本职责

### `scripts/preflight-check.sh`

- 检查 `docker` / `docker compose`
- 检查公共参数是否具备基础可读性
- 预创建运行目录

### `scripts/render-config.sh`

- 从 `.env` 或环境变量装载公共参数
- 将模板渲染到 `data/runtime/`
- 只生成底座占位配置，不写协议字段

### `scripts/start.sh`

- 按顺序执行检查和渲染
- 通过 `docker compose` 启动基础容器
- 不再依赖单体入口脚本直接拼接全部逻辑

### `scripts/status.sh`

- 查看运行时文件
- 查看导出目录
- 输出 compose 服务状态

### `scripts/export-client.sh`

- 仅保留导出流程接口
- 当前只生成占位说明，不输出具体客户端链接

---

## 模板职责

### `templates/core/`

- 放公共层渲染产物模板
- 当前包含基础变量清单和运行 manifest

### `templates/transport/`

- 预留 transport 片段位置
- 由后续 `v2-ws-tls` / `v2-reality` 分支填充

### `templates/proxy/`

- 预留代理层模板位置
- 当前只定义接口占位，不假定必须存在某类代理

---

## 与旧结构的关系

- 本轮没有删除旧的 `Dockerfile`、`caddy.sh`、`v2ray.json`、`v2ray.js`
- 旧文件当前仍可作为审计样本和迁移参考
- 新底座已经将“检查 / 渲染 / 启动 / 状态 / 导出”拆成原子脚本

---

## 下一步建议

- 把旧脚本中的配置正文拆到模板目录
- 为 `refactor-base` 补齐统一参数加载逻辑
- 让 `compose.yaml` 从占位容器切换为真实服务编排
- 在 transport 分支分别实现协议模板和导出器
