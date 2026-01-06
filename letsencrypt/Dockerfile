ARG BUILD_FROM
FROM $BUILD_FROM

# setup base
ARG \
    BUILD_ARCH \
    CRYPTOGRAPHY_VERSION \
    CERTBOT_VERSION \
    CERTBOT_DNS_ALIYUN_VERSION \
    ACME_VERSION

RUN \
    set -x \
    && apk add --no-cache --update \
        libffi \
        musl \
        openssl \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        libffi-dev \
        musl-dev \
        openssl-dev \
        cargo \
    && pip3 install --no-cache-dir --find-links \
        "https://wheels.home-assistant.io/alpine-$(cut -d '.' -f 1-2 < /etc/alpine-release)/${BUILD_ARCH}/" \ 
        cryptography==${CRYPTOGRAPHY_VERSION} \
        certbot==${CERTBOT_VERSION} \
        certbot-dns-aliyun==${CERTBOT_DNS_ALIYUN_VERSION} \
        acme==${ACME_VERSION} \
    && apk del .build-dependencies

# Copy data
COPY rootfs /
