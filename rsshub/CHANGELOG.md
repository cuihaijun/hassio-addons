# Changelog

## [1.0.0] - 2026-07-01

### Added
- 初始版本 RSSHub Home Assistant Add-on
- 支持 amd64 架构
- 本地构建镜像，绕过 Docker Hub 拉取限制
- 国内网络优化（清华镜像源 + npm 国内镜像）
- GitHub 克隆失败时自动使用 ghproxy.net 代理
- 多阶段 Docker 构建，减少最终镜像大小
- 健康检查配置
- 非 root 用户运行（安全性提升）
- 可配置端口（默认 1200）
- 无 Puppeteer 基础版

### Security
- 容器以非 root 用户 (nodejs:1001) 运行
- 桥接网络隔离

### Notes
- `auto_update` 设置为 false，需手动重新构建更新
- 首次构建耗时约 5-10 分钟（取决于 CPU 和网络）
