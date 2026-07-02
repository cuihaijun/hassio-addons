# Target

## Goal

修复 FreshRSS Home Assistant addon 的 nginx ingress 配置问题，使其能够正常启动并通过 ingress 访问。

## Scope

1. 修复 nginx 配置中重复的 `location /` 块导致的启动失败
2. 验证 FreshRSS 能够正常启动并运行
3. 验证 ingress 访问功能正常
4. 测试 bind_address: 0.0.0.0:7077 配置

## Non-Goals

- 不修改 FreshRSS 核心功能
- 不修改 Home Assistant 核心配置
- 不进行破坏性变更

## Success Criteria

- FreshRSS addon 能够正常启动（state: started）
- nginx 配置无语法错误
- ingress 端口 8099 可访问
- 直接访问端口 7077 可访问（如果配置了 bind_address）
