# RSSHub Add-on Structure Audit

Date: 2026-07-03

## Reference

- Reference deployment: official RSSHub Docker Compose
- Reference add-on patterns checked from local files:
  - `config.yaml`
  - `Dockerfile`
  - `rootfs/usr/local/bin/run-addon.sh`
  - Nginx ingress/direct HTTPS support files

## Findings

1. `config.yaml` exposes HTTPS-ready ingress/frontend settings.
   - Required value: `0.0.0.0:1200`
   - Current: `options.bind_address` defaults to `0.0.0.0:1200`; `ssl`, `certfile`, and `keyfile` support direct HTTPS.

2. Port mapping was inconsistent with the frontend process.
   - Previous mapping: `1200/tcp: 5000`
   - Nginx now listens on internal/direct port `1200`.
   - Fix: changed mapping to `1200/tcp: 1200`.

3. `host_network: true` was unnecessary for ingress and direct port mapping.
   - Portainer reference uses explicit ingress/port exposure rather than host networking.
   - Fix: removed `host_network: true`.

4. Sidebar integration follows the Nginx ingress proxy pattern.
   - Current: `ingress: true`, `panel_icon`, `panel_title`, `ingress_port: 8099`, `ingress_stream: true`.
   - Runtime: `run-addon.sh` reads Supervisor `/addons/self/info` and generates an Nginx ingress server that proxies to RSSHub.

5. HTTPS support is now explicit.
   - Home Assistant sidebar HTTPS is provided by Home Assistant ingress.
   - Direct HTTPS on port `1200` is available when `ssl: true` and `/ssl` certificates are configured.

6. Runtime now targets the official Compose-style complete experience.
   - Current base image: `ghcr.io/diygod/rsshub:chromium-bundled`.
   - Current bundled services: RSSHub, Nginx, Redis.
   - Browser support: bundled Chromium/Playwright via `CHROMIUM_EXECUTABLE_PATH`.

7. The previous S6/Home Assistant base layout is no longer used.
   - Current entrypoint: `/usr/local/bin/run-addon.sh`.
   - The entrypoint reads `/data/options.json`, starts Redis when `cache_type=redis`, starts RSSHub on `127.0.0.1:1201`, then starts Nginx.

8. Health check targeted the generic root path.
   - RSSHub upstream compose uses `/healthz`.
   - Current health check: `http://127.0.0.1:1201/healthz`.

## Files Modified

- `config.yaml`
- `Dockerfile`
- `build.yaml`
- `README.md`
- `audit_report.md`
- `rootfs/usr/local/bin/run-addon.sh`
- `rootfs/etc/nginx/*`

## Files Removed

- invalid previous `rootfs/etc/s6-overlay/*` layout
- top-level `run.sh`
- obsolete Home Assistant base/S6 files under `rootfs/etc/cont-init.d` and `rootfs/etc/services.d`
- obsolete tempio Nginx template

## Final Assessment

The add-on now uses a single entrypoint on top of `rsshub:chromium-bundled`, giving the same default dependency experience as the official RSSHub Docker Compose deployment: RSSHub, Redis, and browser-capable Playwright support are available without requiring separate HA add-ons or external containers. It supports sidebar ingress over Home Assistant HTTPS and optional direct HTTPS on port `1200`.
