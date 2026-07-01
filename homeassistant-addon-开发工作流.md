# Home Assistant Add-on 开发与审核工作流

**版本:** v1.0.0
**最后更新:** 2026-07-01
**定位:** HA Add-on 开发全流程指南 — 从需求到发布

---

## 📋 工作流概览

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ 0. 镜像策略  │ → │  1. 需求分析  │ → │  2. 规范研究  │ → │  3. 开发实现  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                  ↓
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ 7. 维护更新  │ ← │  6. 发布上线  │ ← │  5. 修复迭代  │ ← │  4. 代码审核  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

---

## 🎯 阶段 1：需求分析

### 1.1 确认 Add-on 类型

| 类型 | 特征 | 推荐方案 |
|------|------|---------|
| **Web 应用** | 提供 HTTP 服务 | Ingress + nginx 反向代理 |
| **后台服务** | 无 UI，纯服务 | 直接暴露端口 |
| **硬件集成** | 需要访问硬件 | 配置 devices + privileged |

### 1.2 确认目标用户

| 用户群体 | 架构需求 | 网络优化 |
|---------|---------|---------|
| 国内用户 | amd64 + aarch64 | 国内镜像源 |
| 全球用户 | amd64 + aarch64 + armv7 | 标准镜像 |
| 树莓派用户 | aarch64 / armv7 | 轻量级构建 |

### 1.3 确认网络环境

| 场景 | 方案 |
|------|------|
| HA 可访问外网 | 使用官方镜像，GHCR 预构建 |
| HA 无法访问外网 | 本地构建 (`build: true`) |
| 国内网络受限 | 清华镜像 + npm 国内镜像 + ghproxy fallback |

---

## 🎯 阶段 0：镜像策略选择（最高优先级）

### 0.1 决策树：是否需要自定义构建？

```
开始
 │
 ├─→ 有官方 Docker Hub / GHCR 镜像？
 │    ├─ ✅ 是 → 直接使用官方镜像（config.yaml: image: diygod/rsshub）
 │    │         └─→ 跳过 Dockerfile 编写，仅保留 run.sh 配置读取
 │    └─ ❌ 否 → 进入下一步
 │
 ├─→ 应用是否简单（单进程、无复杂依赖）？
 │    ├─ ✅ 是 → 基于官方基础镜像 + 少量自定义
 │    └─ ❌ 否 → 需要完整自定义构建
 │
 └─→ HA 网络环境是否受限？
      ├─ ✅ 可访问外网 → 使用 GHCR / Docker Hub 预构建
      └─ ❌ 无法访问 → 本地构建 (build: true)
```

### 0.2 三种镜像策略对比

| 策略 | 适用场景 | 优点 | 缺点 |
|------|---------|------|------|
| **直接使用官方镜像** | 有成熟官方镜像（如 RSSHub、Node-RED） | ✅ 零维护<br>✅ 自动更新<br>✅ 无构建时间 | ❌ 无法深度定制<br>❌ 依赖官方维护 |
| **GHCR/Docker Hub 预构建** | 需要自定义但希望快速部署 | ✅ HA 秒级安装<br>✅ CI/CD 自动化 | ⚠️ 需配置 Secrets<br>⚠️ 首次构建耗时 |
| **本地构建 (build: true)** | HA 无法访问外网或高度定制 | ✅ 完全可控<br>✅ 无需外部依赖 | ❌ 每次安装需 5-10 分钟<br>❌ CPU 占用高 |

### 0.3 最佳实践原则

> **黄金规则：能直接用官方镜像，就绝不自己构建。**

| 检查项 | 说明 |
|--------|------|
| ✅ **优先检查官方镜像** | Docker Hub / GHCR 搜索应用名 |
| ✅ **验证镜像可用性** | `docker pull <image>` 测试拉取速度 |
| ✅ **评估定制需求** | 如果只需环境变量配置，无需自定义构建 |
| ❌ **避免重复造轮子** | 不要为已有官方镜像的应用重新构建 |

### 0.4 网络受限环境的应对策略

| 场景 | 症状 | 解决方案 |
|------|------|----------|
| **Docker Hub 超时** | `context deadline exceeded` | 改用本地构建 (`build: true`) |
| **GHCR 403 denied** | `Head ... denied` | 检查 Package 可见性或改 Docker Hub |
| **GitHub clone 失败** | `Connection timed out` | 使用 `ghproxy.net` 代理 |
| **npm install 慢** | 卡在 `fetchMetadata` | 配置 `registry.npmmirror.com` |

