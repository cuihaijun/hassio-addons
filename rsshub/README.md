# Home Assistant Add-on: RSSHub

轻量级RSS聚合器，将任意网站转为RSS订阅源（HA App System）

## 关于

[RSSHub](https://github.com/DIYgod/RSSHub) 是一个开源、易用且可扩展的 RSS 订阅源生成器。它可以从几乎任何内容生成 RSS 订阅源。

本 Add-on 基于 HA App System 架构实现：
- 使用 bashio 工具集与 Home Assistant Supervisor 集成
- 支持 Ingress 方式访问
- 多架构支持（amd64, aarch64）
- 通过 GitHub Container Registry (GHCR) 自动构建和分发

## 架构支持

- ✅ amd64
- ✅ aarch64

## 配置

| 选项 | 说明 | 默认值 |
|------|------|--------|
| request_retry | 请求重试次数 | - |
| request_timeout | 请求超时时间（秒） | - |
| cache_expire | 缓存过期时间（秒） | - |
| cache_content_expire | 内容缓存过期时间（秒） | - |
| logger_level | 日志级别 | - |

## 使用方法

1. 在 Home Assistant Supervisor → Add-on Store → Repositories 中添加仓库地址：`https://github.com/cuihaijun/hassio-addons`
2. 刷新后找到 RSSHub 并安装
3. 启动 Add-on
4. 通过 Home Assistant 侧边栏访问 RSSHub，或通过配置的端口访问

## 注意事项

- 支持 Ingress 方式直接嵌入 Home Assistant UI
- 可通过 `/addon_configs/rsshub/routes_env.sh` 配置路由特定环境变量
- `auto_update` 已设置为 false，避免自动更新时因网络问题导致启动失败
- 如需更新，手动重新构建即可

## 技术细节

- 基础镜像：ghcr.io/home-assistant/base:latest
- RSSHub 镜像：ghcr.io/diygod/rsshub:latest
- Web 服务器：nginx（用于 Ingress 代理）
- 端口映射：内部 1200 → 外部 5000
- 构建方式：GitHub Actions 自动构建并推送到 GHCR

## 如何更新

1. 停止 Add-on
2. 点击 **"Rebuild"** 重新构建（会拉取最新 RSSHub 源码）
3. 启动 Add-on

## 许可证

本项目遵循 MIT 许可证。
