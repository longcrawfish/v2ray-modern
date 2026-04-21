{
  "phase": "phase1a",
  "branch_role": "refactor-base",
  "profile": "{{PROFILE}}",
  "domain": "{{DOMAIN}}",
  "node_name": "{{NODE_NAME}}",
  "xray_port": "{{XRAY_PORT}}",
  "tls_mode": "{{TLS_MODE}}",
  "template_slots": {
    "transport": "templates/transport/{{PROFILE}}",
    "proxy": "templates/proxy/{{PROFILE}}"
  },
  "notes": [
    "当前文件仅为底座占位产物",
    "具体协议和 transport 逻辑由后续分支实现"
  ]
}
