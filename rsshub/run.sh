#!/usr/bin/with-contenv bashio
# ==============================================================================
# RSSHub Start Script with Reverse Proxy Support
# ==============================================================================

# 信任反向代理（HA Ingress）
export TRUST_PROXY=true

# 从 HA 配置读取选项（如果存在）
if [ -f /data/options.json ]; then
    # 读取用户配置的环境变量
    if bashio::config.has_value 'request_retry'; then
        export REQUEST_RETRY=$(bashio::config 'request_retry')
    fi
    if bashio::config.has_value 'request_timeout'; then
        export REQUEST_TIMEOUT=$(bashio::config 'request_timeout')
    fi
    if bashio::config.has_value 'cache_expire'; then
        export CACHE_EXPIRE=$(bashio::config 'cache_expire')
    fi
    if bashio::config.has_value 'cache_content_expire'; then
        export CACHE_CONTENT_EXPIRE=$(bashio::config 'cache_content_expire')
    fi
    if bashio::config.has_value 'logger_level'; then
        export LOGGER_LEVEL=$(bashio::config 'logger_level')
    fi
fi

bashio::log.info "Starting RSSHub with reverse proxy support..."
bashio::log.info "TRUST_PROXY=${TRUST_PROXY}"

# 启动 RSSHub
cd /app
npm start
