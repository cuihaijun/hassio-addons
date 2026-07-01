#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configure nginx for ingress
# ==============================================================================

INGRESS_ENTRY=$(bashio::addon.ingress_entry)
bashio::log.info "Configuring nginx for ingress entry: ${INGRESS_ENTRY}"

# Update nginx config with ingress entry
sed -i "s|INGRESS_ENTRY_PLACEHOLDER|${INGRESS_ENTRY}|g" /etc/nginx/conf.d/default.conf
