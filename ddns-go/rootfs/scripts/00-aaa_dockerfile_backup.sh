#!/bin/bash
# If dockerfile failed install manually
if [ ! -f "/usr/bin/ddns-go" ]; then
    echo "Bashio does not exist, executing script"
    (
        ################
        # Install apps #
        ################
        apk add --no-cache \
            curl \
            jq \
            bash \
            cifs-utils \
            keyutils \
            samba \
            samba-client \
            bind-tools \
            nginx

        ###################
        # Install ddns-go #
        ##################
        BASHIO_VERSION=4.2.0
        mkdir -p /tmp/ddns-go
        curl -L -f -s ""https://github.com/jeessy2/ddns-go/releases/download/v${BUILD_UPSTREAM}/ddns-go_${BUILD_UPSTREAM}_linux_${ARCH}.tar.gz"" |
            tar -xzf - --strip 1 -C /tmp/ddns-go
        mv /tmp/ddns-go/lib /usr/lib/ddns-go
        ln -s /usr/lib/ddns-go/ddns-go /usr/bin/ddns-go
        rm -rf /tmp/ddns-go

        ########################################
        # Correct upstream image folders links #
        ########################################
        mkdir -p -m 777 /config/ddns-go || true

    ) >/dev/null
    echo "ddns-go installed"
fi
