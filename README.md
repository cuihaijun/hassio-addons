# Home Assistant Add-on: RSSHub

轻量级RSS聚合器，将任意网站转为RSS订阅源（国内优化版）

## 关于

[RSSHub](https://github.com/DIYgod/RSSHub) 是一个开源、易用且可扩展的 RSS 订阅源生成器。它可以从几乎任何内容生成 RSS 订阅源。

本 Add-on 针对国内网络环境进行了优化：
- 使用清华镜像源加速 Alpine 软件包安装
- 使用国内 npm 镜像加速依赖安装
- 本地构建镜像，绕过 Docker Hub 拉取限制
- 支持 GitHub 克隆失败时的代理 fallback

## 架构支持

- ✅ amd64

## 配置

| 选项 | 说明 | 默认值 |
|------|------|--------|
| port | RSSHub Web服务端口 | 1200 |

## 使用方法

1. 在 Home Assistant Supervisor → Add-on Store → Repositories 中添加仓库地址：`https://github.com/cuihaijun/hassio-addons`
2. 刷新后找到 RSSHub 并安装
3. 点击 **"Build"** 进行本地构建（耗时约 5-10 分钟，取决于 CPU 性能）
4. 启动 Add-on
5. 访问 `http://<HA_IP>:1200` 即可看到 RSSHub 首页

## 注意事项

- 首次构建可能需要较长时间（取决于网络速度）
- 如果 GitHub 访问慢，Dockerfile 会自动尝试通过 ghproxy.net 代理克隆
- 不使用 Puppeteer（基础版），如需浏览器渲染功能请参考 RSSHub 官方文档
- `auto_update` 已设置为 false，避免自动更新时因网络问题导致启动失败
- 如需更新，手动重新构建即可

## 技术细节

- 基础镜像：node:20-alpine
- Alpine 软件源：清华镜像 (mirrors.tuna.tsinghua.edu.cn)
- npm 镜像：https://registry.npmmirror.com
- 镜像标签：local/rsshub-{arch}
- 构建方式：本地 Dockerfile 构建

## 故障排查

### 构建失败
- 检查网络连接，确认可以访问 GitHub 和 npm 镜像
- 查看 Supervisor 日志：`docker logs hassio_supervisor`
- 如果 GitHub 克隆失败，Dockerfile 会自动尝试通过 ghproxy.net 代理

### 端口冲突
- 修改 Add-on 配置中的端口（默认 1200）
- 检查端口占用：`netstat -tlnp | grep 1200`

### 服务无法启动
- 查看 Add-on 日志
- 确认内存充足（建议 ≥512MB）
- 检查 Dockerfile 构建是否成功

## 如何更新

1. 停止 Add-on
2. 点击 **"Rebuild"** 重新构建（会拉取最新 RSSHub 源码）
3. 启动 Add-on

## 许可证

本项目遵循 RSSHub 原始许可证（MIT）。
