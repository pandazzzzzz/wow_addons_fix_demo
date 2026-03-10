# TOC 文件详解

> TOC 文件是魔兽世界插件的配置清单
> 权威来源: [Warcraft Wiki - TOC format](https://warcraft.wiki.gg/wiki/TOC_format)

## 概述

TOC (Table of Contents) 文件是每个插件的入口配置，定义了插件的基本信息、依赖关系和加载顺序。

## 文件位置

```
Interface/
└── AddOns/
    └── MyAddon/
        ├── MyAddon.toc    # 必须与文件夹同名
        ├── MyAddon.lua
        └── modules/
```

## 基础结构

### 最小示例

```toc
## Interface: 120001
## Title: My Addon
## Version: 1.0.0

MyAddon.lua
```

### 完整示例

```toc
## Interface: 120001
## Title: My Addon
## Title-zhCN: 我的插件
## Notes: A helpful addon
## Notes-zhCN: 一个有用的插件
## Author: YourName
## Version: 1.0.0
## IconTexture: Interface\Icons\Spell_Nature_StarFall
## Category: Miscellaneous
## SavedVariables: MyAddonDB
## SavedVariablesPerCharacter: MyAddonCharDB
## OptionalDeps: SomeOtherAddon
## X-Website: https://example.com

# Libraries
Libs\LibStub\LibStub.lua

# Core
MyAddon.lua
Core\Init.lua

# Modules
Modules\*.lua
```

## 核心指令

### Interface（必需）

定义兼容的游戏版本号：

```toc
## Interface: 120001    # Midnight (12.x)
```

**常用版本号**:
| 版本 | 版本号 |
|------|--------|
| Midnight (12.x) | 120001 |
| The War Within (11.x) | 110107 |
| Dragonflight (10.x) | 100207 |

### Title（必需）

插件在插件列表中显示的名称：

```toc
## Title: My Addon
## Title-zhCN: 我的插件    # 本地化标题
```

### Version

插件版本号：

```toc
## Version: 1.0.0
## Version: @project-version@    # CurseForge 自动替换
```

### Notes

插件描述：

```toc
## Notes: A helpful addon
## Notes-zhCN: 一个有用的插件    # 本地化描述
```

## 12.x 新特性

### Category

插件分类，用于插件列表筛选：

```toc
## Category: Inventory
```

**可选值**:
- `Audio & Video`
- `Bags & Inventory`
- `Buffs & Debuffs`
- `Chat & Communication`
- `Class`
- `Combat`
- `Data Broker`
- `Development Tools`
- `Guild`
- `Mail`
- `Map & Minimap`
- `Miscellaneous`
- `Quests & Leveling`
- `Roleplay`
- `Tooltip`
- `Unit Frames`

### Group

插件分组，可批量开关：

```toc
## Group: MyAddonSuite
```

### AllowLoadGameType

限制只在特定客户端类型加载：

```toc
## AllowLoadGameType: standard
```

**可选值**:
- `standard` - Retail (Mainline)
- `classic` - Classic Era
- `bcc` - TBC Classic
- `wotlk` - Wrath Classic
- `cata` - Cataclysm Classic

### AllowLoadTextLocale

限制只在特定语言环境加载：

```toc
## AllowLoadTextLocale: zhCN
```

## 数据持久化

### SavedVariables

账户共享的持久化数据：

```toc
## SavedVariables: MyAddonDB
```

```lua
-- 使用示例
MyAddonDB = MyAddonDB or {}

function MyAddon:OnLoad()
    self.db = MyAddonDB
    self.db.settings = self.db.settings or {}
end
```

### SavedVariablesPerCharacter

角色独立的持久化数据：

```toc
## SavedVariablesPerCharacter: MyAddonCharDB
```

## 依赖管理

### Dependencies

必需依赖：

```toc
## Dependencies: SomeLibrary
```

### OptionalDeps

可选依赖：

```toc
## OptionalDeps: TomTom, Aurora
```

### LoadOnDemand

延迟加载：

```toc
## LoadOnDemand: 1
```

## 变量展开

12.x 支持 TOC 内的变量展开：

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `[Family]` | 客户端家族 | Mainline |
| `[Game]` | 游戏版本 | Standard |
| `[TextLocale]` | 文本语言 | zhCN |

### 根据语言加载文件

```toc
Loca\[TextLocale].lua
```

### 根据客户端类型

```toc
## AllowLoadGameType: standard
Core\Retail.lua

## AllowLoadGameType: classic
Core\Classic.lua
```

## 文件加载

### 加载顺序

TOC 文件按顺序加载：

```toc
# 1. 库文件
Libs\LibStub\LibStub.lua
Libs\AceAddon-3.0\AceAddon-3.0.lua

# 2. 核心文件
MyAddon.lua
Core.lua

# 3. 模块
Modules\*.lua    # 通配符按字母顺序加载
```

### 通配符

```toc
# 加载所有 lua 文件
*.lua

# 加载子目录中所有 lua 文件
Modules\*.lua
```

**注意**: XML 文件不支持递归加载子目录。

### XML 与 Lua 混合

```toc
# 先加载 XML 定义
UI\Templates.xml

# 再加载 Lua 逻辑
UI\UI.lua
```

## 项目示例

参考 `addons/WorldQuestTab/WorldQuestTab.toc`:

```toc
## Interface: 120001
## Title: WorldQuestTab
## Title-zhCN: 世界任务标签
## Notes: Adds a World Quest tab to the world map
## Author: AuthorName
## Version: @project-version@
## IconTexture: Interface\Icons\Achievement_Quests_Completed_TwilightHighlands
## SavedVariables: WorldQuestTabDB
## SavedVariablesPerCharacter: WorldQuestTabCharDB
## Category: Map & Minimap
## OptionalDeps: TomTom

Libs\LibStub\LibStub.lua
Libs\AceAddon-3.0\AceAddon-3.0.lua

Loca\enUS.lua
Loca\zhCN.lua

WorldQuestTab.lua
Data.lua
Dataprovider.lua
Settings.lua
```

## 最佳实践

### 1. 版本号规范

使用语义化版本号：
```toc
## Version: 1.0.0
```

或使用 CurseForge 自动替换：
```toc
## Version: @project-version@
```

### 2. 本地化标题

为主流语言提供本地化：
```toc
## Title: My Addon
## Title-zhCN: 我的插件
## Title-zhTW: 我的插件
## Title-deDE: Mein Addon
```

### 3. 依赖版本

为依赖指定版本：
```toc
## OptionalDeps: LibStub(1.0)
```

### 4. 模块化加载

使用 `LoadOnDemand` 优化启动性能：
```toc
# 主插件
MyAddon.toc

# 模块（按需加载）
Modules\BigModule.toc
```

## 相关链接

- [TOC 指令完整列表](../references/toc-directives-12x.md)
- [Warcraft Wiki - TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
- [Warcraft Wiki - SavedVariables](https://warcraft.wiki.gg/wiki/Saving_variables)