> **国内 HA 用户推荐：** 本地构建 + 清华镜像源 + ghproxy fallback

### 0.5 实战案例：RSSHub Add-on 演进历程

| 版本 | 策略 | 问题 | 结果 |
|------|------|------|------|
| v1.0 | 本地构建（从源码编译） | Dockerfile 复杂，构建耗时长 | ❌ 放弃 |
| v2.0 | GHCR 预构建 | HA 无法访问 GHCR (403 denied) | ❌ 放弃 |
| v3.0 | Docker Hub (`cuihaijun/rsshub`) | HA 无法访问 Docker Hub (timeout) | ❌ 放弃 |
| v4.0 | **直接使用 `diygod/rsshub:latest`** | 需配置 HA 代理或科学上网 | ✅ **成功** |

#### 关键教训

1. **版本号必须匹配官方标签**：
   - ❌ `version: 1.0.0` + `image: diygod/rsshub` → HA 尝试拉取 `diygod/rsshub:1.0.0`（不存在）
   - ✅ `version: "latest"` + `image: diygod/rsshub` → HA 拉取 `diygod/rsshub:latest`

2. **Ingress 配置**：
   - 必须在 `config.yaml` 中添加 `ingress: true`
   - 安装后需在 HA UI 中手动启用 **"Show in sidebar"**

3. **网络环境优先评估**：
   - 如果 HA 已配置科学上网 → 直接使用官方镜像
   - 如果 HA 无法访问外网 → 配置 Docker 代理或手动加载镜像

---

## 📚 阶段 1.5：规范研究

### 2.1 参考仓库

