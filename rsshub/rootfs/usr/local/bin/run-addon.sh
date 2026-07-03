#!/bin/sh
set -eu

log() {
  printf '[rsshub-addon] %s\n' "$*"
}

json_get() {
  node -e '
const fs = require("fs");
const file = process.argv[1];
const key = process.argv[2];
const fallback = process.argv[3] ?? "";
let data = {};
try { data = JSON.parse(fs.readFileSync(file, "utf8")); } catch {}
let value = data[key];
if (value === undefined || value === null || value === "") value = fallback;
if (typeof value === "boolean") value = value ? "true" : "false";
process.stdout.write(String(value));
' "$1" "$2" "${3:-}"
}

json_stdin_get() {
  node -e '
let input = "";
process.stdin.on("data", chunk => input += chunk);
process.stdin.on("end", () => {
  const path = process.argv[1].split(".");
  const fallback = process.argv[2] ?? "";
  let data = {};
  try { data = JSON.parse(input); } catch {}
  let value = data;
  for (const part of path) value = value && value[part];
  if (value === undefined || value === null || value === "") value = fallback;
  process.stdout.write(String(value));
});
' "$1" "${2:-}"
}

OPTIONS_FILE=/data/options.json
if [ ! -f "$OPTIONS_FILE" ]; then
  log "Options file not found at $OPTIONS_FILE; using defaults."
fi

bind_address="$(json_get "$OPTIONS_FILE" bind_address "0.0.0.0:1200")"
bind_host="${bind_address%:*}"
bind_port="${bind_address##*:}"
if [ "$bind_host" = "$bind_address" ] || [ -z "$bind_host" ] || [ -z "$bind_port" ]; then
  log "bind_address must use host:port format, got: $bind_address"
  exit 1
fi

certfile="$(json_get "$OPTIONS_FILE" certfile "fullchain.pem")"
keyfile="$(json_get "$OPTIONS_FILE" keyfile "privkey.pem")"
ssl="$(json_get "$OPTIONS_FILE" ssl "false")"

export NO_LOGFILES=true
export TITLE_LENGTH_LIMIT=255
export PORT=1201
export LISTEN_INADDR_ANY=false
export DISABLE_IPV6=true
export NODE_ENV="${NODE_ENV:-production}"
export CACHE_TYPE
export REDIS_URL
export CACHE_EXPIRE
export CACHE_CONTENT_EXPIRE
export DISALLOW_ROBOT
export ENABLE_CACHE_MANAGER
export REQUEST_RETRY
export REQUEST_TIMEOUT
export LOGGER_LEVEL
export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-/app/node_modules/.cache/ms-playwright}"

CACHE_TYPE="$(json_get "$OPTIONS_FILE" cache_type "redis")"
REDIS_URL="$(json_get "$OPTIONS_FILE" redis_url "")"
if [ -z "$REDIS_URL" ]; then
  REDIS_URL="redis://127.0.0.1:6379/"
fi
CACHE_EXPIRE="$(json_get "$OPTIONS_FILE" cache_expire "3600")"
CACHE_CONTENT_EXPIRE="$(json_get "$OPTIONS_FILE" cache_content_expire "3600")"
DISALLOW_ROBOT="$(json_get "$OPTIONS_FILE" disallow_robot "false")"
ENABLE_CACHE_MANAGER="$(json_get "$OPTIONS_FILE" enable_cache_manager "true")"
REQUEST_RETRY="$(json_get "$OPTIONS_FILE" request_retry "3")"
REQUEST_TIMEOUT="$(json_get "$OPTIONS_FILE" request_timeout "30000")"
LOGGER_LEVEL="$(json_get "$OPTIONS_FILE" logger_level "info")"

access_key="$(json_get "$OPTIONS_FILE" access_key "")"
if [ -n "$access_key" ]; then
  export ACCESS_KEY="$access_key"
fi

playwright_ws_endpoint="$(json_get "$OPTIONS_FILE" playwright_ws_endpoint "")"
if [ -n "$playwright_ws_endpoint" ]; then
  export PLAYWRIGHT_WS_ENDPOINT="$playwright_ws_endpoint"
