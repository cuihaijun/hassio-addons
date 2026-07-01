# Home Assistant Add-on 迁移到 HA App System 工作流

**版本:** v1.0.0
**最后更新:** 2026-07-01
**定位:** 将传统 Supervisor Add-on 迁移到现代 HA App System 的标准化流程

---

## 📋 工作流概览

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  1. 现状评估  │ → │  2. 架构设计  │ → │  3. 文件重构  │ → │  4. CI/CD配置│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                  ↓
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  6. 维护策略  │ ← │  5. 测试验证  │ ← │  4. 推送发布  │ ← │              │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

---

## 🎯 阶段 1：现状评估

### 1.1 识别当前 Add-on 类型

| 检查项 | 传统 Add-on 特征 | HA App System 特征 |
|--------|-----------------|-------------------|
| 配置文件 | `config.json` 或旧版 `config.yaml` | 新版 `config.yaml` |
| 基础镜像 | 自定义（如 `node:20-alpine`） | `ghcr.io/home-assistant/base` |
| Label 标识 | `io.hass.type="addon"` | `io.hass.type="app"` |
| 进程管理 | 直接启动应用 | s6-overlay + 服务定义 |
| Ingress | 可选或无 | 推荐启用 |
| 镜像分发 | 本地构建 (`build: true`) | GHCR 预构建 |

### 1.2 评估迁移必要性

| 场景 | 建议 |
|------|------|
| HA 版本 ≥ 2025.x | ✅ 强烈建议迁移 |
| 需要多架构支持 | ✅ 必须迁移 |
| 需要 Ingress 集成 | ✅ 必须迁移 |
| 国内离线环境 | ⚠️ 保留本地构建选项 |
| HA 版本 < 2024.x | ❌ 暂不迁移 |

### 1.3 收集参考实现

