# Phase 1A Summary

## 阶段目标

Phase 1A 的目标是把老的一键部署项目拆成：

- 可维护的公共底座
- 可独立演进的 transport 分支
- 统一的模板、runtime、export、compose、脚本流程

截至当前，Phase 1A 的边界已经基本清晰，三条分支职责已经分离。

---

## 分支状态总览

### `refactor-base`

已完成：

- 目录结构重构
- 参数系统初版
- 模板系统初版
- compose-first 入口
- `preflight-check / render-config / start / status / export-client` 原子脚本
- `data/runtime / data/exports / data/logs` 目录约定

未完成：

- 更完整的公共参数加载抽象
- 更稳定的配置校验与错误提示
- 更完整的 runtime 查看与调试工具
- 自动化测试与 CI

风险点：

- 当前更多是“框架可用”，不是“所有 profile 都可自动回归验证”
- 文档虽然已成体系，但仍依赖人工遵守边界

建议下一阶段：

- 把通用验证、日志与导出能力继续沉淀到底座
- 为后续新 profile 预留更稳定的接口

### `v2-ws-tls`

已完成：

- Xray 替换旧内核
- VLESS + WS + TLS 基本实现
- Caddy 反向代理与 TLS 入口
- `show-env / show-config / status` 基本排障路径
- profile 专属模板和导出文件

未完成：

- 实机完整联调与回归
- 更细粒度的健康检查
- 更稳定的多客户端与多实例能力

风险点：

- 对域名解析、80/443 放通、ACME 签发依赖较强
- 当前 healthcheck 仍偏占位
- 未形成自动化部署验证

建议下一阶段：

- 做一轮真实服务器联调
- 补齐日志检查、证书失败排障和多实例设计

### `v2-reality`

已完成：

- Xray + VLESS + REALITY 基本实现
- Reality 专属模板
- key 生成脚本
- profile 专属校验与导出
- 与 `ws-tls` 的依赖解耦

未完成：

- 实机完整联调与回归
- 更完善的 key 生命周期管理
- 更清晰的状态输出和故障提示

风险点：

- 密钥生成和运行验证依赖 Docker / Xray 镜像
- REALITY 参数错误时，问题定位仍主要依赖人工检查
- 与不同客户端的兼容性尚未系统验证

建议下一阶段：

- 做一轮针对主流客户端的联调
- 增加对 Reality 参数组合的更细校验

---

## Phase 1A 结论

### 已达成

- 三条分支职责明确
- 底座与 transport 逻辑已经分离
- 项目不再依赖老式超长 `docker run`
- 文档、术语、目录约定已经成形

### 尚未完全达成

- 三条分支的自动化验证
- 一套稳定的交付级测试流程
- 多实例、多用户、更丰富导出格式

---

## 推荐路线

### 对开发者

- 默认从 `refactor-base` 理解项目结构与公共概念
- 需要做 WS + TLS 时进入 `v2-ws-tls`
- 需要做 Reality 时进入 `v2-reality`

### 对试部署用户

- 更容易上手：`v2-ws-tls`
- 更偏进阶与轻依赖：`v2-reality`

---

## 是否建议提升默认推荐路线

建议区分两类“默认”：

- 默认开发主线：`refactor-base`
- 默认首个可交付候选：`v2-ws-tls`

原因：

- `refactor-base` 最适合作为后续 Phase 2 的演进主干
- `v2-ws-tls` 更贴近传统用户的部署习惯，适合作为第一条面向使用者的推荐路径
