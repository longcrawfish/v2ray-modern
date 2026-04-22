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
    network: tcp
    tls: true
    udp: true
    servername: ${REALITY_SERVER_NAME}
    client-fingerprint: ${CLIENT_FINGERPRINT}
    flow: ${FLOW}
    reality-opts:
      public-key: ${REALITY_PUBLIC_KEY}
      short-id: ${REALITY_SHORT_ID}

proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - ${NODE_NAME}
      - DIRECT

rules:
  - MATCH,PROXY
