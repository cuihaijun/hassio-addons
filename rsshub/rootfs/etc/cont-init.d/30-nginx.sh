#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

declare bind_address
declare bind_host
declare bind_port
declare direct_ssl
declare ingress_entry

bind_address="$(bashio::config 'bind_address')"
bind_host="${bind_address%:*}"
bind_port="${bind_address##*:}"
direct_ssl="false"
ingress_entry="$(bashio::addon.ingress_entry)"

if [[ "${bind_host}" == "${bind_address}" || -z "${bind_host}" || -z "${bind_port}" ]]; then
  bashio::log.fatal "bind_address must use host:port format, got: ${bind_address}"
  exit 1
fi

if bashio::config.true 'ssl'; then
  bashio::config.require.ssl
  direct_ssl="true"
  bashio::log.info "Direct HTTPS enabled on ${bind_address}"
else
  bashio::log.info "Direct HTTP enabled on ${bind_address}"
fi

[[ "${ingress_entry}" =~ ^/(.*)$ ]] && ingress_entry="${BASH_REMATCH[1]}"

bashio::var.json \
  bind_host "${bind_host}" \
  bind_port "^${bind_port}" \
  ingress_host "$(bashio::addon.ip_address)" \
  ingress_port "^$(bashio::addon.ingress_port)" \
  ingress_entry "${ingress_entry}" \
  certfile "$(bashio::config 'certfile')" \
  keyfile "$(bashio::config 'keyfile')" \
  direct_ssl "^${direct_ssl}" \
  | tempio \
    -template /etc/nginx/templates/rsshub.gtpl \
    -out /etc/nginx/servers/rsshub.conf
