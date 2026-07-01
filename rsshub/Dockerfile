# 直接使用官方 RSSHub 镜像
FROM diygod/rsshub:latest

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION="RSSHub Add-on for Home Assistant"
ARG BUILD_NAME="RSSHub"
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# 添加 HA App System 标签
LABEL \
  io.hass.name="${BUILD_NAME}" \
  io.hass.description="${BUILD_DESCRIPTION}" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="app" \
  io.hass.version="${BUILD_VERSION}" \
  maintainer="cuihaijun" \
  org.opencontainers.image.title="${BUILD_NAME}" \
  org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
  org.opencontainers.image.vendor="cuihaijun" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.revision="${BUILD_REF}" \
  org.opencontainers.image.version="${BUILD_VERSION}" \
  org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}"

# 暴露端口
EXPOSE 1200

# 设置环境变量
ENV NODE_ENV=production
ENV PORT=1200

# 启动命令
CMD ["npm", "start"]
