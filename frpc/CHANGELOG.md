# Changelog

## 2026.7.1

- Migrated from legacy `config.json` add-on metadata to HA App System style `config.yaml`.
- Updated frp client from `0.44` to `0.69.1`.
- Replaced legacy command-line proxy startup with generated `frpc.toml`.
- Removed the bundled public test token from default options.
- Removed i386 support because frp `0.69.1` no longer publishes a linux 386 release asset.
