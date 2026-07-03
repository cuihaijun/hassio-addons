# Changelog

## 2026.7.8

- Added bundled Redis service managed by the add-on entrypoint and enabled Redis cache by default
- Added bundled Chromium runtime support through `CHROMIUM_EXECUTABLE_PATH`
- Kept `redis_url` and `playwright_ws_endpoint` as advanced external overrides
- Added `git` to the runtime image to avoid RSSHub startup warnings

## 2026.7.7

- Fixed RSSHub runtime option export so `cache_type`, `disallow_robot`, and cache manager settings are applied by the service process
- Added optional `access_key` support for RSSHub `ACCESS_KEY`
- Added optional `redis_url` support for RSSHub `REDIS_URL`
- Added optional `playwright_ws_endpoint` support for browserless/Playwright routes
- Updated README to document add-on options instead of unsupported `environment_variables`

## 2026.7.6

- Restored RSSHub environment variables configuration
- Added env vars to config.yaml options/schema (cache_type, cache_expire, etc.)
- Updated 40-rsshub-env.sh to read from config and export as environment variables
- Added default ENV values in Dockerfile

## 2026.7.5

- Simplified config.yaml to fix HA addon store visibility
- Removed invalid map types (addon_config, all_addon_configs)
- Fixed maintainer email in repository.json

## 2026.7.4

- Guarded S6 finish scripts so controlled restarts do not call a missing `/var/run/s6/services`.

## 2026.7.3

- Fixed duplicate Nginx `daemon` directive.
- Replaced `finish` scripts with shell scripts that do not depend on missing `s6-test`.

## 2026.7.2

- Fixed startup failure when `/etc/nginx/servers` did not exist before generating `rsshub.conf`.

## 2026.7.1

- Rebuilt the add-on around a Home Assistant base image and the upstream RSSHub app files.
- Added S6-managed RSSHub backend and Nginx frontend services.
- Added Home Assistant ingress listener on port 8099 for sidebar access.
- Added optional direct HTTPS on port 1200 using `/ssl` certificates.
- Fixed RSSHub backend binding to an internal localhost port behind Nginx.
- Removed the previous inactive S6-overlay rootfs layout and redundant top-level startup script.
