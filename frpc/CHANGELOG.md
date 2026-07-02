# Changelog

## 2026.7.2

- Bump add-on version so Home Assistant can pick up the frpc auth scope compatibility options.

## 2026.7.1

- Migrated from legacy `config.json` add-on metadata to HA App System style `config.yaml`.
- Updated frp client from `0.44` to `0.69.1`.
- Replaced legacy command-line proxy startup with generated `frpc.toml`.
- Added optional heartbeat and new work connection auth scope settings for frps compatibility.
- Removed the bundled public test token from default options.
- Removed i386 support because frp `0.69.1` no longer publishes a linux 386 release asset.
