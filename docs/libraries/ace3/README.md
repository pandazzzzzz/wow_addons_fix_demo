# Ace3 框架入门

> Ace3 是魔兽世界插件开发最流行的框架
> 权威来源: [Ace3 Wiki](https://www.wowace.com/projects/ace3)

## 概述

Ace3 是一套模块化框架，提供了常用功能的标准化实现：
- **AceAddon-3.0** - 插件生命周期管理
- **AceDB-3.0** - 数据持久化
- **AceConfig-3.0** - 配置系统
- **AceConsole-3.0** - 命令行工具
- **AceEvent-3.0** - 事件系统
- **AceHook-3.0** - 函数钩子

## 项目模板

使用项目中的 Ace3 模板：

```bash
cp -r templates/ace3-addon addons/MyAceAddon
```

## AceAddon-3.0

### 基本结构

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon(
    "MyAddon",           -- 插件名称
    "AceConsole-3.0",    -- 嵌入的库
    "AceEvent-3.0"
)

-- 初始化（加载数据库等）
function MyAddon:OnInitialize()
    self:Print("Initializing...")
end

-- 启用插件
function MyAddon:OnEnable()
    self:Print("Enabled!")
end

-- 禁用插件
function MyAddon:OnDisable()
    self:Print("Disabled")
end
```

### 生命周期

```
ADDON_LOADED
    ↓
OnInitialize()    ← 只调用一次
    ↓
PLAYER_LOGIN
    ↓
OnEnable()        ← 每次启用时调用
    ↓
(插件运行中)
    ↓
OnDisable()       ← 可选，禁用时调用
```

### Slash 命令

```lua
-- 注册命令
MyAddon:RegisterChatCommand("myaddon", "SlashCommand")
MyAddon:RegisterChatCommand("ma", "SlashCommand")

-- 处理命令
function MyAddon:SlashCommand(msg)
    local cmd, arg = msg:match("^(%S*)%s*(.-)$")

    if cmd == "show" then
        self:ShowMainFrame()
    elseif cmd == "config" then
        self:OpenConfig()
    else
        self:Print("Commands: show, config")
    end
end
```

## AceDB-3.0

### 创建数据库

```lua
function MyAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(
        "MyAddonDB",       -- 全局变量名
        {
            profile = {
                -- 默认配置
                enabled = true,
                scale = 1.0,
                position = { x = 0, y = 0 },
                filters = {
                    showCompleted = false,
                    minValue = 0,
                },
            },
            char = {
                -- 角色独立数据
                favorites = {},
            },
        }
    )
end
```

### 使用配置

```lua
-- 读取配置
local scale = self.db.profile.scale
local showCompleted = self.db.profile.filters.showCompleted

-- 修改配置
self.db.profile.scale = 1.2
self.db.profile.position.x = 100

-- 重置配置
self.db:ResetProfile()
```

### 配置回调

```lua
function MyAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MyAddonDB", defaults)

    -- 注册回调
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end

function MyAddon:RefreshConfig()
    -- 应用新配置
    self:UpdateFrameScale(self.db.profile.scale)
    self:UpdatePosition(self.db.profile.position)
end
```

### 配置文件管理

```lua
-- 获取配置列表
local profiles = MyAddon.db:GetProfiles()

-- 切换配置
MyAddon.db:SetProfile("Alternate")

-- 创建新配置并切换
MyAddon.db:SetProfile("NewProfile")

-- 复制配置
MyAddon.db:CopyProfile("Main", "Backup")

-- 删除配置
MyAddon.db:DeleteProfile("OldProfile")
```

## AceConfig-3.0

### 创建配置界面

```lua
local options = {
    name = "MyAddon",
    handler = MyAddon,
    type = "group",
    args = {
        general = {
            name = "General",
            type = "group",
            args = {
                enabled = {
                    name = "Enable",
                    desc = "Enable or disable the addon",
                    type = "toggle",
                    width = "full",
                    get = function(info)
                        return MyAddon.db.profile.enabled
                    end,
                    set = function(info, value)
                        MyAddon.db.profile.enabled = value
                    end,
                },
                scale = {
                    name = "Scale",
                    desc = "UI Scale",
                    type = "range",
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    get = function(info)
                        return MyAddon.db.profile.scale
                    end,
                    set = function(info, value)
                        MyAddon.db.profile.scale = value
                        MyAddon:UpdateScale()
                    end,
                },
                message = {
                    name = "Welcome Message",
                    type = "input",
                    width = "full",
                    get = function(info)
                        return MyAddon.db.profile.welcomeMessage
                    end,
                    set = function(info, value)
                        MyAddon.db.profile.welcomeMessage = value
                    end,
                },
            },
        },
    },
}

-- 注册配置
LibStub("AceConfig-3.0"):RegisterOptionsTable("MyAddon", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MyAddon", "MyAddon")

-- Slash 命令打开配置
function MyAddon:SlashCommand(msg)
    if msg == "config" then
        InterfaceOptionsFrame_OpenToCategory("MyAddon")
    end
end
```

### 常用控件

```lua
args = {
    -- 开关
    toggle = {
        name = "Toggle Option",
        type = "toggle",
        get = function() return db.toggle end,
        set = function(info, v) db.toggle = v end,
    },

    -- 滑块
    range = {
        name = "Range Option",
        type = "range",
        min = 0,
        max = 100,
        step = 5,
        get = function() return db.range end,
        set = function(info, v) db.range = v end,
    },

    -- 文本输入
    input = {
        name = "Text Input",
        type = "input",
        get = function() return db.text end,
        set = function(info, v) db.text = v end,
    },

    -- 下拉选择
    select = {
        name = "Select Option",
        type = "select",
        values = {
            ["option1"] = "Option 1",
            ["option2"] = "Option 2",
            ["option3"] = "Option 3",
        },
        get = function() return db.select end,
        set = function(info, v) db.select = v end,
    },

    -- 颜色选择器
    color = {
        name = "Color",
        type = "color",
        hasAlpha = true,
        get = function()
            return db.color.r, db.color.g, db.color.b, db.color.a
        end,
        set = function(info, r, g, b, a)
            db.color = { r = r, g = g, b = b, a = a }
        end,
    },

    -- 按钮
    button = {
        name = "Reset",
        type = "execute",
        func = function()
            MyAddon.db:ResetProfile()
        end,
    },

    -- 标题
    header = {
        name = "Section Header",
        type = "header",
    },

    -- 描述
        name = "This is a description text.",
        type = "description",
    },
}
```

## AceEvent-3.0

### 注册事件

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceEvent-3.0")

function MyAddon:OnEnable()
    -- 注册事件，自动映射到同名方法
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("QUEST_LOG_UPDATE")
end

-- 事件处理方法
function MyAddon:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    if isLogin then
        self:Print("Welcome back!")
    end
end

function MyAddon:QUEST_LOG_UPDATE(event)
    self:RefreshQuestList()
end
```

### 自定义消息

```lua
-- 发送消息
self:SendMessage("MyAddon_UpdateComplete", self, "quests")

-- 接收消息
self:RegisterMessage("MyAddon_UpdateComplete", "OnUpdateComplete")

function MyAddon:OnUpdateComplete(event, sender, dataType)
    self:Print("Update complete:", dataType)
end
```

## AceConsole-3.0

### 打印消息

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceConsole-3.0")

-- 带颜色的打印
MyAddon:Print("Hello")                              -- 默认颜色
MyAddon:Print("|cFF00FF00Success|r")                 -- 自定义颜色

-- 调试打印
MyAddon:Debug("Debug message")  -- 需要 MyAddon.debug = true
```

## 完整示例

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon(
    "MyAddon",
    "AceConsole-3.0",
    "AceEvent-3.0"
)

-- 默认配置
local defaults = {
    profile = {
        enabled = true,
        scale = 1.0,
        showTips = true,
    },
}

function MyAddon:OnInitialize()
    -- 初始化数据库
    self.db = LibStub("AceDB-3.0"):New("MyAddonDB", defaults)

    -- 注册配置
    self:SetupOptions()

    -- 注册命令
    self:RegisterChatCommand("myaddon", "SlashCommand")
    self:RegisterChatCommand("ma", "SlashCommand")

    self:Print("Loaded!")
end

function MyAddon:OnEnable()
    -- 注册事件
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("QUEST_LOG_UPDATE")

    -- 应用配置
    self:ApplySettings()
end

function MyAddon:PLAYER_ENTERING_WORLD(event, isLogin)
    if isLogin and self.db.profile.showTips then
        self:Print("Welcome! Type /ma for commands.")
    end
end

function MyAddon:QUEST_LOG_UPDATE(event)
    self:RefreshQuestList()
end

function MyAddon:SlashCommand(msg)
    msg = msg:lower()
    if msg == "config" then
        InterfaceOptionsFrame_OpenToCategory("MyAddon")
    elseif msg == "reset" then
        self.db:ResetProfile()
        self:ApplySettings()
        self:Print("Settings reset!")
    else
        self:Print("Commands: config, reset")
    end
end

function MyAddon:ApplySettings()
    -- 应用设置
end

function MyAddon:SetupOptions()
    local options = {
        name = "MyAddon",
        type = "group",
        args = {
            enabled = {
                name = "Enable",
                type = "toggle",
                order = 1,
                get = function() return self.db.profile.enabled end,
                set = function(info, v)
                    self.db.profile.enabled = v
                    self:ApplySettings()
                end,
            },
            scale = {
                name = "Scale",
                type = "range",
                order = 2,
                min = 0.5,
                max = 2.0,
                step = 0.1,
                get = function() return self.db.profile.scale end,
                set = function(info, v)
                    self.db.profile.scale = v
                    self:ApplySettings()
                end,
            },
        },
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable("MyAddon", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MyAddon")
end
```

## TOC 配置

```toc
## Interface: 120001
## Title: MyAceAddon
## SavedVariables: MyAddonDB

Libs\LibStub\LibStub.lua
Libs\CallbackHandler-1.0\CallbackHandler-1.0.lua
Libs\AceAddon-3.0\AceAddon-3.0.lua
Libs\AceEvent-3.0\AceEvent-3.0.lua
Libs\AceDB-3.0\AceDB-3.0.lua
Libs\AceConsole-3.0\AceConsole-3.0.lua
Libs\AceConfig-3.0\AceConfig-3.0.lua
Libs\AceConfig-3.0\AceConfigDialog-3.0\AceConfigDialog-3.0.lua
Libs\AceGUI-3.0\AceGUI-3.0.lua

MyAddon.lua
```

## 相关链接

- [Ace3 Wiki](https://www.wowace.com/projects/ace3)
- [SavedVariables 持久化](../../tutorials/saved-variables.md)
- [事件系统概述](../../api-reference/events/README.md)
