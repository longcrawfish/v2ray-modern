# Phase 1A Flow

## 🚀 总流程

```
User
↓
preflight-check
↓
render-config
↓
export-client
↓
docker compose up
↓
status
```

---

## 🔀 分支流程

### refactor-base

```
.env
↓
template render
↓
basic runtime config
```

---

### v2-ws-tls

```
.env
↓
ws-tls profile
↓
xray config
↓
caddy / tls
↓
client export
```

---

### v2-reality

```
.env
↓
reality profile
↓
xray config
↓
direct 443
↓
client export
```

---

## 🔁 Profile 流程

```
PROFILE
↓
select template
↓
render config
↓
render client export
↓
start service
```

## 📦 导出产物

```
data/exports/<profile>/
├── clash.yaml
├── vless.txt
└── clash-subscription-url.txt
```

字段差异：

- `ws-tls`：`network: ws`、`ws-opts.path`、`ws-opts.headers.Host`
- `reality`：`network: tcp`、`flow`、`reality-opts.public-key`、`reality-opts.short-id`

---

## 🔮 后续扩展

```
multi-node
↓
dashboard
↓
api
```
