# 客户端导出说明

## 目标

项目提供统一的客户端配置导出流程，覆盖：

- Clash Verge Rev
- ClashX Meta
- Mihomo 系客户端
- v2rayNG

标准流程：

```bash
cp .env.example .env
bash scripts/render-config.sh
bash scripts/export-client.sh
bash scripts/start.sh
```

---

## 导出目录

每个 profile 会输出到独立目录：

```text
data/exports/<profile>/
├── clash.yaml
└── vless.txt
```

适用关系：

- `clash.yaml`
  - 用于 Clash Verge Rev、ClashX Meta、Mihomo
- `vless.txt`
  - 用于 v2rayNG 等支持 `vless://` 的客户端

---

## profile 差异

### ws-tls

导出字段包含：

- `network: ws`
- `tls: true`
- `ws-opts.path`
- `ws-opts.headers.Host`
- `servername`
- `client-fingerprint`

对应 `vless://` 参数包含：

- `security=tls`
- `type=ws`
- `host`
- `path`
- `fp`

### reality

导出字段包含：

- `network: tcp`
- `tls: true`
- `flow`
- `reality-opts.public-key`
- `reality-opts.short-id`
- `servername`
- `client-fingerprint`

对应 `vless://` 参数包含：

- `security=reality`
- `type=tcp`
- `pbk`
- `sid`
- `flow`
- `fp`

约束：

- `reality` 不包含 `ws-opts`
- `reality` 不复用 ws-tls 的字段拼接方式
- `reality` 不依赖传统 TLS 证书导出逻辑

---

## 关键变量

公共变量：

- `PROFILE`
- `NODE_NAME`
- `SERVER`
- `PORT`
- `UUID`
- `CLIENT_FINGERPRINT`

`ws-tls` 额外变量：

- `SNI`
- `HOST`
- `WS_PATH`

`reality` 额外变量：

- `REALITY_SERVER_NAME`
- `REALITY_PUBLIC_KEY`
- `REALITY_SHORT_ID`
- `FLOW`

变量来源规则：

1. 优先读取 `.env`
2. 缺失时从 `data/runtime/core-base.env` 补齐
3. `NODE_NAME` 和 `WS_PATH` 在生成 `vless://` 时会做 URL 编码

---

## `v2-reality` 导出约定

在当前 `v2-reality` 分支中：

- 保留 `data/exports/reality/clash.yaml`
- 保留 `data/exports/reality/vless.txt`
- 不再内置 HTTP Clash 订阅地址
- 不再生成 `clash-subscription-url.txt`

这样做的目的是避免把 Reality 节点材料通过项目内置的明文 HTTP 订阅链路暴露出去。

如果需要继续给 Clash 类客户端使用，推荐方式是：

- 直接本地导入 `clash.yaml`
- 或在你自己的 HTTPS 静态托管/订阅服务上发布该文件

---

## 推荐导入方式

Clash Verge Rev / ClashX Meta / Mihomo：

1. 本地导入 `clash.yaml`
2. 如需远程更新，请自行托管为 HTTPS URL 后按订阅方式导入

v2rayNG：

1. 打开 `data/exports/<profile>/vless.txt`
2. 复制其中的 `vless://` 链接
3. 在客户端中粘贴导入
