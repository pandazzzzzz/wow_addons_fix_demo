# CLAUDE.md

## 项目说明

魔兽世界正式服（Retail）插件开发项目。

## API文档来源

### 官方资源

- 游戏内置源码: `_retail_/Interface/FrameXML/`
- Gethe/wow-ui-source: https://github.com/Gethe/wow-ui-source
- wago.tools: https://wago.tools

### 社区资源

- Warcraft Wiki: https://warcraft.wiki.gg
- CurseForge: https://www.curseforge.com/wow/addons

## 开发规范

### TOC版本号

```
## Interface: 120001  # Midnight (12.x)
```

### 核心模式

**帧池** - 内存复用
**Mixin** - 面向对象封装
**EventRegistry** - 现代事件系统（优于传统frame:RegisterEvent）

### 常用API命名空间

`C_QuestLog` `C_Map` `C_Timer` `C_SuperTrack` `C_CVar`

### 关键注意事项

1. 战斗锁定 - 部分操作无法在战斗中进行
2. 内存优化 - 避免在OnUpdate中创建表
3. 版本检测 - `select(4, GetBuildInfo())`

### 第三方库

LibStub, AceAddon-3.0, AceDB-3.0
