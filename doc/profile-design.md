# Profile Design

## 目标

解释项目中的 `profile` 设计，以及它和 template、runtime、export、transport-specific logic 的关系。

---

## 什么是 profile

`profile` 是 transport 选择键。

当前支持：

- `ws-tls`
- `reality`

它的职责是：

- 选择 transport 模板目录
- 选择 proxy 模板目录
- 触发 profile 专属校验
- 决定启动哪些服务

---

## profile 与 template 的关系

模板目录拆分为：

- `templates/core/`
- `templates/transport/<profile>/`
- `templates/proxy/<profile>/`

含义：

- `core` 放公共模板
- `transport/<profile>` 放某个 profile 的 transport 模板
- `proxy/<profile>` 放某个 profile 的代理层模板或运行说明

---

## profile 与 runtime 的关系

渲染流程会把模板输出到 `data/runtime/`。

运行时服务不直接读取 `templates/`，而是读取 `runtime` 结果。

这使得：

- 模板源文件与实际运行配置分离
- 可以通过 `show-config` 或直接查看 `data/runtime/` 排障

---

## profile 与 export 的关系

`export` 是客户端可使用的导出结果，位于 `data/exports/`。

不同 profile 的导出内容不同：

- `ws-tls` 导出 VLESS + WS + TLS 链接
- `reality` 导出 VLESS + REALITY 链接

因此导出逻辑属于 transport-specific logic。

---

## 什么是 transport-specific logic

只属于某个 transport 的实现细节，包括：

- WebSocket 路径
- Reality 密钥
- 是否依赖 Caddy
- 是否依赖传统证书
- 客户端链接格式
- 专属预检规则

这些逻辑不应进入 `refactor-base`。

---

## 当前 profile 设计原则

1. `profile` 只做路由，不做协议抽象魔法
2. 公共能力进入 `refactor-base`
3. transport 差异进入对应 profile 目录
4. runtime 和 export 都由 profile 驱动生成
