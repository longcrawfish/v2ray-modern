# AGENTS.md（Phase 1A）

## 🎯 总目标

构建一个：

- 可维护
- 可扩展
- 多协议支持

的部署系统。

---

## 🧠 核心设计原则

1. 架构优先（先 refactor-base）
2. 协议分离（ws-tls / reality）
3. 模板驱动（禁止硬编码）
4. compose 优先
5. 脚本原子化

---

## 🧩 分支职责

### refactor-base

职责：

- 目录重构
- 参数系统
- 模板系统
- compose 化
- CLI 脚本

禁止：

- 写死协议
- 引入 reality / ws 逻辑

---

### v2-ws-tls

职责：

- Xray 替换 V2Ray
- 使用 VLESS
- 使用 WS + TLS
- 保留域名接入体验

---

### v2-reality

职责：

- Xray + VLESS + REALITY
- 独立 transport 实现
- 不依赖 Caddy

---

## 🧩 Agent 角色

### Refactor Agent
负责 base 重构

---

### Transport Agent
实现：

- ws-tls
- reality

---

### Template Agent
负责：

- tpl 文件
- 参数注入

---

### Infra Agent
负责：

- compose
- 网络
- 端口

---

### QA Agent
负责：

- 启动测试
- 配置校验
- 日志分析

---

## 🚫 禁止事项

- 在 refactor-base 写协议逻辑
- 写死 `/one`
- 强依赖 Caddy
- 不使用模板直接写配置

---

## ✅ 成功标准

- 三个分支能独立运行
- 配置全部模板化
- CLI 流程统一