| 参考仓库 | 特点 | 适用场景 |
|---------|------|---------|
| [andrewjswan/rsshub-addon](https://github.com/andrewjswan/rsshub-addon) | 完整 HA App System 实现 | Web 应用类 Add-on |
| [home-assistant/addons](https://github.com/home-assistant/addons) | 官方标准实现 | 学习规范 |
| [alexbelgium/hassio-addons](https://github.com/alexbelgium/hassio-addons) | 多 Add-on 集合 | 目录结构参考 |

---

## 🏗️ 阶段 2：架构设计

### 2.1 核心架构对比

#### 传统 Add-on 架构
```
┌─────────────────────────────────┐
│     Home Assistant Supervisor   │
├─────────────────────────────────┤
│  config.json                    │
│  Dockerfile (本地构建)           │
│  run.sh (直接启动)               │
├─────────────────────────────────┤
│  自定义基础镜像                  │
│  应用进程                        │
└─────────────────────────────────┘
```

#### HA App System 架构
```
┌─────────────────────────────────┐
│     Home Assistant Supervisor   │
├─────────────────────────────────┤
│  config.yaml                    │
│  Dockerfile (GHCR 预构建)        │
│  run.sh (bashio + s6-overlay)    │
├─────────────────────────────────┤
│  ghcr.io/home-assistant/base    │
│  ├── s6-overlay                 │
│  ├── nginx (Ingress)            │
│  └── 应用进程                    │
└─────────────────────────────────┘
```

### 2.2 关键决策点

| 决策项 | 选项 | 推荐 |
|--------|------|------|
| 基础镜像 | 自定义 / HA base | HA base |
| 镜像分发 | 本地构建 / GHCR | GHCR |
| Ingress | 启用 / 禁用 | 启用 |
| 架构支持 | amd64 / amd64+aarch64 | 双架构 |
| 进程管理 | 直接启动 / s6-overlay | s6-overlay |

### 2.3 关键决策：是否需要自定义构建？

在开始迁移前，先评估是否可以**直接使用官方镜像**：

| 条件 | 建议 |
|------|------|
| ✅ Docker Hub/GHCR 有成熟官方镜像 | **直接使用官方镜像**，跳过 Dockerfile 编写 |
| ✅ 只需环境变量配置 | 使用 `run.sh` + `bashio::config` 读取配置 |
| ❌ 需要深度定制（如添加 nginx、修改源码） | 继续完整迁移流程 |

> **RSSHub 实战经验：** 从"本地构建 → GHCR 预构建 → Docker Hub"最终回归"直接使用 `diygod/rsshub:latest`"，大幅简化了维护成本。

### 2.4 目录结构设计

```
addon-repo/                          # Git 仓库根目录
├── .github/
│   └── workflows/
│       └── build.yml                # GitHub Actions CI/CD
├── repository.json                  # 仓库元数据
├── README.md                        # 仓库说明
├── LICENSE                          # MIT 许可证
└── addon-name/                      # Add-on 目录
    ├── config.yaml                  # HA App System 配置
    ├── Dockerfile                   # 多阶段构建
    ├── run.sh                       # bashio 启动脚本
    ├── README.md                    # Add-on 文档
    ├── CHANGELOG.md                 # 版本记录
    ├── icon.png                     # 图标 (128x128)
    ├── logo.png                     # Logo (256x256)
    └── rootfs/                      # 文件系统覆盖
        └── etc/
            ├── cont-init.d/         # 容器初始化脚本
            │   └── 80-nginx.sh      # nginx 配置初始化
            ├── nginx/
            │   └── conf.d/
            │       └── default.conf # Ingress 反向代理
            └── services.d/          # s6 服务定义
                └── nginx/
                    └── run          # nginx 服务启动脚本
```

---

## 🔧 阶段 3：文件重构

### 3.1 config.json → config.yaml

#### 迁移对照表

| config.json 字段 | config.yaml 字段 | 变化说明 |
|-----------------|-----------------|---------|
| `"name"` | `name:` | 格式变化 |
| `"version"` | `version:` | 格式变化 |
| `"slug"` | `slug:` | 格式变化 |
| `"description"` | `description:` | 格式变化 |
| `"arch": ["amd64"]` | `arch: [amd64, aarch64]` | **新增 aarch64** |
| `"image": "local/{arch}-addon"` | `image: "ghcr.io/{user}/{arch}-addon"` | **改为 GHCR** |
| `"build": true` | *(删除)* | **不再本地构建** |
| `"auto_update": false` | *(删除)* | GHCR 自动更新 |
| `"init": false` | `init: false` | 保持不变 |
| *(无)* | `ingress: true` | **新增 Ingress** |
| *(无)* | `watchdog: "tcp://[HOST]:[PORT]"` | **新增健康监控** |
| `"map": ["config:rw"]` | `map: [all_addon_configs:rw, ...]` | **扩展映射** |
| `"panel_icon"` | `panel_icon:` | 格式变化 |
| `"ports"` | `ports:` + `ports_description:` | 格式变化 |
| *(无)* | `schema:` | **新增用户配置项** |

#### 示例：RSSHub config.yaml

```yaml
---
name: RSSHub
version: 1.0.0
slug: rsshub
description: Generate a RSS/Atom/JSON feed from anything
url: https://github.com/cuihaijun/hassio-addons
arch:
  - amd64
  - aarch64
image: ghcr.io/cuihaijun/{arch}-rsshub-addon
startup: services
boot: auto
init: false
ingress: true
map:
  - all_addon_configs:rw
  - config:rw
  - share:rw
  - ssl:rw
homeassistant: 2024.1.0
panel_icon: mdi:newspaper-variant-multiple
panel_title: RSSHub
ports:
  1200/tcp: 5000
ports_description:
  1200/tcp: "Web Interface"
watchdog: "tcp://[HOST]:[PORT:1200]"
schema:
  request_retry: int?
  request_timeout: int?
  cache_expire: int?
  cache_content_expire: int?
  logger_level: list(emerg|alert|crit|error|warning|notice|info|debug)?
```

### 3.2 Dockerfile 策略选择

#### 方案 A：直接使用官方镜像（推荐优先尝试）

如果评估后认为无需自定义构建，Dockerfile 可以极度简化：

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

**对应 config.yaml：**
```yaml
image: diygod/rsshub        # 直接使用官方镜像
version: "latest"           # ⚠️ 必须与官方标签一致
ingress: true               # 启用 Ingress
```

#### 方案 B：完整自定义构建（需要深度定制时）

### 3.3 Dockerfile 重写

#### 迁移要点

| 项目 | 传统方式 | HA App System |
|------|---------|--------------|
| 基础镜像 | `FROM node:20-alpine` | `ARG BUILD_FROM=ghcr.io/home-assistant/base:latest` |
| 应用来源 | 从源码构建 | `FROM ghcr.io/diygod/rsshub:latest AS org` |
| Label | 简单标识 | 完整 HA App System Label |
| 进程管理 | `CMD ["npm", "start"]` | `CMD ["/run.sh"]` + s6-overlay |
| Ingress | 无 | nginx 反向代理 |
| 多架构 | 单架构 | `ARG TARGETPLATFORM` / `BUILDPLATFORM` |

#### 示例：RSSHub Dockerfile

```dockerfile
ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ghcr.io/diygod/rsshub:latest AS org

FROM $BUILD_FROM

ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN echo "Docker builder running on $BUILDPLATFORM, building for $TARGETPLATFORM"

# Packages
RUN \
  apk add --no-cache --virtual .build-dependencies \
    npm git nginx

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Add Label (HA App System 标识)
LABEL \
  io.hass.name="${BUILD_NAME}" \
  io.hass.description="${BUILD_DESCRIPTION}" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="app" \
  io.hass.version=${BUILD_VERSION} \
  maintainer="cuihaijun" \
  org.opencontainers.image.title="${BUILD_NAME}" \
  org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
  org.opencontainers.image.vendor="cuihaijun" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.created=${BUILD_DATE} \
  org.opencontainers.image.revision=${BUILD_REF} \
  org.opencontainers.image.version=${BUILD_VERSION} \
  org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}"

EXPOSE 1200

# Ingress - 覆盖文件系统
WORKDIR /
COPY rootfs /

# Copy data for app
COPY --from=org /app /app

COPY run.sh /

# Make scripts executable
RUN chmod a+x $(find "./" -type f -iname "*.sh")
RUN chmod a+x $(find "./etc/services.d" -type f -iname "*")

# Start RSSHub
CMD [ "/run.sh" ]
```

### 3.3 run.sh 重写

#### 迁移要点

| 项目 | 传统方式 | HA App System |
|------|---------|--------------|
| Shebang | `#!/bin/bash` | `#!/usr/bin/with-contenv bashio` |
| 配置读取 | 环境变量 `$PORT` | `bashio::config 'port'` |
| 日志输出 | `echo` | `bashio::log.info` |
| 错误处理 | 手动检查 | `bashio::exit.ok` |
| 启动信息 | 无 | Supervisor 信息展示 |

#### 示例：RSSHub run.sh

```bash
#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant App: RSSHub
# ==============================================================================

if bashio::supervisor.ping; then
    bashio::log.blue \
        '-----------------------------------------------------------'
    bashio::log.blue " App: $(bashio::addon.name)"
    bashio::log.blue " $(bashio::addon.description)"
    bashio::log.blue \
        '-----------------------------------------------------------'
    bashio::log.blue " App version: $(bashio::addon.version)"
    bashio::log.blue " System: $(bashio::info.operating_system)" \
        " ($(bashio::info.arch) / $(bashio::info.machine))"
    bashio::log.blue \
        '-----------------------------------------------------------'
fi

# ==============================================================================
cd /app

bashio::log.info 'RSSHub Starting...'
bashio::log.info 'Configuration:'

export NO_LOGFILES=true
export DISALLOW_ROBOT=false
export TITLE_LENGTH_LIMIT=255

if bashio::config.has_value 'request_retry'; then
    export REQUEST_RETRY=$(bashio::config 'request_retry')
    bashio::log.blue " Request retry: $(bashio::config 'request_retry')"
fi

if bashio::config.has_value 'request_timeout'; then
    export REQUEST_TIMEOUT=$(bashio::config 'request_timeout')
    bashio::log.blue " Request timeout: $(bashio::config 'request_timeout')"
fi

if bashio::config.has_value 'cache_expire'; then
    export CACHE_EXPIRE=$(bashio::config 'cache_expire')
    bashio::log.blue " Cache expire: $(bashio::config 'cache_expire')"
fi

if bashio::config.has_value 'cache_content_expire'; then
    export CACHE_CONTENT_EXPIRE=$(bashio::config 'cache_content_expire')
    bashio::log.blue " Cache content expire: $(bashio::config 'cache_content_expire')"
fi

if bashio::config.has_value 'logger_level'; then
    export LOGGER_LEVEL=$(bashio::config 'logger_level')
    bashio::log.blue " Logger level: $(bashio::config 'logger_level')"
fi

ROUTE_FILE="/addon_configs/rsshub/routes_env.sh"
if [ -f $ROUTE_FILE ]; then
    bashio::log.blue " Adding route specific configurations:"
    bashio::log.blue " ${ROUTE_FILE}"
    source $ROUTE_FILE
fi

bashio::log.blue "RSSHub port mapping (local:external): $(bashio::addon.network), use external port for access."
bashio::log.info 'RSSHub Start'

# ==============================================================================
npm run start

# ==============================================================================
bashio::log.info 'RSSHub Stop'
bashio::exit.ok
```

### 3.4 创建 rootfs 目录

#### 3.4.1 nginx 初始化脚本

**rootfs/etc/cont-init.d/80-nginx.sh**
```bash
#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configure nginx for ingress
# ==============================================================================

INGRESS_ENTRY=$(bashio::addon.ingress_entry)
bashio::log.info "Configuring nginx for ingress entry: ${INGRESS_ENTRY}"

# Update nginx config with ingress entry
sed -i "s|INGRESS_ENTRY_PLACEHOLDER|${INGRESS_ENTRY}|g" /etc/nginx/conf.d/default.conf
```

#### 3.4.2 nginx 配置文件

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
        proxy_redirect off;
    }
}
```

#### 3.4.3 s6 nginx 服务

**rootfs/etc/services.d/nginx/run**
```bash
#!/usr/bin/with-contenv bashio
# ==============================================================================
# Start nginx service
# ==============================================================================
exec nginx -g 'daemon off;'
```

---

## 🚀 阶段 4：CI/CD 配置

### 4.1 GitHub Actions 工作流

**.github/workflows/build.yml**
```yaml
name: Build and Push

on:
  push:
    branches:
      - main
      - master
    tags:
      - 'v*'
  pull_request:
    branches:
      - main
      - master
  workflow_dispatch:

jobs:
  build:
    name: Build ${{ matrix.arch }}
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        arch:
          - amd64
          - aarch64

    steps:
      - name: Checkout
        uses: actions/checkout@v4

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
          file: ./rsshub/Dockerfile
          platforms: linux/${{ matrix.arch }}
          push: true
          build-args: |
            BUILD_ARCH=${{ matrix.arch }}
            BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
            BUILD_DESCRIPTION=RSSHub Add-on for Home Assistant
            BUILD_NAME=RSSHub
            BUILD_REF=${{ github.sha }}
            BUILD_REPOSITORY=${{ github.repository }}
            BUILD_VERSION=${{ steps.version.outputs.version }}
          tags: |
            ghcr.io/${{ github.repository_owner }}/${{ matrix.arch }}-rsshub-addon:${{ steps.version.outputs.version }}
            ghcr.io/${{ github.repository_owner }}/${{ matrix.arch }}-rsshub-addon:latest

  release:
    name: Create Release
    runs-on: ubuntu-latest
    needs: build
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: *** secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: RSSHub ${{ github.ref }}
          draft: false
          prerelease: false
```

### 4.2 GHCR 镜像命名规范

| 组件 | 格式 | 示例 |
|------|------|------|
| 仓库 | `ghcr.io/{username}/{arch}-{addon}` | `ghcr.io/cuihaijun/amd64-rsshub-addon` |
| 标签 | `{version}` + `latest` | `1.0.0`, `latest` |
| 多架构 | 分别构建后合并 manifest | 使用 Docker Buildx |

---

## 🧪 阶段 5：测试验证

### 5.1 本地验证

```bash
# 1. 验证 YAML 语法
python3 -c "import yaml; yaml.safe_load(open('rsshub/config.yaml'))"

# 2. 验证 Dockerfile 语法
docker build --check ./rsshub

# 3. 本地构建测试（可选）
docker build -t rsshub-test --build-arg BUILD_ARCH=amd64 --build-arg BUILD_VERSION=1.0.0 ./rsshub

# 4. 运行测试
docker run -p 1200:1200 rsshub-test

# 5. 验证健康检查
curl http://localhost:1200/
```

### 5.2 HA 环境测试

1. **等待 GitHub Actions 构建完成**
   - 检查 Actions 页面确认构建成功
   - 确认 GHCR 镜像已推送

2. **添加仓库**
   - Supervisor → Add-on Store → Repositories
   - 添加 `https://github.com/username/addon-repo`

3. **安装 Add-on**
   - 刷新仓库
   - 找到 Add-on 并安装（将拉取 GHCR 镜像）

4. **启动测试**
   - 启动 Add-on
   - 查看日志确认无错误
   - 验证 Web UI 可访问

5. **Ingress 测试**
   - 启用 "Show in sidebar"
   - 点击侧边栏图标
   - 验证页面正常加载

6. **配置测试**
   - 修改 schema 中的配置项
   - 重启 Add-on
   - 验证配置生效

### 5.3 常见问题排查

| 问题 | 症状 | 解决方案 |
|------|------|---------|
| GHCR 拉取失败 | 安装时报错 | 检查网络，或使用本地构建 fallback |
| Ingress 404 | 访问 HA UI 报 404 | 检查 nginx 配置和 `ingress_entry` |
| 配置不生效 | 修改配置后无变化 | 检查 `bashio::config` 读取逻辑 |
| 多架构构建失败 | Actions 报错 | 检查 QEMU 和 Buildx 配置 |

---

## 🔄 阶段 6：维护策略

### 6.1 版本更新流程

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

# 4. 推送（触发 GitHub Actions）
git push origin main
git push origin v1.0.1
```

### 6.2 上游依赖更新

```bash
# 检查上游镜像更新
docker pull ghcr.io/diygod/rsshub:latest

# 更新 Dockerfile 中的版本引用
# 提交并推送
git commit -m "chore: update rsshub upstream image"
```

### 6.3 定期维护任务

| 任务 | 频率 | 说明 |
|------|------|------|
| 检查上游更新 | 每月 | 关注 RSSHub 官方发布 |
| 更新基础镜像 | 每季度 | `ghcr.io/home-assistant/base:latest` |
| 监控 GHCR 配额 | 每月 | 确保存储配额充足 |
| 响应安全漏洞 | 即时 | 关注 CVE 告警 |
| 清理旧镜像 | 每季度 | 删除过时的 GHCR 标签 |

---

## 📎 附录

### A. 迁移检查清单

#### 迁移前

- [ ] 确认 HA 版本 ≥ 2024.1.0
- [ ] 备份现有 Add-on 文件
- [ ] 研究参考实现（andrewjswan/rsshub-addon）
- [ ] 确认目标架构（amd64 + aarch64）

#### 迁移中

- [ ] config.json → config.yaml
- [ ] 添加 `arch: [amd64, aarch64]`
- [ ] 修改 `image:` 为 GHCR 模板
- [ ] 删除 `build: true` 和 `auto_update`
- [ ] 添加 `ingress: true`
- [ ] 添加 `watchdog`
- [ ] 重写 Dockerfile（HA base + 官方镜像）
- [ ] 重写 run.sh（bashio）
- [ ] 创建 rootfs/ 目录结构
- [ ] 创建 GitHub Actions 工作流

#### 迁移后

- [ ] 验证 YAML 语法
- [ ] 验证 Dockerfile 语法
- [ ] 本地构建测试
- [ ] HA 环境测试
- [ ] Ingress 功能测试
- [ ] 推送到 GitHub
- [ ] 确认 GitHub Actions 构建成功
- [ ] 确认 GHCR 镜像已推送

### B. 关键命令速查

```bash
# 验证 YAML
python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"

# 验证 Dockerfile
docker build --check .

# 查看 GHCR 镜像
skopeo inspect docker://ghcr.io/username/arch-addon:latest

# 查看 Add-on 日志
ha addons logs <slug>

# 进入容器
docker exec -it addon_<slug> bash
```

### C. 参考链接

| 资源 | 链接 |
|------|------|
| HA Add-on 文档 | https://developers.home-assistant.io/docs/add-ons |
| HA App System | https://developers.home-assistant.io/docs/add-ons/configuration |
| s6-overlay | https://github.com/just-containers/s6-overlay |
| bashio | https://github.com/hassio-addons/bashio |
| andrewjswan/rsshub-addon | https://github.com/andrewjswan/rsshub-addon |

---

**版本:** v1.0.0
**维护者:** 开发助理
**最后更新:** 2026-07-01
**基于案例:** RSSHub Add-on 迁移实践
