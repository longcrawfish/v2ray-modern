# Phase 1A 参数系统与模板渲染框架

## 目标

本轮在 `refactor-base` 分支建立统一参数系统和模板渲染框架，只解决公共底座问题，不引入任何具体协议实现。

---

## 一、参数加载流程

### 问题

- 旧实现中参数分散在脚本位置参数、Docker 命令和内嵌默认值里。
- 缺少统一入口，错误提示不清晰。

### 风险

- 参数来源不一致会导致运行行为不可预测。
- 后续引入多个 transport 时，分支之间会各自复制一套参数处理。

### 重构建议

- 统一通过 `.env` 提供运行参数。
- 公共加载逻辑集中在 `scripts/lib/common.sh`。
- 所有入口脚本通过同一组函数读取、校验并导出变量。

---

## 二、当前支持的环境变量

| 变量 | 是否必填 | 说明 |
|------|----------|------|
| `PROFILE` | 是 | 选择模板插槽，当前允许 `ws-tls` 或 `reality` |
| `DOMAIN` | 是 | 公共域名参数，供 transport 或 proxy 模板引用 |
| `UUID` | 否 | 若提供则校验格式，当前只作为占位变量下发 |
| `WS_PATH` | 否 | transport 层占位路径，默认由 `.env` 提供 |
| `NODE_NAME` | 否 | 节点名称，占位输出使用 |
| `XRAY_PORT` | 否 | 运行端口占位变量，要求为数字 |
| `TLS_MODE` | 否 | 代理层 TLS 策略占位变量 |

---

## 三、预检逻辑

### 问题

- 旧项目缺少统一预检，错误往往拖到容器启动后才暴露。

### 风险

- 排障成本高。
- 不同分支可能会出现不一致的检查口径。

### 重构建议

`scripts/preflight-check.sh` 当前统一检查：

- `docker` 是否存在
- `docker compose` / `docker-compose` 是否可用
- 80/443 端口是否被占用
- `.env` 是否存在
- `DOMAIN` 是否为空
- `UUID` 若提供是否符合 UUID 格式
- `PROFILE` 是否属于允许值
- 对应 profile 的模板目录是否存在

---

## 四、模板渲染框架

### 问题

- 旧实现通过 heredoc 即时写配置，无法按 profile 组合。

### 风险

- 后续扩展只能继续堆条件分支。
- 底座会不受控制地感知具体协议。

### 重构建议

- `templates/core/` 存放所有 profile 共用模板。
- `templates/transport/<profile>/` 存放 transport 插槽模板。
- `templates/proxy/<profile>/` 存放 proxy 插槽模板。
- `scripts/render-config.sh` 根据 `PROFILE` 自动选择对应目录并渲染到 `data/runtime/`。

当前渲染产物命名规则：

- `core-<template-name>`
- `transport-<template-name>`
- `proxy-<template-name>`

这样后续新增 profile 时，只需要补目录和模板文件，不需要重写底座渲染框架。

---

## 五、对 transport 分支的预留接口

### `v2-ws-tls`

- 使用 `templates/transport/ws-tls/`
- 使用 `templates/proxy/ws-tls/`
- 可在该分支补充 transport / proxy 模板正文

### `v2-reality`

- 使用 `templates/transport/reality/`
- 使用 `templates/proxy/reality/`
- 可在该分支补充无需传统代理层的实现细节

说明：
- `refactor-base` 只负责 profile 路由和变量注入。
- 具体协议字段、导出内容、代理软件选择都留给 transport 分支。
