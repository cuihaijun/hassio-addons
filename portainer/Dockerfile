ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:12.2.4
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
ARG BUILD_ARCH=amd64
ARG BUILD_UPSTREAM="2.16.0"
ENV PACKAGES="nginx"

RUN \
    BUILD_ARCH=$(uname -m) \
    && echo "${BUILD_ARCH}" \
    && BUILD_ARCH=${BUILD_ARCH:-x86} \
    && if [[ "${BUILD_ARCH}" == *aarch64* ]]; then ARCH="arm64"; fi \
    && if [[ "${BUILD_ARCH}" == *armv8* ]]; then ARCH="arm64"; fi \
    && if [[ "${BUILD_ARCH}" == *arm64* ]]; then ARCH="arm64"; fi \
    && if [[ "${BUILD_ARCH}" == *armhf* ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" == *armv7* ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" == arm ]]; then ARCH="arm"; fi \
    && if [[ "${BUILD_ARCH}" == *x86* ]]; then ARCH="amd64"; fi \
    \
    && curl -f -L -s \
    "https://github.com/portainer/portainer/releases/download/${BUILD_UPSTREAM}/portainer-${BUILD_UPSTREAM}-linux-${ARCH}.tar.gz" \
    | tar zxvf - -C /opt/ || printf '%s\n' "${BUILD_UPSTREAM}" > /PORTFILE


RUN \
    apk add --no-cache ${PACKAGES} || true

# Copy root filesystem
COPY rootfs /

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