else
  chromium_path="$(find "$PLAYWRIGHT_BROWSERS_PATH" -type f -path '*/chrome-linux64/chrome' | head -1 || true)"
  if [ -n "$chromium_path" ]; then
    export CHROMIUM_EXECUTABLE_PATH="$chromium_path"
  fi
fi

info_json=""
if [ -n "${SUPERVISOR_TOKEN:-}" ]; then
  info_json="$(curl -sS -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" http://supervisor/addons/self/info || true)"
fi
ingress_host="$(printf '%s' "$info_json" | json_stdin_get data.ip_address "127.0.0.1")"
ingress_port="$(printf '%s' "$info_json" | json_stdin_get data.ingress_port "8099")"
ingress_entry="$(printf '%s' "$info_json" | json_stdin_get data.ingress_entry "")"
ingress_entry="${ingress_entry#/}"

mkdir -p /etc/nginx/servers /run/nginx
{
  cat <<EOF
server {
  listen ${ingress_host}:${ingress_port} default_server;
  server_name _;

  allow 172.30.32.2;
  deny all;

  client_max_body_size 4G;

  proxy_hide_header X-Frame-Options;
  proxy_hide_header Content-Security-Policy;
  add_header X-Frame-Options "SAMEORIGIN";
  add_header Content-Security-Policy "frame-ancestors *";

  location / {
    proxy_pass http://127.0.0.1:1201/;
    proxy_http_version 1.1;
    proxy_set_header Connection \$connection_upgrade;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Host \$http_host;
    proxy_set_header X-Forwarded-Host \$http_host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-NginX-Proxy true;
    proxy_set_header Accept-Encoding "";

    sub_filter_once off;
    sub_filter_types *;
    sub_filter href="/ href="/${ingress_entry}/;
    sub_filter src="/ src="/${ingress_entry}/;
    sub_filter action="/ action="/${ingress_entry}/;
  }
}

server {
EOF
  if [ "$ssl" = "true" ]; then
    printf '  listen %s:%s ssl;\n' "$bind_host" "$bind_port"
  else
    printf '  listen %s:%s;\n' "$bind_host" "$bind_port"
  fi
  cat <<EOF
  server_name _;
EOF
  if [ "$ssl" = "true" ]; then
    cat <<EOF
  ssl_certificate /ssl/${certfile};
  ssl_certificate_key /ssl/${keyfile};
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
EOF
  fi
  cat <<'EOF'

  client_max_body_size 4G;

  location / {
    proxy_pass http://127.0.0.1:1201/;
    proxy_http_version 1.1;
    proxy_set_header Connection $connection_upgrade;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Host $http_host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-NginX-Proxy true;
  }
}
EOF
} > /etc/nginx/servers/rsshub.conf

if [ "$CACHE_TYPE" = "redis" ] && [ "$REDIS_URL" = "redis://127.0.0.1:6379/" ]; then
  log "Starting bundled Redis on 127.0.0.1:6379"
  mkdir -p /data/redis
  redis-server \
    --bind 127.0.0.1 \
    --port 6379 \
    --dir /data/redis \
    --appendonly yes \
    --save 60 1 \
    --loglevel notice &
fi

if [ -f /addon_configs/rsshub/routes_env.sh ]; then
  # shellcheck disable=SC1091
  . /addon_configs/rsshub/routes_env.sh
fi

log "Starting RSSHub backend on 127.0.0.1:1201"
log "RSSHub cache type: ${CACHE_TYPE}"
if [ "${CHROMIUM_EXECUTABLE_PATH:-}" ]; then
  log "RSSHub Chromium executable: ${CHROMIUM_EXECUTABLE_PATH}"
fi
cd /app
npm run start &
rsshub_pid=$!

for _ in $(seq 1 90); do
  if curl -fsS http://127.0.0.1:1201/healthz >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

log "Starting Nginx frontend"
nginx -g 'daemon off;' &
nginx_pid=$!

trap 'kill "$rsshub_pid" "$nginx_pid" 2>/dev/null || true; wait' INT TERM
while :; do
  if ! kill -0 "$rsshub_pid" 2>/dev/null; then
    wait "$rsshub_pid"
    exit $?
  fi
  if ! kill -0 "$nginx_pid" 2>/dev/null; then
    wait "$nginx_pid"
    exit $?
  fi
  sleep 1
done
