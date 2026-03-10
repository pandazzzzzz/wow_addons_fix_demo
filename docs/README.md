# 魔兽世界 Retail 12.x 插件开发文档

> 适用于 Interface 120001 (Midnight) 版本

## 文档导航

### 入门指南

| 文档 | 说明 |
|------|------|
| [开发环境搭建](getting-started/01-environment-setup.md) | VS Code配置、开发流程 |
| [第一个插件](getting-started/02-first-addon.md) | 从模板创建第一个插件 |
| [TOC文件详解](getting-started/03-toc-format.md) | TOC格式与12.x新特性 |
| [调试技巧](getting-started/04-debugging.md) | 常用调试方法 |

### 设计模式

| 文档 | 说明 |
|------|------|
| [Mixin模式](tutorials/patterns/mixin-pattern.md) | 面向对象封装 |
| [帧池模式](tutorials/patterns/frame-pool.md) | 内存复用与性能优化 |
| [EventRegistry系统](tutorials/patterns/event-registry.md) | 现代事件系统 |

### API参考

| 文档 | 说明 |
|------|------|
| [事件系统概述](api-reference/events/README.md) | 事件注册与处理 |
| [C_QuestLog](api-reference/namespaces/C_QuestLog.md) | 任务日志API |
| [C_Map](api-reference/namespaces/C_Map.md) | 地图API |
| [C_Timer](api-reference/namespaces/C_Timer.md) | 定时器API |

### 第三方库

| 文档 | 说明 |
|------|------|
| [Ace3框架入门](libraries/ace3/README.md) | AceAddon-3.0、AceDB-3.0 |

### 参考资源

| 文档 | 说明 |
|------|------|
| [12.x TOC指令完整列表](references/toc-directives-12x.md) | 所有TOC指令参考 |
| [权威文档来源](references/authoritative-sources.md) | 官方与社区资源 |

## 版本说明

- **Interface版本**: 120001 (Midnight)
- **客户端类型**: Retail (Mainline)

## 关键注意事项

1. **战斗锁定** - 部分操作无法在战斗中进行
2. **内存优化** - 避免在OnUpdate中创建表
3. **版本检测** - `select(4, GetBuildInfo())`
