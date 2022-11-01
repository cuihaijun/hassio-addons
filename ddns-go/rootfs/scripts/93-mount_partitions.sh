#!/usr/bin/with-contenv ddns-go

mkdir -p /addons
mount /dev/mmcblk0p8 /addons &>/dev/null && bashio::log.info "Data drive mounted in /addons"
