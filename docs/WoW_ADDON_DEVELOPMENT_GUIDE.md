# 魔兽世界插件开发完整指南

## 问题背景
用户希望了解魔兽世界正式服（Retail）当前版本的完整插件开发流程，包括所需工具、官方文档参考和测试方法。

---

## 一、开发环境搭建

### 1.1 必备工具

| 工具 | 用途 | 推荐选项 |
|------|------|----------|
| 文本编辑器 | 代码编写 | VS Code、Sublime Text、Notepad++ |
| Lua语言支持 | 语法高亮、智能提示 | VS Code Lua扩展 |
| XML编辑器 | XML模板编辑 | VS Code内置支持 |
| Git | 版本控制 | GitHub Desktop / Git CLI |
| 解压工具 | 查看游戏资源 | 7-Zip |

### 1.2 VS Code 推荐扩展

```
- sumneko.lua (Lua Language Server)
- WoW API (WoW开发API提示)
- XML Tools
- GitLens
```

### 1.3 开发目录结构

```
World of Warcraft/
├── _retail_/
│   ├── Interface/
│   │   └── AddOns/
│   │       └── YourAddon/        # 开发目录
│   │           ├── YourAddon.toc
│   │           ├── YourAddon.lua
│   │           └── YourAddon.xml
│   └── WTF/
│       └── Account/
│           └── 账号名/
│               └── SavedVariables/
│                   └── YourAddon.lua  # 配置数据
```

---

## 二、官方文档与参考资料

### 2.1 API文档来源

> **重要说明**: Blizzard 未发布官方API文档网站。游戏内置源码是最权威参考。

#### 官方资源

| 资源 | 说明 |
|------|------|
| 游戏内置源码 | `_retail_/Interface/FrameXML/` - 最权威 |
| 内置API文档 | `_retail_/Interface/FrameXML/APIDocumentation/` |
| Gethe/wow-ui-source | https://github.com/Gethe/wow-ui-source - GitHub镜像，每补丁更新 |
| wago.tools | https://wago.tools - DB2数据、地图、音效等资源查看 |

#### 社区资源

| 资源 | 网址 | 说明 |
|------|------|------|
| Warcraft Wiki | https://warcraft.wiki.gg | 社区维护，持续更新最新API |
| CurseForge | https://www.curseforge.com/wow/addons | 查看开源插件学习 |

### 2.2 游戏内置API文档

在游戏中使用以下命令查看API：
```lua
/dump GetBuildInfo()           -- 查看版本信息
/dump C_AddOns.GetAddOnInfo()  -- 查看插件信息
/script for k,v in pairs(_G) do if type(v)=="function" and k:find("^C_") then print(k) end end  -- 列出所有C_*函数
```

### 2.3 版本号对照（当前正式服）

```
Midnight (12.x):            Interface: 120001
The War Within (11.0.x):    Interface: 110000
Dragonflight (10.x):        Interface: 100000
```

可使用 `select(4, GetBuildInfo())` 获取当前客户端版本号。

---

## 三、插件文件结构

### 3.1 TOC文件（扩展符定义文件）

```toc
## Interface: 120001
## Title: MyAddon
## Title-zhCN: 我的插件
## Notes: A sample addon
## Notes-zhCN: 示例插件
## Author: YourName
## Version: 1.0.0
## SavedVariables: MyAddonDB
## OptionalDeps: Ace3, LibStub

# 库文件
Libs\LibStub\LibStub.lua
Libs\CallbackHandler-1.0\CallbackHandler-1.0.lua
Libs\AceAddon-3.0\AceAddon-3.0.lua

# 主文件
MyAddon.lua
MyAddon.xml
```

### 3.2 主Lua文件结构

```lua
-- 获取插件名和私有表
local addonName, addon = ...

-- 创建全局访问点
MyAddon = addon

-- 初始化
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            -- 插件加载完成
            print("MyAddon loaded!")
        end
    elseif event == "PLAYER_LOGIN" then
        -- 玩家登录完成
        addon:Initialize()
    end
end

-- 创建事件框架
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)

-- 或使用AceAddon框架
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceConsole-3.0")

function MyAddon:OnInitialize()
    -- 初始化数据库
    self.db = LibStub("AceDB-3.0"):New("MyAddonDB", defaults, true)
end

function MyAddon:OnEnable()
    -- 插件启用
    self:RegisterEvent("EVENT_NAME", "OnEventName")
end
```

### 3.3 XML模板

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.blizzard.com/wow/ui/">

    <Frame name="MyAddonTemplate" virtual="true">
        <Size x="200" y="100"/>
        <Layers>
            <Layer level="BACKGROUND">
                <Texture parentKey="Bg">
                    <Color r="0" g="0" b="0" a="0.5"/>
                </Texture>
            </Layer>
        </Layers>
        <Scripts>
            <OnLoad>self:OnLoad()</OnLoad>
            <OnShow>self:OnShow()</OnShow>
        </Scripts>
    </Frame>

</Ui>
```

---

## 四、核心开发概念

### 4.1 事件系统

```lua
-- 传统事件注册
local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterUnitEvent("UNIT_HEALTH", "player")  -- 只监听玩家
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "QUEST_LOG_UPDATE" then
        -- 处理任务更新
    end
end)

-- EventRegistry（现代方式）
EventRegistry:RegisterCallback("MyAddon.Event", callbackFunc, self)

