ARG BUILD_VERSION="4.2.0"
ARG BUILD_UPSTREAM="4.2.0"
FROM ghcr.io/hassio-addons/base/amd64:11.0.0

RUN \
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
    nginx \
    \
    ##################
    # Install bashio #
    ##################
    && mkdir -p /tmp/bashio \
    && curl -L -f -s ""https://github.com/jeessy2/ddns-go/releases/download/v${BUILD_UPSTREAM}/ddns-go_${BUILD_UPSTREAM}_linux_${ARCH}.tar.gz"" \
    | tar -xzf - --strip 1 -C /tmp/ddns-go \
    && mv /tmp/ddns-go/lib /usr/lib/ddns-go \
    && ln -s /usr/lib/ddns-go/ddns-go /usr/bin/ddns-go \
    && rm -rf /tmp/ddns-go \
    \
    ########################################
    # Correct upstream image folders links #
    ########################################
    && mkdir -p -m 777 /config/ddns-go	|| true

# Copy root filesystem
COPY rootfs / 

VOLUME [ "/data" ]
WORKDIR /
RUN chmod 777 /entrypoint.sh
ENTRYPOINT [ "/usr/bin/env" ]
CMD [ "/entrypoint.sh" ] 


### LABELS
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="alexbelgium (https://github.com/alexbelgium)" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Add-ons" \
    org.opencontainers.image.authors="alexbelgium (https://github.com/alexbelgium)" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/alexbelgium" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
