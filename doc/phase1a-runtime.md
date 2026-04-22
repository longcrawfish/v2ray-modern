# Phase 1A 运行时与启动流程

## 目标

本轮为 `refactor-base` 提供标准化运行期入口，使公共底座可以独立作为 compose-first 版本存在，不再依赖原始的超长 `docker run` 命令。

---

## 一、compose 设计

### 问题

- 旧项目依赖单次命令直接起容器，运行目录、日志目录和状态查看方式都不统一。

### 风险

- 后续各分支容易复制不同的启动方式。
- 无法沉淀统一的运行期约定和排障路径。

### 重构建议

`compose.yaml` 当前采用以下约定：

- 统一服务名：`v2ray-modern`
- 统一容器名：`v2ray-modern`
- 使用 `restart: unless-stopped`
- 挂载：
  - `./data/runtime:/app/runtime`
  - `./data/logs:/app/logs`
  - `./data/exports:/app/exports`
- 通过 `.env` 注入公共参数
- 增加 healthcheck 占位，当前仅检查 `core-manifest.json` 是否存在

说明：
- 当前 healthcheck 只是底座级别占位，不代表具体协议服务健康。
- `PROFILE` 仍只用于底座路由和模板选择，不代表协议逻辑已经实现。

---

## 二、启动流程

### 问题

- 如果检查、渲染、启动分散执行，调用顺序容易漂移。

### 风险

- 启动时可能直接使用过期配置，或者跳过参数校验。

### 重构建议

标准入口为：

```bash
bash scripts/start.sh
```

执行顺序固定为：

1. `scripts/preflight-check.sh`
2. `scripts/render-config.sh`
3. `docker compose up -d`

这样可以保证：

- 配置渲染先于容器启动
- 关键参数和端口状态先被校验
- 启动方式在所有后续分支中保持一致

---

## 三、状态与排障流程

### 问题

- 旧项目缺少统一状态命令，运维只能手写 `docker ps`、`docker logs`。

### 风险

- 排障路径不一致，容易遗漏运行目录和渲染产物检查。

### 重构建议

标准状态入口为：

```bash
bash scripts/status.sh
```

当前输出内容包括：

- compose 容器状态
- `data/logs/` 路径和文件列表
- `data/runtime/` 渲染产物列表
- `data/exports/` 导出目录列表
- 常用排障命令提示

---

## 四、目录约定

### `data/runtime/`

- 存放模板渲染后的运行时配置
- 属于生成物，不作为长期手工编辑目录

### `data/logs/`

- 存放底座级别日志
- 当前占位容器会写入 `bootstrap.log`

### `data/exports/`

- 存放客户端导出文件或未来其他可交付产物

---

## 五、仍留给 transport 分支的能力

- 真实服务镜像和进程编排
- 协议健康检查
- 协议相关日志结构
- 更复杂的导出聚合能力（如多节点、多订阅源）
- 反向代理或无代理运行方案
