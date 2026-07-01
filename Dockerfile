# 多阶段构建：第一阶段构建 RSSHub
FROM node:20-alpine AS builder

# 更换 Alpine 软件源为清华镜像
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# 安装 git
RUN apk add --no-cache git

WORKDIR /app

# 从 GitHub 克隆 RSSHub 源码（优先直连，失败则使用代理）
RUN git clone --depth 1 https://github.com/DIYgod/RSSHub.git . || \
    (echo "Direct clone failed, trying with proxy..." && \
     git clone --depth 1 https://ghproxy.net/https://github.com/DIYgod/RSSHub.git .)

# 配置 npm 使用国内镜像
RUN npm config set registry https://registry.npmmirror.com

# 安装依赖并构建（不包含 Puppeteer）
# 优先使用 npm ci，失败则回退到 npm install
RUN (npm ci --omit=dev || npm install --omit=dev) && \
    npm run build

# 第二阶段：生产运行环境
FROM node:20-alpine

# 更换 Alpine 软件源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# 创建非 root 用户
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# 从 builder 阶段复制构建好的文件
COPY --from=builder /app /app

# 设置目录权限
RUN chown -R nodejs:nodejs /app

# 切换到非 root 用户
USER nodejs

# 设置环境变量
ENV NODE_ENV=production
ENV PORT=1200

# 暴露端口
EXPOSE 1200

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:1200/ || exit 1

# 启动命令
CMD ["npm", "start"]
