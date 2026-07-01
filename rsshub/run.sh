#!/usr/bin/with-contenv bashio

# Set RSSHub configuration
export PORT=1200
export HOSTNAME=0.0.0.0

# Start RSSHub
exec node /app/lib/index.js
