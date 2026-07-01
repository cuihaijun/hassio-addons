# RSSHub Home Assistant Add-on
# https://github.com/cuihaijun/hassio-addons

LABEL io.hass.version="1.0.0" \
      io.hass.type="addon" \
      io.hass.arch="amd64"

# 多阶段构建：第一阶段构建 RSSHub
FROM node:20-alpine AS builder

# 更换 Alpine 软件源为清华镜像
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# 安装 git
RUN apk add --no-cache git

WORKDIR /app

# 从 GitHub 克隆 RSSHub 源码（优先直连，失败则使用代理）
# ghproxy.net 代理格式：https://ghproxy.net/https://github.com/user/repo.git
RUN git clone --depth 1 https://github.com/DIYgod/RSSHub.git . 2>/dev/null || \
    (echo "Direct clone failed, trying with ghproxy.net..." && \
     git clone --depth 1 https://ghproxy.net/https://github.com/DIYgod/RSSHub.git .)

# 配置 npm 使用国内镜像
RUN npm config set registry https://registry.npmmirror.com

# 安装所有依赖（包括 devDependencies，因为 build 需要 TypeScript 等）
# 优先使用 npm ci，失败则回退到 npm install
RUN (npm ci || npm install) && \
    npm run build && \
    npm prune --omit=dev  # 构建完成后移除 devDependencies，减小镜像体积

# 第二阶段：生产运行环境
FROM node:20-alpine

# 更换 Alpine 软件源并安装 wget（用于健康检查）
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk add --no-cache wget

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
