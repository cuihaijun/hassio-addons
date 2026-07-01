# RSSHub Addon 修复总结

**日期:** 2026-07-01  
**状态:** ✅ 所有高优先级问题已修复

---

## 📝 修复清单

### 1. 删除冗余启动脚本
```bash
✅ rm run.sh
```
**原因:** run.sh 与 S6-overlay 服务结构冲突，导致启动路径不一致。

---

### 2. 修正端口映射 (config.yaml)
```yaml
# 修复前
ports:
  1200/tcp: 5000

# 修复后
ports:
  1200/tcp: 1200
```
**原因:** RSSHub 默认监听 1200 端口，不是 5000。

---

### 3. 添加配置默认值 (config.yaml)
```yaml
options:
  request_retry: 3
  request_timeout: 3000
  cache_expire: 3600
  cache_content_expire: 3600
  logger_level: info
```
**原因:** schema 定义了选项但缺少默认值，用户首次安装时无初始配置。

---

### 4. 修复 S6-overlay 初始化脚本
**文件:** `rootfs/etc/s6-overlay/s6-rc.d/init-rsshub/up`

```bash
#!/usr/bin/with-contenv bashio
bashio::log.debug "RSSHub post-init complete"
exit 0
```
**原因:** 原文件内容无效（显示为 "(see attached image)"）。

---

### 5. 添加环境变量传递逻辑
**文件:** `rootfs/etc/s6-overlay/s6-rc.d/rsshub/run`

新增代码将 addon 配置转换为 RSSHub 环境变量：
- `request_retry` → `REQUEST_RETRY`
- `request_timeout` → `REQUEST_TIMEOUT`
- `cache_expire` → `CACHE_EXPIRE`
- `cache_content_expire` → `CACHE_CONTENT_EXPIRE`
- `logger_level` → `LOGGER_LEVEL`

**原因:** 用户在 Home Assistant UI 中修改的配置需要传递给 RSSHub 进程。

---

### 6. 优化健康检查 (Dockerfile)
```dockerfile
# 修复前
CMD curl -f http://localhost:1200/ || exit 1

# 修复后
CMD wget --no-verbose --tries=1 --spider http://localhost:1200/ || exit 1
```
**原因:** wget 更可能在基础镜像中可用，curl 可能需要额外安装。

---

## 🎯 符合的标准

| 标准 | 状态 |
|------|------|
| Portainer 结构模式 | ✅ 符合（S6-overlay + ingress） |
| bind_address | ✅ 0.0.0.0:1200（RSSHub 标准端口） |
| 侧边栏集成 | ✅ ingress: true |
| HTTPS 支持 | ✅ 通过 HA ingress 自动提供 |
| S6-overlay 结构 | ✅ init-rsshub (oneshot) → rsshub (longrun) |

**注意:** bind_address 要求中的 `0.0.0.0:9000` 是 Portainer 的特定端口，RSSHub 应保持其标准端口 1200。

---

## 📊 文件变更统计

| 文件 | 操作 | 说明 |
|------|------|------|
| `run.sh` | 🗑️ 删除 | 移除冗余启动脚本 |
| `config.yaml` | ✏️ 修改 | 修正端口 + 添加默认值 |
| `Dockerfile` | ✏️ 修改 | 优化 HEALTHCHECK |
| `init-rsshub/up` | ✏️ 修改 | 修复无效内容 |
| `rsshub/run` | ✏️ 修改 | 添加环境变量传递 |

---

## 🔍 验证步骤

部署前建议验证：

```bash
# 1. 检查 YAML 语法
python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"

# 2. 检查 Dockerfile 语法
docker build --no-cache -t rsshub-test .

# 3. 本地测试运行
docker run -p 1200:1200 rsshub-test

# 4. 验证健康检查
curl http://localhost:1200/
```

---

**完整审核报告:** 参见 `audit_report.md`
