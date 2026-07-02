# Acceptance Criteria

## AC-1: Nginx 配置修复

**Must Pass**

- [ ] ingress.gtpl 中移除重复的 `location /` 块
- [ ] nginx 配置语法检查通过
- [ ] FreshRSS addon 能够正常启动

**Evidence Required:**
- nginx -t 命令成功
- ha apps info 显示 state: started

## AC-2: Ingress 访问功能

**Must Pass**

- [ ] ingress 端口 8099 可访问
- [ ] 返回 HTTP 200 状态码
- [ ] 能够访问 FreshRSS 界面

**Evidence Required:**
- curl 命令返回 200
- 浏览器访问成功

## AC-3: 直接访问功能（可选）

**Should Pass**

- [ ] 配置 bind_address: 0.0.0.0:7077 后端口 7077 可访问
- [ ] 返回 HTTP 200 状态码

**Evidence Required:**
- curl 命令返回 200
