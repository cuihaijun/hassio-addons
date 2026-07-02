# Home Assistant Add-on: FRP Client

FRP Client connects Home Assistant or another local service to your own public `frps` server.

This add-on has been migrated to the HA App System style:

- `config.yaml` instead of legacy `config.json`
- Home Assistant base image
- `io.hass.type="app"` image metadata
- frp `0.69.1`
- no bundled public test token

## Configuration

```yaml
frp_server: "example.com"
frp_server_port: 7000
frp_token: "change-me"
local_host: homeassistant
local_port: 8123
tunnel_type: tcp
proxy_name: homeassistant
tcp_remote_port: 6000
transport_protocol: tcp
tls_enable: true
auth_heartbeats: false
auth_new_work_conns: false
log_level: info
admin_enable: false
admin_addr: 0.0.0.0
admin_port: 7400
admin_user: admin
admin_password: ""
```

### Required Options

| Option | Description |
| --- | --- |
| `frp_server` | Public frps server hostname or IP |
| `frp_server_port` | frps bind port |
| `frp_token` | Token configured on your frps server |
| `local_host` | Local target host, for Home Assistant use `homeassistant` |
| `local_port` | Local target port, for Home Assistant use `8123` |
| `tunnel_type` | `tcp` or `http` |

### Authentication Scope Compatibility

If your `frps` enables heartbeat or new work connection authentication, enable the matching client options:

```yaml
auth_heartbeats: true
auth_new_work_conns: true
```

These options generate:

```toml
auth.additionalScopes = ["HeartBeats", "NewWorkConns"]
```

### TCP Mode

Set:

```yaml
tunnel_type: tcp
tcp_remote_port: 6000
```

The add-on creates:

```text
frps:6000 -> local_host:local_port
```

### HTTP Mode

Set:

```yaml
tunnel_type: http
http_domain: "ha.example.com"
http_subdomain_host: ""
```

`http_domain` is written as a custom domain for the proxy. If your frps uses subdomains, set `http_subdomain_host`.

## frps Example

Minimal `frps.toml`:

```toml
bindPort = 7000
auth.method = "token"
auth.token = "change-me"
```

For HTTP virtual host support:

```toml
bindPort = 7000
vhostHTTPPort = 80
subdomainHost = "example.com"
auth.method = "token"
auth.token = "change-me"
```

## Home Assistant Proxy Note

When exposing Home Assistant through a reverse proxy, configure trusted proxies in `configuration.yaml` as needed:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.33.0/24
```
