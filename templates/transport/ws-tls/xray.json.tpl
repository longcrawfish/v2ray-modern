{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "{{XRAY_LOG_LEVEL}}"
  },
  "inbounds": [
    {
      "tag": "vless-ws-in",
      "listen": "0.0.0.0",
      "port": {{XRAY_PORT}},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "{{UUID}}",
            "email": "{{NODE_NAME}}@{{DOMAIN}}"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "{{WS_PATH}}"
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom"
    },
    {
      "tag": "block",
      "protocol": "blackhole"
    }
  ]
}
