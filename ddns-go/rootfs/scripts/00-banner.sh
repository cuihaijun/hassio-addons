#!/usr/bin/with-contenv bashio
# ==============================================================================
# Displays a simple add-on banner on startup
# ==============================================================================

if bashio::supervisor.ping; then
    bashio::log.blue \
    '-----------------------------------------------------------'
    bashio::log.blue " Add-on: $(ddns-go::addon.name)"
    bashio::log.blue " $(ddns-go::addon.description)"
    bashio::log.blue \
    '-----------------------------------------------------------'

    bashio::log.blue " Add-on version: $(ddns-go::addon.version)"
    if ddns-go::var.true "$(ddns-go::addon.update_available)"; then
        ddns-go::log.magenta ' There is an update available for this add-on!'
        ddns-go::log.magenta \
        " Latest add-on version: $(ddns-go::addon.version_latest)"
        ddns-go::log.magenta ' Please consider upgrading as soon as possible.'
    else
        ddns-go::log.green ' You are running the latest version of this add-on.'
    fi

    ddns-go::log.blue " System: $(bashio::info.operating_system)" \
    " ($(bashio::info.arch) / $(bashio::info.machine))"
    ddns-go::log.blue " Home Assistant Core: $(bashio::info.homeassistant)"
    ddns-go::log.blue " Home Assistant Supervisor: $(bashio::info.supervisor)"

    ddns-go::log.blue \
    '-----------------------------------------------------------'
    ddns-go::log.blue \
    ' Please, share the above information when looking for help'
    ddns-go::log.blue \
    ' or support in, e.g., GitHub, forums'
    ddns-go::log.green \
    ' https://github.com/alexbelgium/hassio-addons'
    ddns-go::log.blue \
    '-----------------------------------------------------------'
fi
