#!/usr/bin/with-contenv bash
set -e  # 遇到错误立即退出

# RSSHub 启动脚本

# 从配置中读取端口（优先从 s6-overlay 注入的环境变量，其次从 options.json）
if [ -n "$PORT" ]; then
    PORT=$PORT
elif [ -f /data/options.json ]; then
    PORT=$(cat /data/options.json | grep -o '"port":[0-9]*' | cut -d: -f2)
    PORT=${PORT:-1200}
else
    PORT=1200
fi

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
