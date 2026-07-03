# Cuihaijun's Home Assistant Add-ons

自己常用的 HomeAssistant 插件集合，支持本地化启动运行。

## 可用 Add-ons

| Add-on | 描述 |
|--------|------|
| [RSSHub](rsshub/) | 轻量级 RSS 聚合器，将任意网站转为 RSS 订阅源（HA App System）<br>内置 Redis 缓存和 Chromium/Playwright 能力，默认接近官方 Docker Compose 完整体验 |
| [FreshRSS](freshrss/) | 自托管 RSS 阅读器，支持 Home Assistant 侧边栏 ingress 打开网页界面 |
| [FRP Client](frpc/) | frpc 内网穿透客户端（HA App System），连接到你自己的 frps 服务器，支持 TCP/HTTP 隧道 |

## 安装方法

1. 在 Home Assistant Supervisor → Add-on Store → Repositories 中添加仓库地址：
   ```
   https://github.com/cuihaijun/hassio-addons
   ```
2. 刷新后找到对应的 Add-on 并安装
3. 点击 **"Build"** 进行本地构建（如需要）
4. 启动 Add-on

## RSSHub 配置

RSSHub Add-on 默认内置 Redis 缓存和 Chromium/Playwright 能力，不需要额外部署 Redis 或 browserless 容器。

### 配置步骤

1. 打开 HA → Supervisor → Add-ons → RSSHub
2. 点击 **"Configuration"** 标签
3. 按需要调整缓存、访问密钥和高级覆盖项
5. 保存并重启 Add-on

### 常用配置

- `cache_type`: 默认 `redis`，使用内置 Redis；也可改为 `memory`
- `redis_url`: 默认留空，使用内置 Redis；需要外部 Redis 时才填写
- `playwright_ws_endpoint`: 默认留空，使用内置 Chromium；需要外部 browserless 时才填写
- `access_key`: 可选访问密钥；设置后 RSSHub URL 需要带 `?key=...`
- `disallow_robot`: 禁止搜索引擎爬取
- `request_retry` / `request_timeout`: 请求重试和超时

### 示例配置

```yaml
cache_type: redis
redis_url: ""
playwright_ws_endpoint: ""
access_key: ""
```

详细文档请查看: [RSSHub README](rsshub/README.md)

## FreshRSS 侧边栏访问

FreshRSS Add-on 支持通过 Home Assistant 侧边栏打开网页界面。

### 功能说明

- `ingress: true`：启用 Home Assistant 侧边栏入口
- `panel_title: FreshRSS`：侧边栏显示名称
- `panel_icon: mdi:rss-box`：侧边栏图标
- `ingress_port: 8099`：容器内部 ingress 监听端口，不占用宿主机端口
- `80/tcp: 7077`：直接访问 FreshRSS 网页界面的宿主机端口

### 配置建议

使用侧边栏访问时，`base_url` 可以保持为空：

```yaml
base_url: ""
ssl: false
```

如果通过固定外部域名或直连端口访问 FreshRSS，再按实际访问地址配置 `base_url`。

详细文档请查看: [FreshRSS DOCS](freshrss/DOCS.md)

## FRP Client 配置

FRP Client Add-on 用于连接自有 `frps` 服务器，将 Home Assistant 或其他本地服务通过隧道暴露出去。

### 常用配置

```yaml
frp_server: "example.com"
frp_server_port: 7000
frp_token: "change-me"
local_host: homeassistant
local_port: 8123
tunnel_type: tcp
proxy_name: homeassistant
tcp_remote_port: 6000
transport_protocol: tcp
tls_enable: true
```

### 兼容选项

如果服务端启用了心跳或新工作连接鉴权，开启匹配的客户端鉴权范围：

```yaml
auth_heartbeats: true
auth_new_work_conns: true
```

管理面板默认不启用；需要时设置：

```yaml
admin_enable: true
admin_port: 7400
```

详细文档请查看: [FRP Client README](frpc/README.md)

## 注意事项

- 所有 Add-on 均针对国内网络环境优化
- 使用清华镜像源和国内 npm 镜像加速构建
- `auto_update` 默认关闭，避免网络问题导致启动失败
