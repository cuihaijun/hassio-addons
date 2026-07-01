# RSSHub Home Assistant Addon

Generate RSS feeds for everything with RSSHub integrated into Home Assistant.

## Features

- Generate RSS feeds from any website
- Sidebar integration through Home Assistant ingress
- Opens through HTTPS when Home Assistant is accessed over HTTPS
- Optional direct HTTPS on port 1200 with Home Assistant `/ssl` certificates
- Nginx frontend plus RSSHub backend managed by S6 services

## Installation

1. Add this repository to your Home Assistant addon store
2. Install the RSSHub addon
3. Start the addon
4. Access RSSHub through the Home Assistant sidebar

## Configuration

The addon listens on `0.0.0.0:1200` by default for direct access. Home Assistant ingress uses an internal Nginx listener on port `8099`.

| Option | Default | Description |
| --- | --- | --- |
| `bind_address` | `0.0.0.0:1200` | Direct access bind address for the Nginx frontend. |
| `ssl` | `false` | Enables direct HTTPS on `bind_address`. Home Assistant ingress HTTPS does not require this. |
| `certfile` | `fullchain.pem` | Certificate file in `/ssl`. Used only when `ssl` is `true`. |
| `keyfile` | `privkey.pem` | Private key file in `/ssl`. Used only when `ssl` is `true`. |
| `request_retry` | unset | Optional RSSHub `REQUEST_RETRY`. |
| `request_timeout` | unset | Optional RSSHub `REQUEST_TIMEOUT`. |
| `cache_expire` | unset | Optional RSSHub `CACHE_EXPIRE`. |
| `cache_content_expire` | unset | Optional RSSHub `CACHE_CONTENT_EXPIRE`. |
| `logger_level` | unset | Optional RSSHub log level. |

HTTPS through the sidebar is provided by Home Assistant ingress when Home Assistant itself is served over HTTPS. Direct access to port `1200` is HTTP by default and becomes HTTPS only when `ssl: true`.

## Usage

Once installed, you can:
- Access RSSHub from the Home Assistant sidebar (look for the RSS icon)
- Use RSSHub API through ingress
- Use direct access at `http://homeassistant.local:1200`, or `https://homeassistant.local:1200` when `ssl: true`
- Generate RSS feeds for any supported source

## Support

For RSSHub documentation and supported routes, visit: https://docs.rsshub.app/
