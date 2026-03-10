# 12.x TOC 指令完整参考

> 适用于 Interface 120001 (Midnight) 版本
> 权威来源: [Warcraft Wiki - TOC format](https://warcraft.wiki.gg/wiki/TOC_format)

## 基础指令

### 必需指令

| 指令 | 说明 | 示例 |
|------|------|------|
| `## Interface:` | 游戏版本号 | `## Interface: 120001` |
| `## Title:` | 插件显示名称 | `## Title: My Addon` |
| `## Version:` | 插件版本 | `## Version: 1.0.0` |

### 可选基础指令

| 指令 | 说明 | 示例 |
|------|------|------|
| `## Author:` | 作者名称 | `## Author: YourName` |
| `## Notes:` | 插件描述 | `## Notes: A helpful addon` |
| `## IconTexture:` | 插件图标 | `## IconTexture: Interface\Icons\Spell_Nature_StarFall` |
| `## SavedVariables:` | 持久化变量 | `## SavedVariables: MyAddonDB` |
| `## SavedVariablesPerCharacter:` | 角色独立变量 | `## SavedVariablesPerCharacter: MyAddonCharDB` |

## 12.x 新特性指令

### Category 与 Group

```toc
## Category: Inventory      # 插件分类（用于插件列表筛选）
## Group: MyAddonSuite      # 插件分组（批量开关）
```

**Category 可选值**:
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

### 条件加载指令

#### AllowLoadGameType

限制只在特定客户端类型加载:

```toc
## AllowLoadGameType: standard
```

**可选值**:
- `standard` - Retail (Mainline)
- `classic` - Classic Era
- `bcc` - Burning Crusade Classic
- `wotlk` - Wrath of the Lich King Classic
- `cata` - Cataclysm Classic

#### AllowLoadTextLocale

限制只在特定语言环境加载:

```toc
## AllowLoadTextLocale: zhCN
```

**常用值**:
- `enUS` - 英语
- `zhCN` - 简体中文
- `zhTW` - 繁体中文
- `deDE` - 德语
- `esES` - 西班牙语
- `frFR` - 法语
- `koKR` - 韩语
- `ptBR` - 葡萄牙语(巴西)
- `ruRU` - 俄语

### 表访问权限

```toc
## AllowAddOnTableAccess: 1
```

允许插件访问 `_.addonTable`（用于共享库）。

## TOC 变量展开

12.x 支持 TOC 文件内的变量展开：

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `[Family]` | 客户端家族 | Mainline, Classic |
| `[Game]` | 游戏版本 | Standard, Vanilla, TBC, Wrath, Cata, Mists |
| `[TextLocale]` | 文本语言 | enUS, zhCN |

**示例 - 根据语言加载不同文件**:

```toc
## Title: My Addon
## Interface: 120001
Loca\[TextLocale].lua
MyAddon.lua
```

## 文件加载顺序

TOC 文件按顺序加载，依赖关系需要正确排列：

```toc
# 库文件优先
Libs\LibStub\LibStub.lua
Libs\AceAddon-3.0\AceAddon-3.0.lua
Libs\AceDB-3.0\AceDB-3.0.lua

# 核心文件
MyAddon.lua
MyAddon\Core.lua
MyAddon\UI.lua

# 文件夹（递归加载）
MyModule\
```

### 通配符加载

```toc
# 加载 Loca 文件夹下所有 lua 文件
Loca\*.lua

# 加载所有 XML 文件
# 注意：XML 不会递归加载子文件夹
```

## 完整示例

参考项目文件: `addons/WorldQuestTab/WorldQuestTab.toc`

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
## Group: WorldQuestTools

## OptionalDeps: TomTom, Aurora

# Libraries
libs\LibStub\LibStub.lua
libs\AceAddon-3.0\AceAddon-3.0.lua
libs\AceDB-3.0\AceDB-3.0.lua

# Localization (语言文件)
Loca\enUS.lua
Loca\zhCN.lua

# Core Files
WorldQuestTab.lua
Data.lua
Dataprovider.lua
Settings.lua
```

## XML 文件指令

XML 文件支持额外指令：

```toc
## Title: My Addon
## Interface: 120001

# XML 指令通常在文件内部定义
MyFrame.xml
MyFrame.lua
```

XML 内部使用 `Script` 标签：
```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
    <Script file="MyFrame.lua"/>
    <Frame name="MyFrame" inherits="UIPanelDialogTemplate">
        <!-- Frame content -->
    </Frame>
</Ui>
```

## 相关链接

- [Warcraft Wiki - TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
- [wow-ui-source (GitHub)](https://github.com/Gethe/wow-ui-source)
- [wago.tools](https://wago.tools)
