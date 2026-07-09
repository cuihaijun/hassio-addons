# Changelog

## 2026.7.7

- Remove `unsafe-eval` from the ingress CSP so FreshRSS no longer shows the unsafe CSP warning.

## 2026.7.6

- Keep FreshRSS internal user log directory for anonymous image/favicon proxy requests.
- Allow external and data URI images in the ingress CSP so subscription content images render inside Home Assistant.
- Collapse duplicated ingress prefixes produced by response URL rewriting.
- Match the default direct-access SSL option with the current Home Assistant App configuration.

## 2026.7.5

- Use a safer ingress CSP header that keeps FreshRSS XSS protections while allowing Home Assistant sidebar embedding.

## 2026.7.4

- Hide FreshRSS FastCGI frame-blocking headers in ingress so the sidebar iframe can render.

## 2026.7.3

- Pass Home Assistant ingress prefix to FreshRSS PHP requests so redirects stay under ingress.

## 2026.7.2

- Fixed deprecated bashio calls (use `bashio::app.*` instead of `bashio::addon.*`)
- Fixed nginx http2 directive warning
- Fixed users/_ directory creation for shared logs
- Added ingress support with sidebar panel

## 2026.7.1

- Initial release with Home Assistant ingress support
- Added direct HTTPS on port 7077 using `/ssl` certificates
- Added PHP-FPM backend with Nginx frontend
- Added Home Assistant sidebar panel (FreshRSS)
