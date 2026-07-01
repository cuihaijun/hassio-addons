# Cuihaijun's Home Assistant Add-ons

自己常用的 HomeAssistant 插件集合，支持本地化启动运行。

## 可用 Add-ons

| Add-on | 描述 |
|--------|------|
| [RSSHub](rsshub/) | 轻量级 RSS 聚合器，将任意网站转为 RSS 订阅源（HA App System）<br>**新增**: 支持通过 UI 配置环境变量，启用更多平台集成（GitHub、Twitter、YouTube、微信、微博、Bilibili 等） |
| [FRP Client](frpc/) | frpc 内网穿透客户端（HA App System），连接到你自己的 frps 服务器，支持 TCP/HTTP 隧道 |

## 安装方法

1. 在 Home Assistant Supervisor → Add-on Store → Repositories 中添加仓库地址：
   ```
   https://github.com/cuihaijun/hassio-addons
   ```
2. 刷新后找到对应的 Add-on 并安装
3. 点击 **"Build"** 进行本地构建（如需要）
4. 启动 Add-on

## RSSHub 环境变量配置

RSSHub Add-on 支持通过 Home Assistant UI 配置环境变量，以启用更多平台集成。

### 配置步骤

1. 打开 HA → Supervisor → Add-ons → RSSHub
2. 点击 **"Configuration"** 标签
3. 找到 **"Environment Variables"** 部分
4. 填写需要的 API 密钥或配置项
5. 保存并重启 Add-on

### 支持的环境变量

#### 缓存与性能
- `NODE_ENV`: Node 环境模式（默认: production）
- `CACHE_TYPE`: 缓存类型（memory/redis，默认: memory）
- `CACHE_EXPIRE`: 缓存过期时间（秒，默认: 3600）
- `CACHE_CONTENT_EXPIRE`: 内容缓存过期时间（秒，默认: 3600）
- `DISALLOW_ROBOT`: 禁止搜索引擎爬取（默认: false）
- `ENABLE_CACHE_MANAGER`: 启用缓存管理器（默认: true）
- `REQUEST_RETRY`: 请求重试次数（默认: 3）
- `REQUEST_TIMEOUT`: 请求超时时间（毫秒，默认: 30000）

#### 平台 API 密钥
- `GITHUB_ACCESS_TOKEN`: GitHub Personal Access Token
- `TWITTER_USERNAME`: Twitter/X 用户名
- `TWITTER_PASSWORD`: Twitter/X 密码
- `TWITTER_AUTH_TOKEN`: Twitter/X Auth Token
- `YOUTUBE_KEY`: YouTube Data API v3 Key
- `WECHAT_MP_COOKIE`: 微信公众号 Cookie
- `WEIBO_COOKIES`: 微博登录 Cookie
- `BILIBILI_COOKIE_你的UID`: Bilibili 用户 Cookie（替换"你的UID"为实际 UID）

### 示例配置

```yaml
environment_variables:
  # 缓存设置
  CACHE_TYPE: memory
  CACHE_EXPIRE: 7200
  
  # GitHub 集成
  GITHUB_ACCESS_TOKEN: "ghp_xxxxxxxxxxxx"
  
  # Twitter/X 集成
  TWITTER_USERNAME: "your_username"
  TWITTER_PASSWORD: "***"
  TWITTER_AUTH_TOKEN: "***"
  
  # YouTube 集成
  YOUTUBE_KEY: "AIzaSyxxxxxxxxxxxx"
```

详细文档请查看: [RSSHub README](rsshub/README.md)

## 注意事项

- 所有 Add-on 均针对国内网络环境优化
- 使用清华镜像源和国内 npm 镜像加速构建
- `auto_update` 默认关闭，避免网络问题导致启动失败
