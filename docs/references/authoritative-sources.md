# 权威文档来源

> 魔兽世界插件开发的官方与社区资源

## 官方资源

### 游戏内置源码

最权威的 API 参考来源于游戏内置的 FrameXML 代码：

```
# Windows
World of Warcraft\_retail_\Interface\FrameXML\

# macOS
World of Warcraft/_retail_/Interface/FrameXML/
```

### GitHub 镜像

- **Gethe/wow-ui-source**: https://github.com/Gethe/wow-ui-source
  - 官方 FrameXML 源码镜像
  - 每个版本都有完整历史记录

### wago.tools

- **wago.tools**: https://wago.tools
  - 在线浏览 WoW 数据和代码
  - 支持各版本 FrameXML 查询
  - API 和事件的详细文档

## 社区资源

### Warcraft Wiki

- **Warcraft Wiki**: https://warcraft.wiki.gg
  - 最全面的 API 文档
  - 详细的事件列表
  - XML 元素参考
  - 开发教程

**常用页面**:
- [World of WarCraft API](https://warcraft.wiki.gg/wiki/World_of_Warcraft_API)
- [Events](https://warcraft.wiki.gg/wiki/Events)
- [TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
- [XML](https://warcraft.wiki.gg/wiki/XML)
- [Getting started](https://warcraft.wiki.gg/wiki/Getting_started_with_addon_programming)

### CurseForge

- **CurseForge**: https://www.curseforge.com/wow/addons
  - 插件发布平台
  - 开源插件源码参考
  - Ace3 等框架发布处

### GitHub 资源

- **wow-ui-source**: https://github.com/Gethe/wow-ui-source
- **Ace3**: https://github.com/WoWUIDev/Ace3
- **WoW API 类型定义**:
  - https://github.com/Ketho/vscode-wow-api
  - https://github.com/PrincessLuna/wow-api-defs

## 开发工具

### VS Code 扩展

- **Lua** (sumneko.lua)
  - Lua 语言服务器
  - 代码补全、语法检查

- **WoW Bundle** (Septh.wow-bundle)
  - 魔兽世界 API 补全
  - 事件、API 自动提示

### 游戏 API 参考

| 命名空间 | 说明 | Wiki 链接 |
|----------|------|-----------|
| C_QuestLog | 任务日志 | [Link](https://warcraft.wiki.gg/wiki/Category:API_functions/Quests) |
| C_Map | 地图 | [Link](https://warcraft.wiki.gg/wiki/Category:API_functions/Map) |
| C_Timer | 定时器 | [Link](https://warcraft.wiki.gg/wiki/Category:API_functions/Timers) |
| C_CurrencyInfo | 货币 | [Link](https://warcraft.wiki.gg/wiki/Category:API_functions/Currency) |
| C_Item | 物品 | [Link](https://warcraft.wiki.gg/wiki/Category:API_functions/Items) |
| C_Spell | 法术 | [Link](https://warcraft.wiki.gg/wiki/Category:API/functions/Spells) |
| C_CVar | 控制台变量 | [Link](https://warcraft.wiki.gg/wiki/Category:API_functions/CVar) |
| C_SuperTrack | 超级追踪 | [Link](https://warcraft.wiki.gg/wiki/Category:API_functions/Tracking) |

## 版本信息

### Interface 版本号

| 版本 | 版本号范围 |
|------|--------|
| Midnight (12.x) | 120001+ |
| The War Within (11.x) | 110000 - 110xxx |
| Dragonflight (10.x) | 100000 - 100xxx |
| Shadowlands (9.x) | 90000 - 90xxx |

### 版本检测

```lua
local interfaceVersion = select(4, GetBuildInfo())
local gameVersion = C_Window.GetWindowTitle()  -- "Midnight"
```

## 社区论坛

- **MMO-Champion**: https://www.mmo-champion.com/forums/259-Interface-amp-Macros
- **Reddit r/wowaddons**: https://www.reddit.com/r/wowaddons/
- **Discord**: WoW AddOn Development 社区

## 第三方框架

### Ace3

- **GitHub**: https://github.com/WoWUIDev/Ace3
- **Wiki**: https://www.wowace.com/projects/ace3
- **文档**: [Ace3 框架入门](../libraries/ace3/README.md)

### LibStub

- **GitHub**: https://github.com/WoWUIDev/LibStub
- 说明：轻量级库管理框架

### CallbackHandler

- **GitHub**: https://github.com/WoWUIDev/CallbackHandler-1.0
- 说明：事件回调处理框架

## 项目本地资源

### 参考实现

- `addons/WorldQuestTab/` - 完整插件实现参考
- `templates/basic-addon/` - 基础插件模板
- `templates/ace3-addon/` - Ace3 框架模板

### 项目文档

- [TOC 指令完整列表](toc-directives-12x.md)
- [API 命名空间文档](../api-reference/namespaces/)

## 持续更新

魔兽世界 API 随版本更新而变化，建议：

1. 定期查阅 wago.tools 的最新版本
2. 关注 Gethe/wow-ui-source 的更新
3. 订阅 Warcraft Wiki 的变更
4. 参考项目中的最新 TOC 版本号
