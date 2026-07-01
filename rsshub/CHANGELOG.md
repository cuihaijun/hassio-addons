# Changelog

## 2026.7.1

- Rebuilt the add-on around a Home Assistant base image and the upstream RSSHub app files.
- Added S6-managed RSSHub backend and Nginx frontend services.
- Added Home Assistant ingress listener on port 8099 for sidebar access.
- Added optional direct HTTPS on port 1200 using `/ssl` certificates.
- Fixed RSSHub backend binding to an internal localhost port behind Nginx.
- Removed the previous inactive S6-overlay rootfs layout and redundant top-level startup script.

## 1.0.0

- Initial release
- RSSHub addon for Home Assistant
- Ingress support for sidebar integration
- HTTPS support through Home Assistant ingress
- Default port: 1200
