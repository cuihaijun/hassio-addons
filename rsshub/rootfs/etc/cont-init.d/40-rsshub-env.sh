#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# RSSHub Environment Variables Initialization
# 从 HA Add-on 配置读取环境变量并导出给 RSSHub 使用
# ==============================================================================

set -e

bashio::log.info "Loading RSSHub environment variables from addon configuration..."

# 从 config.yaml 读取并导出为环境变量
export NODE_ENV="${NODE_ENV:-production}"
export CACHE_TYPE="$(bashio::config 'cache_type')"
export CACHE_EXPIRE="$(bashio::config 'cache_expire')"
export CACHE_CONTENT_EXPIRE="$(bashio::config 'cache_content_expire')"
export DISALLOW_ROBOT="$(bashio::config 'disallow_robot')"
export ENABLE_CACHE_MANAGER="$(bashio::config 'enable_cache_manager')"
export REQUEST_RETRY="$(bashio::config 'request_retry')"
export REQUEST_TIMEOUT="$(bashio::config 'request_timeout')"
export LOGGER_LEVEL="$(bashio::config 'logger_level')"

bashio::log.info "RSSHub environment variables loaded:"
bashio::log.info "  CACHE_TYPE=${CACHE_TYPE}"
bashio::log.info "  CACHE_EXPIRE=${CACHE_EXPIRE}"
bashio::log.info "  CACHE_CONTENT_EXPIRE=${CACHE_CONTENT_EXPIRE}"
bashio::log.info "  DISALLOW_ROBOT=${DISALLOW_ROBOT}"
bashio::log.info "  ENABLE_CACHE_MANAGER=${ENABLE_CACHE_MANAGER}"
bashio::log.info "  REQUEST_RETRY=${REQUEST_RETRY}"
bashio::log.info "  REQUEST_TIMEOUT=${REQUEST_TIMEOUT}"
bashio::log.info "  LOGGER_LEVEL=${LOGGER_LEVEL}"

bashio::log.info "RSSHub environment initialization complete."
