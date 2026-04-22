当前 Profile: ws-tls

本地 YAML 文件：
${EXPORT_DIR}/clash.yaml

你可以将该文件通过静态文件服务、Nginx、对象存储或订阅接口暴露为 URL。
在 `v2-ws-tls` 分支中，也可以直接使用项目内置 Caddy 暴露 `/sub/*`。

示例订阅地址：
https://${SUBSCRIPTION_HOST}/sub/ws-tls/clash.yaml

推荐导入方式：
- Clash Verge Rev
- ClashX Meta
- Mihomo 系客户端

注意：
- 若使用项目内置 Caddy，建议将 `SUBSCRIPTION_HOST` 配置为 `DOMAIN`
- 若 `SUBSCRIPTION_HOST` 与 `DOMAIN` 不一致，请自行提供对应域名的静态托管
