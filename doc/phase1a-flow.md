# Phase 1A Flow

## 🚀 总流程

```
User
↓
preflight-check
↓
render-config
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
start service
```

---

## 🔮 后续扩展

```
multi-node
↓
dashboard
↓
api
```

