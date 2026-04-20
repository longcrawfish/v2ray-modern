# Codex Playbook（Phase 1A）

## 🎯 目标

同时推进三条分支：

- refactor-base
- v2-ws-tls
- v2-reality

---

## 🧭 开发轮次

---

## Round 1：refactor-base

任务：

- 目录结构
- scripts 拆分
- 模板系统
- compose.yaml

输出：

- 可运行基础框架

---

## Round 2：v2-ws-tls

任务：

- 引入 Xray
- 配置 VLESS
- 配置 WS + TLS
- 域名接入

---

## Round 3：v2-reality

任务：

- Xray reality 配置
- key 生成
- transport 替换

---

## Round 4：统一 CLI

任务：

- render-config 支持 profile
- export-client
- status

---

## 🔁 执行模式

每轮：

1. Codex 生成代码
2. 本地运行
3. 修复问题
4. commit

---

## 🧪 测试重点

- 端口绑定
- config 合法性
- container 是否启动
- profile 是否正确切换

---

## ⚠️ 注意

- 不要让 reality 继承 ws 逻辑
- 不要让 base 污染协议
