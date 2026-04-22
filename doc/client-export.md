# 客户端导出说明

## 目标

项目提供统一的客户端配置导出流程，覆盖：

- Clash Verge Rev
- ClashX Meta
- Mihomo 系客户端
- v2rayNG

导出脚本：

```bash
bash scripts/export-client.sh
```

执行前建议先渲染运行时配置：

```bash
cp .env.example .env
bash scripts/render-config.sh
bash scripts/export-client.sh
```

---

## 导出目录

每个 profile 都输出到独立目录：

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
  - 用于说明如何把本地 `clash.yaml` 托管成订阅 URL
- `vless.txt`
  - 用于 v2rayNG 等支持 `vless://` 的客户端

---

## profile 差异

### ws-tls

导出字段包含：

- `network: ws`
- `tls: true`
- `servername`
- `client-fingerprint`
- `ws-opts.path`
- `ws-opts.headers.Host`

同时生成：

- Clash / Mihomo 可直接导入的 YAML
- 原生 `vless://` 链接

### reality

导出字段包含：

- `network: tcp`
- `tls: true`
- `servername`
- `client-fingerprint`
- `flow`
- `reality-opts.public-key`
- `reality-opts.short-id`

约束：

- 不包含 `ws-opts`
- 不复用 ws-tls 的路径和 Host 拼接方式
- 不依赖传统 TLS 证书导出字段

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
2. 缺失时回退到 `data/runtime/core-base.env`
3. 节点名称和 `WS_PATH` 在生成 `vless://` 时会做 URL 编码

---

## 订阅 URL 托管

项目不会自动生成公网订阅链接，只会生成说明文件：

```text
data/exports/<profile>/clash-subscription-url.txt
```

常见托管方式：

- Nginx 静态文件
- 对象存储静态托管
- 自建订阅接口
- 任意可公开访问的文件服务

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

---

## 最小示例

### ws-tls

```bash
cp .env.example .env
bash scripts/render-config.sh
bash scripts/export-client.sh
find data/exports/ws-tls -maxdepth 1 -type f | sort
```

### reality

```bash
cp .env.example .env
# 编辑 .env
# PROFILE=reality
# PORT=443
# CLIENT_FINGERPRINT=chrome
# REALITY_SERVER_NAME=www.cloudflare.com
# REALITY_PUBLIC_KEY=<your-public-key>
# REALITY_SHORT_ID=<your-short-id>
# FLOW=xtls-rprx-vision
bash scripts/render-config.sh
bash scripts/export-client.sh
find data/exports/reality -maxdepth 1 -type f | sort
```
