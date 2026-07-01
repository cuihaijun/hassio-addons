ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ghcr.io/diygod/rsshub:latest AS rsshub
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

RUN apk add --no-cache curl nginx npm

COPY --from=rsshub /app /app
COPY rootfs/ /
RUN find /etc/cont-init.d /etc/services.d -type f -print -exec chmod +x {} \;

WORKDIR /

EXPOSE 1200
EXPOSE 8099

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://127.0.0.1:1201/healthz || exit 1

LABEL \
  io.hass.name="${BUILD_NAME}" \
  io.hass.description="${BUILD_DESCRIPTION}" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  io.hass.version="${BUILD_VERSION}" \
  maintainer="cuihaijun" \
  org.opencontainers.image.title="${BUILD_NAME}" \
  org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
  org.opencontainers.image.vendor="Home Assistant Add-ons" \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.revision="${BUILD_REF}" \
  org.opencontainers.image.version="${BUILD_VERSION}" \
  org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}"
