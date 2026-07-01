ARG BUILD_FROM
FROM diygod/rsshub:latest

# Copy root filesystem
COPY rootfs /

# Set working directory
WORKDIR /app

# Expose RSSHub port
EXPOSE 1200

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:1200/ || exit 1
