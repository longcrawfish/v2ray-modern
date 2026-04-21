# Branch Strategy

## 目标

明确 `master`、`refactor-base`、`v2-ws-tls`、`v2-reality` 的关系，降低后续开发和维护成本。

---

## 分支角色

### `master`

- 保留旧实现
- 作为兼容基线和迁移参考
- 不承载 Phase 1A 新架构演进

### `refactor-base`

- 作为公共底座分支
- 负责参数系统、模板系统、compose 框架、原子脚本
- 不实现具体 transport

### `v2-ws-tls`

- 从 `refactor-base` 演进
- 实现 `Xray + VLESS + WS + TLS`
- 保留域名 + 443 体验

### `v2-reality`

- 从 `refactor-base` 演进
- 实现 `Xray + VLESS + REALITY`
- 不依赖 `ws-tls` 的 transport 逻辑

---

## 分支关系

```text
master
└── refactor-base
    ├── v2-ws-tls
    └── v2-reality
```

说明：

- `v2-ws-tls` 和 `v2-reality` 是并列关系
- 两者都建立在 `refactor-base` 之上
- 两者之间不应互相继承 transport-specific logic

---

## 合并策略建议

- 公共能力先进入 `refactor-base`
- 某个 transport 专属能力只进入对应分支
- 若 `v2-ws-tls` 与 `v2-reality` 发现相同的通用需求，应先回收到 `refactor-base`

---

## 适用场景

- 维护公共底座：进入 `refactor-base`
- 维护 WS + TLS：进入 `v2-ws-tls`
- 维护 Reality：进入 `v2-reality`
- 审计老项目：参考 `master`
