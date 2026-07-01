#!/usr/bin/with-contenv bash
set -e  # 遇到错误立即退出

# RSSHub 启动脚本

# 从配置中读取端口
PORT=${PORT:-1200}

# 设置环境变量
export NODE_ENV=production
export PORT=$PORT

# 验证工作目录
if [ ! -d "/app" ]; then
    echo "ERROR: /app directory not found!"
    exit 1
fi

# 启动 RSSHub
echo "Starting RSSHub on port $PORT..."
cd /app
exec npm start  # 使用 exec 替换当前进程，便于信号处理
