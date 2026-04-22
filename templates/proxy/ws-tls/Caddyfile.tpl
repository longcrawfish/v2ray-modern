{
  email {{TLS_EMAIL}}
  admin :{{CADDY_ADMIN_PORT}}
  acme_ca {{TLS_CA}}
}

{{DOMAIN}} {
  encode zstd gzip

  handle_path /sub/* {
    root * /exports
    file_server
  }

  @ws {
    path {{WS_PATH}}
    header Connection *Upgrade*
    header Upgrade websocket
  }

  handle @ws {
    reverse_proxy xray:{{XRAY_PORT}}
  }

  handle {
    root * /srv
    file_server
  }

  tls {{TLS_EMAIL}}

  log {
    output file /var/log/caddy/access.log
    format console
  }
}