| 仓库 | 特点 | 适用场景 |
|------|------|---------|
| [alexbelgium/hassio-addons](https://github.com/alexbelgium/hassio-addons) | 多 Add-on 集合，规范完整 | 学习目录结构 |
| [andrewjswan/rsshub-addon](https://github.com/andrewjswan/rsshub-addon) | HA App System，GHCR CI/CD | 学习现代架构 |
| [home-assistant/addons](https://github.com/home-assistant/addons) | 官方 Add-on | 学习标准实现 |

### 2.2 HA App System vs 传统 Add-on

| 特性 | 传统 Add-on | HA App System |
|------|------------|---------------|
| 配置文件 | `config.json` / `config.yaml` | `config.yaml` |
| 基础镜像 | 自定义 | `ghcr.io/home-assistant/base` |
| 进程管理 | 自定义 | s6-overlay |
| Ingress | 可选 | 推荐 |
| 镜像分发 | 本地构建 | GHCR 预构建 |
| Label 标识 | `io.hass.type="addon"` | `io.hass.type="app"` |

### 2.3 必须了解的规范

```yaml
# config.yaml 关键字段
name: "Add-on 名称"
version: "1.0.0"                    # 语义化版本
slug: "addon-slug"                  # 唯一标识
arch: [amd64, aarch64]              # 支持的架构
image: "ghcr.io/{user}/{arch}-addon" # GHCR 镜像模板
startup: "services"                 # 启动类型
boot: "auto"                        # 自动启动
init: false                         # 使用 s6-overlay
ingress: true                       # HA UI 集成
watchdog: "tcp://[HOST]:[PORT]"     # 健康监控
```

---

## 🛠️ 阶段 2：开发实现

### 3.1 目录结构

```
addon-repo/                          # Git 仓库根目录
├── .github/
│   └── workflows/
│       └── build.yml                # CI/CD 工作流
├── repository.json                  # 仓库元数据
├── README.md                        # 仓库说明
├── LICENSE                          # 许可证
└── addon-name/                      # Add-on 目录
    ├── config.yaml                  # Add-on 配置
    ├── Dockerfile                   # 镜像构建
    ├── run.sh                       # 启动脚本
    ├── README.md                    # Add-on 文档
    ├── CHANGELOG.md                 # 版本记录
    ├── icon.png                     # 图标 (128x128)
    ├── logo.png                     # Logo (256x256)
    └── rootfs/                      # 文件系统覆盖
        └── etc/
            ├── cont-init.d/         # 容器初始化脚本
            ├── nginx/conf.d/        # nginx 配置
            └── services.d/          # s6 服务定义
```

### 3.2 Dockerfile 模板

#### 方案 0：直接使用官方镜像（最简单，推荐优先尝试）

> **适用条件：** Docker Hub/GHCR 上有成熟的官方镜像，且 HA 可以访问。

```dockerfile
# 直接使用官方镜像
FROM diygod/rsshub:latest

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION="RSSHub Add-on for Home Assistant"
ARG BUILD_NAME="RSSHub"
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# 添加 HA App System 标签
LABEL \
  io.hass.name="${BUILD_NAME}" \
  io.hass.description="${BUILD_DESCRIPTION}" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="app" \
  io.hass.version="${BUILD_VERSION}" \
  maintainer="your-name" \
  org.opencontainers.image.title="${BUILD_NAME}" \
  org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
  org.opencontainers.image.vendor="your-name" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.revision="${BUILD_REF}" \
  org.opencontainers.image.version="${BUILD_VERSION}" \
  org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}"

EXPOSE 1200

ENV NODE_ENV=production
ENV PORT=1200

CMD ["npm", "start"]
```

**config.yaml 关键配置：**
```yaml
image: diygod/rsshub        # 直接使用官方镜像
version: "latest"           # ⚠️ 必须与官方镜像标签一致
ingress: true               # 启用 Ingress 以显示侧边栏
```

#### 方案 A：GHCR 预构建（需要自定义构建时）

```dockerfile
ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ghcr.io/diygod/rsshub:latest AS org

FROM $BUILD_FROM

ARG TARGETPLATFORM
ARG BUILDPLATFORM

# 安装依赖
RUN apk add --no-cache nginx

# 构建参数
ARG BUILD_ARCH
ARG BUILD_VERSION

# Label（HA App System 标识）
LABEL \
  io.hass.name="RSSHub" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="app" \
  io.hass.version=${BUILD_VERSION}

EXPOSE 1200

# 覆盖文件系统
COPY rootfs /

# 复制应用
COPY --from=org /app /app

# 启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
```

#### 方案 B：本地构建（离线环境）

```dockerfile
FROM node:20-alpine AS builder

# 国内镜像优化
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

WORKDIR /app

# 克隆源码（带 fallback）
RUN git clone --depth 1 https://github.com/DIYgod/RSSHub.git . || \
    git clone --depth 1 https://ghproxy.net/https://github.com/DIYgod/RSSHub.git .

# npm 国内镜像
RUN npm config set registry https://registry.npmmirror.com

# 构建
RUN npm ci && npm run build && npm prune --omit=dev

# 生产阶段
FROM node:20-alpine

RUN apk add --no-cache wget

# 非 root 用户
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

WORKDIR /app
COPY --from=builder /app /app
RUN chown -R nodejs:nodejs /app
USER nodejs

ENV NODE_ENV=production
ENV PORT=1200
EXPOSE 1200

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:1200/ || exit 1

CMD ["npm", "start"]
```

### 3.3 run.sh 模板（使用 bashio）

```bash
#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: RSSHub
# ==============================================================================

# 启动信息
if bashio::supervisor.ping; then
    bashio::log.blue '-----------------------------------------------------------'
    bashio::log.blue " Add-on: $(bashio::addon.name)"
    bashio::log.blue " Version: $(bashio::addon.version)"
    bashio::log.blue '-----------------------------------------------------------'
fi

# 读取配置
cd /app

export NO_LOGFILES=true
export DISALLOW_ROBOT=false

# 可选配置
if bashio::config.has_value 'request_retry'; then
    export REQUEST_RETRY=$(bashio::config 'request_retry')
fi

if bashio::config.has_value 'cache_expire'; then
    export CACHE_EXPIRE=$(bashio::config 'cache_expire')
fi

# 自定义路由配置
ROUTE_FILE="/addon_configs/rsshub/routes_env.sh"
if [ -f "$ROUTE_FILE" ]; then
    bashio::log.info "Loading route config from $ROUTE_FILE"
    source "$ROUTE_FILE"
fi

bashio::log.info "Starting RSSHub..."

# 启动应用
npm run start

bashio::log.info "RSSHub stopped"
bashio::exit.ok
```

### 3.4 nginx Ingress 配置

**rootfs/etc/cont-init.d/80-nginx.sh**
```bash
#!/usr/bin/with-contenv bashio
# 配置 nginx ingress

INGRESS_ENTRY=$(bashio::addon.ingress_entry)
bashio::log.info "Configuring nginx for ingress: ${INGRESS_ENTRY}"

sed -i "s|INGRESS_ENTRY_PLACEHOLDER|${INGRESS_ENTRY}|g" /etc/nginx/conf.d/default.conf
```

**rootfs/etc/nginx/conf.d/default.conf**
```nginx
server {
    listen 8099;

    location INGRESS_ENTRY_PLACEHOLDER {
        rewrite ^INGRESS_ENTRY_PLACEHOLDER(.*)$ $1 break;
        proxy_pass http://127.0.0.1:1200;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**rootfs/etc/services.d/nginx/run**
```bash
#!/usr/bin/with-contenv bashio
exec nginx -g 'daemon off;'
```

### 3.5 GitHub Actions CI/CD

**.github/workflows/build.yml**
```yaml
name: Build and Push

on:
  push:
    branches: [main, master]
    tags: ['v*']
  pull_request:
    branches: [main, master]
  workflow_dispatch:

jobs:
  build:
    name: Build ${{ matrix.arch }}
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        arch: [amd64, aarch64]

    steps:
      - uses: actions/checkout@v4

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: *** secrets.GITHUB_TOKEN }}

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Get version
        id: version
        run: |
          VERSION=$(grep '^version:' rsshub/config.yaml | awk '{print $2}' | tr -d '"')
          echo "version=${VERSION}" >> $GITHUB_OUTPUT

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: ./rsshub
          platforms: linux/${{ matrix.arch }}
          push: true
          build-args: |
            BUILD_ARCH=${{ matrix.arch }}
            BUILD_VERSION=${{ steps.version.outputs.version }}
          tags: |
            ghcr.io/${{ github.repository_owner }}/${{ matrix.arch }}-rsshub-addon:${{ steps.version.outputs.version }}
            ghcr.io/${{ github.repository_owner }}/${{ matrix.arch }}-rsshub-addon:latest
```

---

## 🔍 阶段 3：代码审核

### 4.1 审核清单

#### config.yaml 检查

| 检查项 | 必须 | 说明 |
|--------|------|------|
| `name` | ✅ | Add-on 显示名称 |
| `version` | ✅ | **⚠️ 必须与镜像标签一致**（如官方镜像用 `"latest"`） |
| `slug` | ✅ | 唯一标识（小写+连字符） |
| `description` | ✅ | 简短描述 |
| `arch` | ✅ | 支持的架构列表 |
| `image` | ✅ | 镜像地址模板 |
| `startup` | ✅ | `services` / `application` / `once` |
| `boot` | ✅ | `auto` / `manual` |
| `ingress` | ⚠️ | **如需侧边栏显示，必须设为 `true`** |
| `panel_icon` | ⚠️ | 侧边栏图标（MDI 格式） |
| `panel_title` | ⚠️ | 侧边栏标题 |
| `ports` | ⚠️ | 如需外部访问 |
| `map` | ⚠️ | 文件系统映射 |
| `schema` | ⚠️ | 用户可配置项 |

#### Dockerfile 检查

| 检查项 | 必须 | 说明 |
|--------|------|------|
| 基础镜像 | ✅ | HA base 或官方镜像 |
| LABEL | ✅ | `io.hass.type="app"` 或 `"addon"` |
| 非 root 用户 | ⚠️ | 安全最佳实践 |
| HEALTHCHECK | ⚠️ | 容器健康监控 |
| 多架构支持 | ⚠️ | `TARGETPLATFORM` / `BUILDPLATFORM` |

#### run.sh 检查

| 检查项 | 必须 | 说明 |
|--------|------|------|
| Shebang | ✅ | `#!/usr/bin/with-contenv bashio` |
| 错误处理 | ✅ | `set -e` 或显式检查 |
| 配置读取 | ✅ | `bashio::config` |
| 日志输出 | ✅ | `bashio::log.info` |
| 优雅退出 | ⚠️ | `bashio::exit.ok` |

### 4.2 常见问题检查

| 问题 | 症状 | 解决方案 |
|------|------|----------|
| **版本号与镜像标签不匹配** | `manifest unknown: diygod/rsshub:1.0.0 not found` | `version` 必须与官方镜像标签一致（如 `"latest"`） |
| **Ingress 已启用但侧边栏不显示** | `ingress: true` 但 `ingress_panel: false` | 在 HA UI 中手动点击 **"Show in sidebar"** |
| `init: false` 与 `with-contenv` 冲突 | 容器启动失败 | 使用 HA base 镜像（含 s6-overlay） |
| `npm ci --omit=dev` + `npm run build` | 构建失败 | 先 `npm ci`，构建后 `npm prune` |
| HEALTHCHECK 依赖未安装 | 健康检查失败 | 在最终阶段安装 `wget` |
| Ingress 路径问题 | 404 错误 | 配置 nginx 路径重写 |
| 端口配置不生效 | 使用默认端口 | 使用 `bashio::config` 读取 |

---

## 🧪 阶段 4：测试验证

### 5.1 本地测试

```bash
# 1. 验证 YAML 语法
python3 -c "import yaml; yaml.safe_load(open('rsshub/config.yaml'))"

# 2. 验证 Dockerfile 语法
docker build --check ./rsshub

# 3. 本地构建测试
docker build -t rsshub-test ./rsshub

# 4. 运行测试
docker run -p 1200:1200 rsshub-test

# 5. 验证健康检查
curl http://localhost:1200/
```

### 5.2 HA 环境测试

1. **添加仓库**
   - Supervisor → Add-on Store → Repositories
   - 添加 `https://github.com/username/addon-repo`

2. **安装 Add-on**
   - 刷新仓库
   - 找到 Add-on 并安装

3. **启动测试**
   - 启动 Add-on
   - 查看日志确认无错误
   - 验证 Web UI 可访问

4. **Ingress 测试**
   - 启用 "Show in sidebar"
   - 点击侧边栏图标
   - 验证页面正常加载

5. **配置测试**
   - 修改配置项
   - 重启 Add-on
   - 验证配置生效

---

## 🔄 阶段 5：修复迭代

### 6.1 发布前检查

- [ ] 所有审核项通过
- [ ] 本地测试通过
- [ ] README 文档完整
- [ ] CHANGELOG 已更新
- [ ] 版本号已更新

### 6.2 发布流程

```bash
# 1. 更新版本号
sed -i 's/version: "1.0.0"/version: "1.0.1"/' rsshub/config.yaml

# 2. 更新 CHANGELOG
echo "## 1.0.1 - $(date +%Y-%m-%d)" >> rsshub/CHANGELOG.md
echo "- 修复 xxx 问题" >> rsshub/CHANGELOG.md

# 3. 提交并打标签
git add -A
git commit -m "release: v1.0.1"
git tag v1.0.1

# 4. 推送
git push origin main
git push origin v1.0.1
```

### 6.3 GitHub Actions 自动发布

推送 tag 后，GitHub Actions 会自动：
1. 构建 amd64 + aarch64 镜像
2. 推送到 GHCR
3. 创建 GitHub Release

---

## 🚀 阶段 6：发布上线

### 7.1 版本更新策略

| 类型 | 版本号变化 | 示例 |
|------|-----------|------|
| 修复 Bug | patch +1 | 1.0.0 → 1.0.1 |
| 新增功能 | minor +1 | 1.0.0 → 1.1.0 |
| 不兼容变更 | major +1 | 1.0.0 → 2.0.0 |

### 7.2 依赖更新

```bash
# 检查上游镜像更新
docker pull ghcr.io/diygod/rsshub:latest

# 更新 Dockerfile 中的版本
# 提交并推送
git commit -m "chore: update rsshub to latest"
```

### 7.3 定期维护

- [ ] 每月检查上游更新
- [ ] 每季度更新基础镜像
- [ ] 监控 GitHub Issues
- [ ] 响应安全漏洞告警

---

## 📎 附录

### A. 参考链接

| 资源 | 链接 |
|------|------|
| HA Add-on 文档 | https://developers.home-assistant.io/docs/add-ons |
| HA Add-on 配置 | https://developers.home-assistant.io/docs/add-ons/configuration |
| s6-overlay 文档 | https://github.com/just-containers/s6-overlay |
| bashio 文档 | https://github.com/hassio-addons/bashio |

### B. 常用命令

```bash
# 查看 Add-on 日志
ha addons logs <slug>

# 重启 Add-on
ha addons restart <slug>

# 进入 Add-on 容器
docker exec -it addon_<slug> bash

# 查看容器状态
docker inspect addon_<slug>
```

### C. 镜像源配置

```bash
# Alpine 清华镜像
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# npm 国内镜像
npm config set registry https://registry.npmmirror.com

# GitHub 代理
https://ghproxy.net/https://github.com/...
```

---

**版本:** v1.0.0
**维护者:** 开发助理
**最后更新:** 2026-07-01
