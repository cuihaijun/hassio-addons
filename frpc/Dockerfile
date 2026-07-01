ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION
ARG FRP_VERSION=0.69.1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
    apk add --no-cache ca-certificates curl tar \
    && case "${BUILD_ARCH}" in \
        amd64) FRP_ARCH="amd64" ;; \
        aarch64) FRP_ARCH="arm64" ;; \
        armhf) FRP_ARCH="arm_hf" ;; \
        armv7) FRP_ARCH="arm" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz" -o /tmp/frp.tar.gz \
    && tar -xzf /tmp/frp.tar.gz -C /tmp \
    && mv "/tmp/frp_${FRP_VERSION}_linux_${FRP_ARCH}/frpc" /usr/local/bin/frpc \
    && chmod +x /usr/local/bin/frpc \
    && rm -rf /tmp/frp*

COPY run.sh /run.sh
RUN chmod +x /run.sh

LABEL \
  io.hass.name="${BUILD_NAME}" \
  io.hass.description="${BUILD_DESCRIPTION}" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="app" \
  io.hass.version="${BUILD_VERSION}" \
  maintainer="cuihaijun <cuihaijun@example.com>" \
  org.opencontainers.image.title="${BUILD_NAME}" \
  org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
  org.opencontainers.image.vendor="cuihaijun" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.revision="${BUILD_REF}" \
  org.opencontainers.image.version="${BUILD_VERSION}" \
  org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}"

CMD ["/run.sh"]
