#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# RSSHub Environment Variables Initialization
# 从 HA Add-on 配置读取环境变量并导出给 RSSHub 使用
# ==============================================================================

set -e

bashio::log.info "Loading RSSHub environment variables from addon configuration..."

# 检查是否有 environment_variables 配置
if bashio::config.exists 'environment_variables'; then
  bashio::log.info "Custom environment variables detected, loading..."
  
  # 遍历所有配置的环境变量
  for key in $(bashio::config keys 'environment_variables'); do
    value="$(bashio::config "environment_variables.${key}")"
    if [[ -n "${value}" ]]; then
      export "${key}=${value}"
      bashio::log.info "  Set ${key}=${value}"
    fi
  done
  
  bashio::log.info "RSSHub custom environment variables loaded successfully."
else
  bashio::log.info "No custom environment variables configured, using defaults."
  
  # 设置默认环境变量
  export NODE_ENV="${NODE_ENV:-production}"
  export CACHE_TYPE="${CACHE_TYPE:-memory}"
  export CACHE_EXPIRE="${CACHE_EXPIRE:-3600}"
  export CACHE_CONTENT_EXPIRE="${CACHE_CONTENT_EXPIRE:-3600}"
  export DISALLOW_ROBOT="${DISALLOW_ROBOT:-false}"
  export ENABLE_CACHE_MANAGER="${ENABLE_CACHE_MANAGER:-true}"
  export REQUEST_RETRY="${REQUEST_RETRY:-3}"
  export REQUEST_TIMEOUT="${REQUEST_TIMEOUT:-30000}"
  
  bashio::log.info "Default environment variables set."
fi

bashio::log.info "RSSHub environment initialization complete."
