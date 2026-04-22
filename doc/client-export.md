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
```

---

## 导出目录

每个 profile 会输出到独立目录：

```text
data/exports/<profile>/
├── clash.yaml
├── clash-subscription-url.txt
└── vless.txt
```

适用关系：

- `clash.yaml`
  - 用于 Clash Verge Rev、ClashX Meta、Mihomo
- `clash-subscription-url.txt`
  - 说明如何把本地 `clash.yaml` 托管成公网订阅 URL
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
- `SUBSCRIPTION_HOST`

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

## 订阅 URL 托管

项目不会自动发布公网订阅，只会生成说明文件：

```text
data/exports/<profile>/clash-subscription-url.txt
```

常见托管方式：

- Nginx 静态文件
- 对象存储静态托管
- 自建订阅接口
- 任意可公开访问的静态文件服务

示例：

```text
https://sub.example.com/sub/ws-tls/clash.yaml
https://sub.example.com/sub/reality/clash.yaml
```

---

## 推荐导入方式

Clash Verge Rev / ClashX Meta / Mihomo：

1. 本地导入 `clash.yaml`
2. 或将其托管为 URL 后按订阅方式导入

v2rayNG：

1. 打开 `data/exports/<profile>/vless.txt`
2. 复制其中的 `vless://` 链接
3. 在客户端中粘贴导入
