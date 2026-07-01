# Cuihaijun's Home Assistant Add-ons

自己常用的 HomeAssistant 插件集合，支持本地化启动运行。

## 可用 Add-ons

| Add-on | 描述 |
|--------|------|
| [RSSHub](rsshub-addon/) | 轻量级 RSS 聚合器，将任意网站转为 RSS 订阅源（国内优化版） |

## 安装方法

1. 在 Home Assistant Supervisor → Add-on Store → Repositories 中添加仓库地址：
   ```
   https://github.com/cuihaijun/hassio-addons
   ```
2. 刷新后找到对应的 Add-on 并安装
3. 点击 **"Build"** 进行本地构建（如需要）
4. 启动 Add-on

## 注意事项

- 所有 Add-on 均针对国内网络环境优化
- 使用清华镜像源和国内 npm 镜像加速构建
- `auto_update` 默认关闭，避免网络问题导致启动失败
