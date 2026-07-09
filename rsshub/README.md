# RSSHub Home Assistant Addon

Generate RSS feeds for everything with RSSHub integrated into Home Assistant.

## Features

- Generate RSS feeds from any website
- Sidebar integration through Home Assistant ingress
- Opens through HTTPS when Home Assistant is accessed over HTTPS
- Optional direct HTTPS on port 1200 with Home Assistant `/ssl` certificates
- Nginx frontend plus RSSHub, Redis, and Chromium/Playwright support managed by the add-on entrypoint

## Installation

1. Add this repository to your Home Assistant addon store
2. Install the RSSHub addon
3. Start the addon
4. Access RSSHub through the Home Assistant sidebar

## Configuration

The addon listens on `0.0.0.0:1200` by default for direct access. Home Assistant ingress uses an internal Nginx listener on port `8099`.

### Basic Options

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
| `cache_type` | `redis` | RSSHub cache backend, `redis` uses the bundled Redis service. |
| `redis_url` | unset | Optional RSSHub `REDIS_URL` override. Leave empty to use bundled Redis. |
| `playwright_ws_endpoint` | unset | Optional RSSHub `PLAYWRIGHT_WS_ENDPOINT` override. Leave empty to use bundled Chromium. |
| `access_key` | unset | Optional RSSHub `ACCESS_KEY`. Leave empty to disable access-key protection. |
| `disallow_robot` | `false` | RSSHub `DISALLOW_ROBOT`. |
| `enable_cache_manager` | `true` | RSSHub `ENABLE_CACHE_MANAGER`. |
| `logger_level` | unset | Optional RSSHub log level. |

### Cache, Browserless, and Access Control

This add-on is packaged for the same out-of-the-box experience as the official Docker Compose example:

- RSSHub runs behind the add-on Nginx frontend.
- Redis runs inside the add-on and persists under the add-on `/data` directory.
- Chromium is installed in the add-on image and exposed to RSSHub through `CHROMIUM_EXECUTABLE_PATH`.

The default configuration is enough for Redis cache and Playwright-backed routes:

```yaml
cache_type: redis
redis_url: ""
playwright_ws_endpoint: ""
access_key: "change-me"
```

Set `redis_url` only when you want to use an external Redis instance. Set `playwright_ws_endpoint` only when you want to use an external browserless/Playwright service instead of bundled Chromium.

When `access_key` is set, pass the key with RSSHub URLs:

```text
https://homeassistant.local:1200/api/radar/rules?key=change-me
```

### Route-Specific Environment Variables

For route-specific secrets such as `GITHUB_ACCESS_TOKEN`, `YOUTUBE_KEY`, `WEIBO_COOKIES`, or `BILIBILI_COOKIE_你的UID`, create `routes_env.sh` in this add-on's Home Assistant public config folder and export the variables there.

Home Assistant mounts that folder at `/config` inside the add-on container, so RSSHub loads:

```text
/config/routes_env.sh
```

On the Home Assistant host, the folder is:

```text
/addon_configs/{REPO}_rsshub/
```

For a local add-on install, `{REPO}` is usually `local`. For a GitHub repository install, `{REPO}` is the repository hash shown by Home Assistant. Restart the add-on after editing.

Keep secrets out of public repository files.

HTTPS through the sidebar is provided by Home Assistant ingress when Home Assistant itself is served over HTTPS. Direct access to port `1200` is HTTP by default and becomes HTTPS only when `ssl: true`.

## Usage

Once installed, you can:
- Access RSSHub from the Home Assistant sidebar (look for the RSS icon)
- Use RSSHub API through ingress
- Use direct access at `http://homeassistant.local:1200`, or `https://homeassistant.local:1200` when `ssl: true`
- Generate RSS feeds for any supported source

## Support

For RSSHub documentation and supported routes, visit: https://docs.rsshub.app/
