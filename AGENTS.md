# AGENTS.md（Phase 1A）

## 总目标

构建一个：

- 可维护
- 可扩展
- 多 transport 支持

的部署系统。

---

## 核心设计原则

1. 架构优先，先完成 `refactor-base`
2. transport 分离，`ws-tls` 与 `reality` 独立实现
3. 模板驱动，禁止在脚本中直接写配置正文
4. compose 优先，替代长 `docker run`
5. 脚本原子化，统一 `preflight / render / start / status / export`

---

## 分支职责

### `refactor-base`

职责：

- 目录结构
- 参数系统
- 模板系统
- compose 框架
- 通用脚本

禁止：

- 写死协议
- 写死 `ws path`
- 假定必须依赖 Caddy
- 引入 `reality` 或 `ws-tls` 具体 transport 逻辑

### `v2-ws-tls`

职责：

- Xray
- VLESS
- WebSocket
- TLS
- 域名 + 443 + 反向代理体验

说明：

- 允许使用 Caddy 或同类代理层
- 但必须继续服从底座的模板与脚本框架

### `v2-reality`

职责：

- Xray
- VLESS
- REALITY
- 独立 transport 实现

说明：

- 不继承 `v2-ws-tls` 的 WS、Caddy、证书依赖
- 视为单独 profile 的实现

---

## Agent 角色

### Refactor Agent

负责：

- 底座结构
- 参数系统
- 模板框架
- 公共脚本

### Transport Agent

负责：

- `ws-tls`
- `reality`

### Template Agent

负责：

- 模板文件
- 参数注入
- runtime 产物命名

### Infra Agent

负责：

- compose
- 网络
- 端口
- volume
- 日志目录

### QA Agent

负责：

- 启动测试
- 配置校验
- 日志分析
- 状态输出

---

## 统一术语

- `profile`：transport 选择键，例如 `ws-tls`、`reality`
- `template`：`templates/` 下的源配置
- `runtime`：`data/runtime/` 下的渲染结果
- `export`：`data/exports/` 下的客户端导出结果
- `transport-specific logic`：只属于某个 transport 分支的实现细节

---

## 禁止事项

- 在 `refactor-base` 写协议逻辑
- 写死 `/one`
- 强依赖 Caddy
- 让 `v2-reality` 继承 `ws-tls` 逻辑
- 不使用模板直接写配置

---

## 成功标准

- 三个分支职责明确
- 配置全部模板化
- CLI 流程统一
- 接手开发者可以通过 README 和 `doc/` 快速理解项目
