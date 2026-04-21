# Phase 1A Scope

## 目标

完成以下三条分支的清晰分工与可运行实现：

- `refactor-base`
- `v2-ws-tls`
- `v2-reality`

---

## 包含内容

- 底座目录重构
- 参数系统
- 模板系统
- compose-first 启动框架
- Xray 引入
- VLESS
- `ws-tls` transport
- `reality` transport
- 状态与导出脚本
- 分支级文档

---

## 不包含内容

- Web UI
- 多节点管理
- 用户系统
- Clash 等多格式导出体系
- 运维面板

---

## 交付物

- `refactor-base`：公共底座
- `v2-ws-tls`：独立 `ws-tls` 实现
- `v2-reality`：独立 `reality` 实现
- README
- `scripts/`
- `templates/`
- `doc/`

---

## 范围原则

> base 提供能力，branch 实现 transport-specific logic
