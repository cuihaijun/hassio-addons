#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant App: FreshRSS
# ------------------------------------------------------------------------------
LOG_FILE="/config/logs/refresh.log"

main() {
    bashio::log.trace "${FUNCNAME[0]}"

    mkdir -p /config/logs

    while true; do
        /usr/bin/php83 /usr/share/freshrss/app/actualize_script.php \
            >> "${LOG_FILE}" 2>&1

        # Trigger logrotate (configured to rotate when files exceed 5 MiB)
        logrotate /etc/logrotate.d/freshrss 2>/dev/null || true

        sleep 1200
    done
}
main "$@"