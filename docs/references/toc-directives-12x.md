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

### 插件栏功能 (AddonCompartment) (11.0+)

```toc
## AddonCompartmentFunc: MyAddon_OnClick        # 点击按钮执行的函数
## AddonCompartmentFuncOnEnter: MyAddon_OnEnter # 鼠标进入时执行
## AddonCompartmentFuncOnLeave: MyAddon_OnLeave # 鼠标离开时执行
```

```lua
-- 点击插件栏按钮时调用
function MyAddon_OnClick(btn, buttonName, down)
    print("Button clicked:", buttonName)
    -- buttonName: "LeftButton", "RightButton" 等
end

function MyAddon_OnEnter(btn)
    GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
    GameTooltip:AddLine("My Addon")
    GameTooltip:Show()
end

function MyAddon_OnLeave(btn)
    GameTooltip:Hide()
end
```

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
## AllowLoadGameType: mainline
```

**可选值**:
- `mainline` - Retail (Mainline)
- `vanilla` - Classic Era
- `tbc` - TBC Classic
- `wrath` - Wrath Classic
- `cata` - Cataclysm Classic
- `mists` - Mists of Pandaria Classic (11.1.0+)
- `plunderstorm` - Plunderstorm

#### 文件级条件加载 (11.1.5+)

可在文件行后添加条件实现文件级别的条件加载:

```toc
# 只在 Retail 加载
MainlineCode.lua [AllowLoadGameType mainline]

# 只在 Classic 系列加载
ClassicCode.lua [AllowLoadGameType vanilla, tbc, wrath, cata]

# 根据语言加载
Localization\[TextLocale].lua
```

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

### 表访问权限 (11.1.7+)

```toc
## AllowAddOnTableAccess: 1
```

允许通过 `C_AddOns.GetLocalAddOnTable("MyAddon")` 获取插件的共享表，用于模块间数据共享。

### 存档变量优先加载 (11.1.5+)

```toc
## LoadSavedVariablesFirst: 1
```

在执行任何 Lua 文件前先加载 SavedVariables，适用于需要在初始化时立即访问配置的插件。

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
