# Phase 1A Flow

## 总流程

```text
.env
↓
preflight-check
↓
render-config
↓
export-client
↓
docker compose up -d
↓
status
```

---

## 公共流程说明

### 1. 参数输入

- 统一从 `.env` 加载
- `PROFILE` 负责选择 transport

### 2. 模板选择

- 先渲染 `templates/core/`
- 再根据 `PROFILE` 选择 `templates/transport/<profile>/`
- 最后选择 `templates/proxy/<profile>/`

### 3. runtime 生成

- 所有渲染结果进入 `data/runtime/`

### 4. 服务启动

- `compose.yaml` 使用 runtime 配置启动对应服务

### 5. 状态与导出

- `status.sh` 输出状态、路径、日志和排障提示
- `export-client.sh` 输出 `clash.yaml`、`vless.txt` 和订阅说明
- `subscription-caddy` 暴露 `/sub/<profile>/clash.yaml`

---

## 分支流程

### `refactor-base`

```text
.env
↓
common template render
↓
runtime skeleton
↓
compose base entry
```

### `v2-ws-tls`

```text
.env
↓
profile=ws-tls
↓
xray runtime
↓
caddy runtime
↓
443 with domain and TLS
↓
client export
```

### `v2-reality`

```text
.env
↓
profile=reality
↓
reality key material
↓
xray reality runtime
↓
direct reality transport
↓
subscription caddy
↓
client export
```

---

## Profile 流程

```text
PROFILE
↓
select profile template directories
↓
render runtime config
↓
render client export
↓
start profile-specific services
```

---

## 导出产物

```text
data/exports/<profile>/
├── clash.yaml
├── clash-subscription-url.txt
└── vless.txt
```

字段差异：

- `ws-tls`：`network: ws`、`ws-opts.path`、`ws-opts.headers.Host`
- `reality`：`network: tcp`、`flow`、`reality-opts.public-key`、`reality-opts.short-id`

---

## 后续扩展方向

```text
more profiles
↓
multi-node
↓
dashboard / api
```
