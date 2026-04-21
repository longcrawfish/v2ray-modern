{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "{{XRAY_LOG_LEVEL}}"
  },
  "inbounds": [
    {
      "tag": "vless-reality-in",
      "listen": "0.0.0.0",
      "port": {{XRAY_PORT}},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "{{UUID}}",
            "flow": "{{REALITY_FLOW}}",
            "email": "{{NODE_NAME}}@{{DOMAIN}}"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "{{REALITY_DEST}}",
          "xver": 0,
          "serverNames": [
            "{{REALITY_SERVER_NAME}}"
          ],
          "privateKey": "{{REALITY_PRIVATE_KEY}}",
          "shortIds": [
            "{{REALITY_SHORT_ID}}"
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
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
