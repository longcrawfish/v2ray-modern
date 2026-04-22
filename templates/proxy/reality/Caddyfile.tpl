:{{SUBSCRIPTION_CADDY_PORT}} {
    handle_path /sub/* {
        root * /srv
        file_server
    }

    handle /healthz {
        respond "ok" 200
    }

    handle {
        respond "subscription server ready" 200
    }
}
