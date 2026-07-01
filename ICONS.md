# 图标文件说明

本 Add-on 需要以下图标文件：

- `icon.png` - 128x128 PNG 格式，用于 Add-on 列表显示
- `logo.png` - 512x512 PNG 格式，用于 Add-on 详情页

## 获取方式

1. 从 RSSHub 官方仓库获取：https://github.com/DIYgod/RSSHub/tree/master/assets
2. 或使用在线工具生成 RSS 图标
3. 或暂时使用空白占位符（不影响功能）

## 临时方案

如果暂时没有图标，可以创建两个空白 PNG 文件：

```bash
# 创建 128x128 空白 icon.png
convert -size 128x128 xc:white icon.png

# 创建 512x512 空白 logo.png
convert -size 512x512 xc:white logo.png
```

或者从现有 Add-on（如 frpc）复制图标文件作为占位符。
