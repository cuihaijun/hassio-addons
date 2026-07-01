#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# RSSHub Environment Variables Initialization
# 从 HA Add-on 配置读取环境变量并导出给 RSSHub 使用
# ==============================================================================

set -e

bashio::log.info "Loading RSSHub environment variables from addon configuration..."

# 基础配置
export NODE_ENV="${NODE_ENV:-production}"
export CACHE_TYPE="$(bashio::config 'cache_type')"
export CACHE_EXPIRE="$(bashio::config 'cache_expire')"
export CACHE_CONTENT_EXPIRE="$(bashio::config 'cache_content_expire')"
export DISALLOW_ROBOT="$(bashio::config 'disallow_robot')"
export ENABLE_CACHE_MANAGER="$(bashio::config 'enable_cache_manager')"
export REQUEST_RETRY="$(bashio::config 'request_retry')"
export REQUEST_TIMEOUT="$(bashio::config 'request_timeout')"
export LOGGER_LEVEL="$(bashio::config 'logger_level')"

bashio::log.info "RSSHub basic environment variables loaded:"
bashio::log.info "  CACHE_TYPE=${CACHE_TYPE}"
bashio::log.info "  CACHE_EXPIRE=${CACHE_EXPIRE}"
bashio::log.info "  CACHE_CONTENT_EXPIRE=${CACHE_CONTENT_EXPIRE}"
bashio::log.info "  DISALLOW_ROBOT=${DISALLOW_ROBOT}"
bashio::log.info "  ENABLE_CACHE_MANAGER=${ENABLE_CACHE_MANAGER}"
bashio::log.info "  REQUEST_RETRY=${REQUEST_RETRY}"
bashio::log.info "  REQUEST_TIMEOUT=${REQUEST_TIMEOUT}"
bashio::log.info "  LOGGER_LEVEL=${LOGGER_LEVEL}"

# Platform API Keys (optional)
# GitHub
GITHUB_TOKEN="$(bashio::config 'github_access_token')"
if [[ -n "${GITHUB_TOKEN}" ]]; then
  export GITHUB_ACCESS_TOKEN="${GITHUB_TOKEN}"
  bashio::log.info "  GITHUB_ACCESS_TOKEN: configured"
fi

# Twitter/X
TWITTER_USER="$(bashio::config 'twitter_username')"
TWITTER_PASS="$(bashio::config 'twitter_password')"
TWITTER_AUTH="$(bashio::config 'twitter_auth_token')"
if [[ -n "${TWITTER_USER}" ]]; then
  export TWITTER_USERNAME="${TWITTER_USER}"
  bashio::log.info "  TWITTER_USERNAME: configured"
fi
if [[ -n "${TWITTER_PASS}" ]]; then
  export TWITTER_PASSWORD="${TWITTER_PASS}"
  bashio::log.info "  TWITTER_PASSWORD: configured"
fi
if [[ -n "${TWITTER_AUTH}" ]]; then
  export TWITTER_AUTH_TOKEN="${TWITTER_AUTH}"
  bashio::log.info "  TWITTER_AUTH_TOKEN: configured"
fi

# YouTube
YOUTUBE_API_KEY="$(bashio::config 'youtube_key')"
if [[ -n "${YOUTUBE_API_KEY}" ]]; then
  export YOUTUBE_KEY="${YOUTUBE_API_KEY}"
  bashio::log.info "  YOUTUBE_KEY: configured"
fi

# WeChat MP
WECHAT_COOKIE="$(bashio::config 'wechat_mp_cookie')"
if [[ -n "${WECHAT_COOKIE}" ]]; then
  export WECHAT_MP_COOKIE="${WECHAT_COOKIE}"
  bashio::log.info "  WECHAT_MP_COOKIE: configured"
fi

# Weibo
WEIBO_COOKIE="$(bashio::config 'weibo_cookies')"
if [[ -n "${WEIBO_COOKIE}" ]]; then
  export WEIBO_COOKIES="${WEIBO_COOKIE}"
  bashio::log.info "  WEIBO_COOKIES: configured"
fi

# Bilibili
BILIBILI_COOKIE="$(bashio::config 'bilibili_cookie')"
if [[ -n "${BILIBILI_COOKIE}" ]]; then
  export BILIBILI_COOKIE="${BILIBILI_COOKIE}"
  bashio::log.info "  BILIBILI_COOKIE: configured"
fi

# Zhihu
ZHIHU_COOKIE="$(bashio::config 'zhihu_cookie')"
if [[ -n "${ZHIHU_COOKIE}" ]]; then
  export ZHIHU_COOKIES="${ZHIHU_COOKIE}"
  bashio::log.info "  ZHIHU_COOKIES: configured"
fi

bashio::log.info "RSSHub environment initialization complete."
