FROM ghcr.io/diygod/rsshub:chromium-bundled

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      git \
      nginx \
      procps \
      redis-server \
    && rm -rf /var/lib/apt/lists/*

# RSSHub 默认环境变量
ENV NODE_ENV=production \
    CACHE_TYPE=redis \
    REDIS_URL=redis://127.0.0.1:6379/ \
    CACHE_EXPIRE=3600 \
    CACHE_CONTENT_EXPIRE=3600 \
    PLAYWRIGHT_BROWSERS_PATH=/app/node_modules/.cache/ms-playwright \
    DISALLOW_ROBOT=false \
    ENABLE_CACHE_MANAGER=true \
    REQUEST_RETRY=3 \
    REQUEST_TIMEOUT=30000 \
    LOGGER_LEVEL=info

COPY rootfs/ /
RUN chmod +x /usr/local/bin/run-addon.sh

WORKDIR /app

EXPOSE 1200
EXPOSE 8099

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://127.0.0.1:1201/healthz || exit 1

ENTRYPOINT ["dumb-init", "--", "/usr/local/bin/run-addon.sh"]
CMD []

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
