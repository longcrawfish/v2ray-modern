# Codex Playbook（Phase 1A）

## 目标

Phase 1A 的工作方式不是在单一分支堆功能，而是通过三条分支协作完成：

- `refactor-base`
- `v2-ws-tls`
- `v2-reality`

---

## 开发顺序

### Round 1：`refactor-base`

任务：

- 目录结构
- 参数系统
- 模板系统
- compose 框架
- 原子脚本

输出：

- 可复用公共底座

### Round 2：`v2-ws-tls`

任务：

- 引入 Xray
- VLESS
- WS + TLS
- 域名接入体验

输出：

- 基于 profile 的 `ws-tls` 实现

### Round 3：`v2-reality`

任务：

- 引入 Xray
- VLESS
- REALITY
- 密钥生成
- 独立 transport 实现

输出：

- 不依赖 `ws-tls` 历史逻辑的 `reality` 实现

### Round 4：统一验证与文档

任务：

- 统一 README
- 统一状态与导出脚本
- 完善排障文档

---

## 执行模式

每轮建议按以下顺序推进：

1. 审计当前结构
2. 实现代码或模板
3. 本地执行脚本验证
4. 修复明显问题
5. 更新文档

---

## 测试重点

- 参数是否正确加载
- 模板是否按 profile 选中
- runtime 是否正确生成
- compose 是否能展开
- container 是否能启动
- export 是否与 runtime 配置一致

---

## 协作约束

- 不要让 `refactor-base` 污染协议
- 不要让 `v2-reality` 继承 `ws-tls` 的 transport 逻辑
- 不要为了复用而保留不属于当前 profile 的历史包袱
- 文档、术语、目录命名必须和 README 保持一致
