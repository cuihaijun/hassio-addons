# RSSHub Add-on Portainer Structure Audit

Date: 2026-07-01

## Reference

- Reference add-on: `alexbelgium/hassio-addons/portainer`
- Reference structure checked from GitHub and local files:
  - `config.yaml`
  - `Dockerfile`
  - `rootfs/etc/cont-init.d/*`
  - `rootfs/etc/services.d/*`
  - Nginx ingress template and SSL support files

## Findings

1. `config.yaml` did not expose HTTPS-ready ingress/frontend settings.
   - Required value: `0.0.0.0:1200`
   - Fix: added `options.bind_address` with default `0.0.0.0:1200`, `ssl`, `certfile`, and `keyfile`.

2. Port mapping was inconsistent with the frontend process.
   - Previous mapping: `1200/tcp: 5000`
   - Nginx now listens on internal/direct port `1200`.
   - Fix: changed mapping to `1200/tcp: 1200`.

3. `host_network: true` was unnecessary for ingress and direct port mapping.
   - Portainer reference uses explicit ingress/port exposure rather than host networking.
   - Fix: removed `host_network: true`.

4. Sidebar integration now follows the Nginx ingress proxy pattern.
   - Existing: `ingress: true`, `panel_icon`, `panel_title`.
   - Fix: set `ingress_port: 8099`, added `ingress_stream: true`, and generated an Nginx ingress server that proxies to RSSHub.

5. HTTPS support is now explicit.
   - Home Assistant sidebar HTTPS is provided by Home Assistant ingress.
   - Direct HTTPS on port `1200` is available when `ssl: true` and `/ssl` certificates are configured.

6. S6-overlay structure was rebuilt.
   - Previous files mixed `/etc/s6-overlay/s6-rc.d` and `/etc/s6-overlay/s6-services`.
   - Fix: use Home Assistant base image paths: `/etc/cont-init.d/30-nginx.sh`, `/etc/services.d/rsshub`, and `/etc/services.d/nginx`.

7. The previous `run.sh` was redundant.
   - It exported `HOSTNAME`, which RSSHub does not use for binding.
   - Fix: removed the top-level startup script and moved runtime configuration into the S6 RSSHub service.

8. Health check targeted the generic root path.
   - RSSHub upstream compose uses `/healthz`.
   - Fix: changed Dockerfile health check to `http://127.0.0.1:1201/healthz`.

## Files Modified

- `config.yaml`
- `Dockerfile`
- `run.sh`
- `build.yaml`
- `README.md`
- `audit_report.md`
- `rootfs/etc/cont-init.d/30-nginx.sh`
- `rootfs/etc/services.d/rsshub/*`
- `rootfs/etc/services.d/nginx/*`
- `rootfs/etc/nginx/*`

## Files Removed

- invalid previous `rootfs/etc/s6-overlay/*` layout
- top-level `run.sh`

## Final Assessment

The add-on now uses the Portainer-style Nginx ingress pattern while keeping RSSHub as a local backend service. It supports sidebar ingress over Home Assistant HTTPS and optional direct HTTPS on port `1200`.
