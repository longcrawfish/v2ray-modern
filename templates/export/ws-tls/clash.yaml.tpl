mixed-port: 7890
allow-lan: true
mode: rule
log-level: info
ipv6: true

proxies:
  - name: ${NODE_NAME}
    type: vless
    server: ${SERVER}
    port: ${PORT}
    uuid: ${UUID}
    network: ws
    tls: true
    udp: true
    servername: ${SNI}
    client-fingerprint: ${CLIENT_FINGERPRINT}
    ws-opts:
      path: ${WS_PATH}
      headers:
        Host: ${HOST}

proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - ${NODE_NAME}
      - DIRECT

rules:
  - MATCH,PROXY
