# v2ray-modern（Phase 1A）

> 基于原一键 V2Ray 项目的现代化重构版本，面向长期维护与多协议扩展。

本项目从原仓库 fork 而来，在保持“一键部署体验”的基础上，进行系统性重构，并引入 Xray 及多传输模式支持。

---

## 🎯 Phase 1A 目标

本阶段同时推进三条分支：

| 分支 | 目标 |
|------|------|
| main | 保持上游兼容，稳定可用 |
| refactor-base | 架构重构（不涉及协议） |
| v2-ws-tls | Xray + VLESS + WS + TLS |
| v2-reality | Xray + VLESS + REALITY |

---

## 🧱 项目定位

从：

> 一键脚本

升级为：

> 可维护的部署系统 + 可扩展的协议框架

---

## 📁 项目结构（refactor-base）

```

.
├── compose.yaml
├── .env.example
├── scripts/
│   ├── preflight-check.sh
│   ├── render-config.sh
│   ├── start.sh
│   ├── status.sh
│   └── export-client.sh
├── templates/
│   ├── core.json.tpl
│   └── transport.tpl
├── data/
│   ├── runtime/
│   └── exports/
└── doc/

````

---

## 🚀 使用方式

### 1. 克隆项目

```bash
git clone https://github.com/longcrawfish/v2ray-modern.git
cd v2ray-modern
````

---

### 2. 切换分支

```bash
# 底座
git checkout refactor-base

# WS + TLS 版本
git checkout v2-ws-tls

# REALITY 版本
git checkout v2-reality
```

---

### 3. 配置环境变量

```bash
cp .env.example .env
```

编辑：

```env
DOMAIN=your.domain.com
UUID=your-uuid
PROFILE=ws-tls   # ws-tls / reality
```

---

### 4. 执行检查

```bash
bash scripts/preflight-check.sh
```

---

### 5. 渲染配置

```bash
bash scripts/render-config.sh
```

---

### 6. 启动服务

```bash
docker compose up -d
```

---

### 7. 查看状态

```bash
bash scripts/status.sh
```

---

## ⚙️ Profile 说明

| Profile | 分支         | 描述              |
| ------- | ---------- | --------------- |
| ws-tls  | v2-ws-tls  | WebSocket + TLS |
| reality | v2-reality | REALITY         |

---

## ⚠️ 注意事项

* 80/443 端口必须未被占用
* 域名必须解析到 VPS
* UUID 必须合法
* REALITY 模式不依赖传统 TLS 证书

---

## 🔜 后续规划

* Phase 2：多实例支持
* Phase 3：客户端配置导出（Clash / JSON / QR）
* Phase 4：Web UI 管理

---

## 📜 License

MIT