-- 触发回调
EventRegistry:TriggerEvent("MyAddon.Event", arg1, arg2)
```

### 4.2 常用事件列表

| 事件 | 触发时机 |
|------|----------|
| ADDON_LOADED | 插件加载完成 |
| PLAYER_LOGIN | 玩家登录完成 |
| PLAYER_ENTERING_WORLD | 进入世界/切换区域 |
| QUEST_LOG_UPDATE | 任务日志更新 |
| BAG_UPDATE | 背包更新 |
| UNIT_HEALTH | 单位生命值变化 |

### 4.3 帧池（性能优化）

```lua
local framePool = CreateFramePool("BUTTON", parent, "MyButtonTemplate", function(pool, frame)
    -- 重置函数
    frame:ClearAllPoints()
    frame:Hide()
    frame.id = nil
end)

-- 获取帧
local frame = framePool:Acquire()
frame:SetPoint("CENTER")
frame:Show()

-- 释放帧
framePool:Release(frame)

-- 释放所有
framePool:ReleaseAll()
```

### 4.4 SavedVariables（数据持久化）

```lua
-- TOC中声明: ## SavedVariables: MyAddonDB

-- 默认值
local defaults = {
    profile = {
        enabled = true,
        showTooltip = true,
    }
}

-- 初始化
function MyAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MyAddonDB", defaults, true)

    -- 使用
    if self.db.profile.enabled then
        self:Enable()
    end

    -- 保存
    self.db.profile.someValue = 100
end
```

---

## 五、测试方法

### 5.1 游戏内调试命令

```lua
/reload              -- 重载UI（测试更改后必须）
/dump var            -- 打印变量值
/print function()    -- 打印函数返回值
/fstack              -- 显示framestack（查看UI层级）
/travel              -- 旅行调试
/console scriptErrors 1  -- 启用Lua错误显示
```

### 5.2 错误捕获

```lua
-- 使用pcall包装可能出错的代码
local success, err = pcall(function()
    -- 可能出错的代码
end)

if not success then
    print("Error:", err)
end

-- 全局错误处理
seterrorhandler(function(err)
    print("Lua Error:", err)
end)
```

### 5.3 性能分析

```lua
-- 简单计时
local startTime = debugprofilestop()
-- 你的代码
local endTime = debugprofilestop()
print("执行时间:", endTime - startTime, "ms")

-- 内存使用
local before = collectgarbage("count")
-- 你的代码
local after = collectgarbage("count")
print("内存变化:", after - before, "KB")
```

### 5.4 测试流程

1. **本地测试**
   - 修改代码 → 保存 → `/reload` → 测试功能
   - 重复以上步骤

2. **错误定位**
   - 启用 `/console scriptErrors 1`
   - 使用 `/dump` 检查变量状态
   - 添加 `print()` 调试语句

3. **多角色测试**
   - 测试SavedVariables是否正确保存
   - 测试不同职业/种族的兼容性

4. **版本兼容测试**
   - 使用条件判断处理API变化
   - 检查旧版本数据迁移

---

## 六、发布流程

### 6.1 发布平台

| 平台 | 网址 | 说明 |
|------|------|------|
| CurseForge | curseforge.com/wow/addons | 最大平台 |
| WowInterface | wowinterface.com | 老牌平台 |
| Wago | wago.io | 现代平台 |

### 6.2 打包要求

```
MyAddon/
├── MyAddon.toc
├── MyAddon.lua
├── Bindings.xml（可选，按键绑定）
├── Libs/（嵌入的库）
└── Localization/（本地化文件）
```

### 6.3 changelog

每次更新需提供changelog，说明：
- 新功能
- 修复的bug
- 兼容性变化

---

## 七、最佳实践

### 7.1 命名规范

```lua
-- 全局变量：驼峰，首字母大写
MyAddon = {}

-- 局部变量：驼峰，首字母小写
local questList = {}

-- 常量：全大写下划线
local MAX_QUESTS = 25

-- 私有表变量：下划线前缀
local _G = _G
local _M = {}

-- Mixin方法：使用Mixin后缀
MyFrameMixin = {}
```

### 7.2 性能优化

- 避免在OnUpdate中创建表
- 使用局部变量缓存全局访问
- 使用帧池避免频繁创建/销毁
- 事件去重处理频繁触发的事件
- 字符串连接使用 `table.concat()` 而非 `..`

### 7.3 安全性

- 不要信任任何来自其他插件的输入
- 敏感操作使用 `InCombatLockdown()` 检查
- 使用 `pcall()` 保护关键代码

---

## 八、参考资源汇总

### 官方资源

| 资源 | 说明 |
|------|------|
| 游戏内置FrameXML源码 | `_retail_/Interface/FrameXML/` - 最权威 |
| 内置API文档 | `_retail_/Interface/FrameXML/APIDocumentation/` |
| Gethe/wow-ui-source | https://github.com/Gethe/wow-ui-source - GitHub镜像，每补丁更新 |
| wago.tools | https://wago.tools - DB2数据、地图、音效等资源查看 |

### 社区资源

| 资源 | 说明 |
|------|------|
| Warcraft Wiki | https://warcraft.wiki.gg - 社区维护，持续更新最新API |
| CurseForge | https://www.curseforge.com/wow/addons - 查看开源插件学习 |
| MMO-Champion论坛 | 插件开发板块 |

### 调试工具插件
- BugSack - 错误收集
- BugGrabber - 错误捕获
- Addon profiler - 性能分析
- FlySpeedButton - 快速重载

---

## 总结

魔兽世界插件开发是一个完整的工作流程：

1. **环境搭建** → 安装编辑器、扩展、设置开发目录
2. **API查阅** → Warcraft Wiki + Gethe/wow-ui-source + 游戏内置源码
3. **编码开发** → TOC定义 + Lua逻辑 + XML界面
4. **测试调试** → /reload + /dump + 错误日志
5. **发布维护** → CurseForge/Wago + 版本更新

关键在于熟悉事件驱动模型、掌握常用API、遵循性能优化最佳实践。
