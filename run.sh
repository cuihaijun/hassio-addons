#!/usr/bin/with-contenv bash
# RSSHub 启动脚本

# 从配置中读取端口
PORT=${PORT:-1200}

# 设置环境变量
export NODE_ENV=production
export PORT=$PORT

# 启动 RSSHub
echo "Starting RSSHub on port $PORT..."
cd /app
npm start
