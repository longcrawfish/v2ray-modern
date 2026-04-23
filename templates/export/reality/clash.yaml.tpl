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

# 1. 预定义规则集（放在文件顶部或与 rules 同级）
rule-providers:
  private:
    type: http
    behavior: domain
    url: "https://fastly.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/private.txt"
    path: ./ruleset/private.yaml
    interval: 86400
  applications:
    type: http
    behavior: classical
    url: "https://fastly.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/applications.txt"
    path: ./ruleset/applications.yaml
    interval: 86400
  telegramcidr:
    type: http
    behavior: ipcidr
    url: "https://fastly.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/telegramcidr.txt"
    path: ./ruleset/telegramcidr.yaml
    interval: 86400

  reject:
    type: http
    behavior: domain
    url: "https://fastly.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/reject.txt"
    path: ./ruleset/reject.yaml
    interval: 86400

  icloud:
    type: http
    behavior: domain
    url: "https://fastly.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/icloud.txt"
    path: ./ruleset/icloud.yaml
    interval: 86400

  apple:
    type: http
    behavior: domain
    url: "https://fastly.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/apple.txt"
    path: ./ruleset/apple.yaml
    interval: 86400

  google:
    type: http
    behavior: domain
    url: "https://fastly.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/google.txt"
    path: ./ruleset/google.yaml
    interval: 86400

  proxy:
    type: http
    behavior: domain
    url: "https://fastly.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/proxy.txt"
    path: ./ruleset/proxy.yaml
    interval: 86400

  direct:
    type: http
    behavior: domain
    url: "https://fastly.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/direct.txt"
    path: ./ruleset/direct.yaml
    interval: 86400

  cnip:
    type: http
    behavior: ipcidr
    url: "https://fastly.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/cncidr.txt"
    path: ./ruleset/cnip.yaml
    interval: 86400

# 2. 逻辑规则
rules:
  # 1. 优先处理本地和私有流量
  - RULE-SET,applications,DIRECT
  - RULE-SET,private,DIRECT

  - DOMAIN,cn.bing.com,DIRECT
  - DOMAIN,d.bing.com,DIRECT      # 必应的静态资源
  - DOMAIN-SUFFIX,bing.com,PROXY  # 剩下的（国际版、Copilot）全部走代理

  # 拦截广告
  - RULE-SET,reject,REJECT
  
  # 局域网和本地流量直连
  - GEOIP,LAN,DIRECT,no-resolve
  
  # 苹果服务（如果你希望 iCloud 等直连，可以设为 DIRECT）
  - RULE-SET,icloud,DIRECT
  - RULE-SET,apple,DIRECT
  
  # 明确的国外常用服务走代理
  - RULE-SET,google,PROXY
  - RULE-SET,proxy,PROXY

  #  强制走代理的特殊 IP (如 Telegram)
  - RULE-SET,telegramcidr,PROXY

  # 明确的国内常用服务直连
  - RULE-SET,direct,DIRECT
  
  # 判定为中国 IP 的流量直连
  - RULE-SET,cnip,DIRECT
  
  # 兜底规则：以上都没匹配上的（通常是冷门国外网站），走代理
  - MATCH,PROXY
