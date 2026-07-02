#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

set -euo pipefail

CONFIG_FILE=/tmp/frpc.toml

toml_escape() {
  local value="${1}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "${value}"
}

server_addr="$(bashio::config 'frp_server')"
server_port="$(bashio::config 'frp_server_port')"
token="$(bashio::config 'frp_token')"
local_host="$(bashio::config 'local_host')"
local_port="$(bashio::config 'local_port')"
tunnel_type="$(bashio::config 'tunnel_type')"
proxy_name="$(bashio::config 'proxy_name')"
http_domain="$(bashio::config 'http_domain')"
http_subdomain_host="$(bashio::config 'http_subdomain_host')"
tcp_remote_port="$(bashio::config 'tcp_remote_port')"
transport_protocol="$(bashio::config 'transport_protocol')"
tls_enable="$(bashio::config 'tls_enable')"
auth_heartbeats="$(bashio::config 'auth_heartbeats')"
auth_new_work_conns="$(bashio::config 'auth_new_work_conns')"
log_level="$(bashio::config 'log_level')"
admin_enable="$(bashio::config 'admin_enable')"
admin_addr="$(bashio::config 'admin_addr')"
admin_port="$(bashio::config 'admin_port')"
admin_user="$(bashio::config 'admin_user')"
admin_password="$(bashio::config 'admin_password')"

if [[ -z "${server_addr}" ]]; then
  bashio::exit.nok "Option 'frp_server' is required."
fi

if [[ -z "${token}" ]]; then
  bashio::exit.nok "Option 'frp_token' is required. Use your own frps token; no default token is bundled."
fi

if [[ -z "${proxy_name}" ]]; then
  proxy_name="homeassistant"
fi

server_addr_toml="$(toml_escape "${server_addr}")"
token_toml="$(toml_escape "${token}")"
transport_protocol_toml="$(toml_escape "${transport_protocol}")"
log_level_toml="$(toml_escape "${log_level}")"
admin_addr_toml="$(toml_escape "${admin_addr}")"
admin_user_toml="$(toml_escape "${admin_user}")"
admin_password_toml="$(toml_escape "${admin_password}")"
proxy_name_toml="$(toml_escape "${proxy_name}")"
tunnel_type_toml="$(toml_escape "${tunnel_type}")"
local_host_toml="$(toml_escape "${local_host}")"
http_subdomain_host_toml="$(toml_escape "${http_subdomain_host}")"
http_domain_toml="$(toml_escape "${http_domain}")"

cat > "${CONFIG_FILE}" <<EOF
serverAddr = "${server_addr_toml}"
serverPort = ${server_port}
loginFailExit = true

auth.method = "token"
auth.token = "${token_toml}"

transport.protocol = "${transport_protocol_toml}"
transport.tls.enable = ${tls_enable}

log.to = "console"
log.level = "${log_level_toml}"

EOF

auth_scopes=()
if bashio::var.true "${auth_heartbeats}"; then
  auth_scopes+=('"HeartBeats"')
fi
if bashio::var.true "${auth_new_work_conns}"; then
  auth_scopes+=('"NewWorkConns"')
fi
if (( ${#auth_scopes[@]} > 0 )); then
  auth_scopes_toml="$(IFS=,; printf '%s' "${auth_scopes[*]}")"
  cat >> "${CONFIG_FILE}" <<EOF
auth.additionalScopes = [${auth_scopes_toml}]

EOF
fi

if bashio::var.true "${admin_enable}"; then
  cat >> "${CONFIG_FILE}" <<EOF
webServer.addr = "${admin_addr_toml}"
webServer.port = ${admin_port}
webServer.user = "${admin_user_toml}"
webServer.password = "${admin_password_toml}"

EOF
fi

cat >> "${CONFIG_FILE}" <<EOF
[[proxies]]
name = "${proxy_name_toml}"
type = "${tunnel_type_toml}"
localIP = "${local_host_toml}"
localPort = ${local_port}
EOF

if [[ "${tunnel_type}" == "tcp" ]]; then
  if [[ -z "${tcp_remote_port}" || "${tcp_remote_port}" == "null" ]]; then
    bashio::exit.nok "Option 'tcp_remote_port' is required when tunnel_type is tcp."
  fi
  cat >> "${CONFIG_FILE}" <<EOF
remotePort = ${tcp_remote_port}
EOF
  bashio::log.info "FRP TCP tunnel: ${server_addr}:${tcp_remote_port} -> ${local_host}:${local_port}"
else
  if [[ -z "${http_subdomain_host}" && -z "${http_domain}" ]]; then
    bashio::exit.nok "At least one of 'http_domain' or 'http_subdomain_host' is required when tunnel_type is http."
  fi
  if [[ -n "${http_subdomain_host}" && "${http_subdomain_host}" != "null" ]]; then
    cat >> "${CONFIG_FILE}" <<EOF
subdomain = "${http_subdomain_host_toml}"
EOF
  fi
  if [[ -n "${http_domain}" && "${http_domain}" != "null" ]]; then
    cat >> "${CONFIG_FILE}" <<EOF
customDomains = ["${http_domain_toml}"]
EOF
  fi
  cat >> "${CONFIG_FILE}" <<EOF
locations = ["/"]
EOF
  bashio::log.info "FRP HTTP tunnel: ${local_host}:${local_port}"
fi

bashio::log.info "Starting frpc ${proxy_name} with frp config ${CONFIG_FILE}"
exec /usr/local/bin/frpc -c "${CONFIG_FILE}"
