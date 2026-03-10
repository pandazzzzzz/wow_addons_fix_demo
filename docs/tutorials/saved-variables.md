# SavedVariables 数据持久化

> 插件数据的保存与加载
> 权威来源: [Warcraft Wiki - Saving variables](https://warcraft.wiki.gg/wiki/Saving_variables)

## 概述

SavedVariables 是魔兽世界插件的持久化机制，允许插件在游戏会话之间保存和恢复数据。

## 基本用法

### TOC 声明

在 TOC 文件中声明要保存的变量：

```toc
## SavedVariables: MyAddonDB
## SavedVariablesPerCharacter: MyAddonCharDB
```

### 账户级 SavedVariables

所有角色共享的数据：

```toc
## SavedVariables: MyAddonDB
```

```lua
-- 使用前必须初始化
MyAddonDB = MyAddonDB or {
    settings = {},
    favorites = {},
}

function MyAddon:OnLoad()
    self.db = MyAddonDB
    -- 使用数据
    self.db.settings.showTips = true
end
```

### 角色级 SavedVariables

每个角色独立的数据：

```toc
## SavedVariablesPerCharacter: MyAddonCharDB
```

```lua
MyAddonCharDB = MyAddonCharDB or {
    position = { x = 0, y = 0 },
    enabled = true,
}
```

## 数据结构设计

### 分层结构

```lua
local DEFAULTS = {
    global = {
        -- 所有角色共享
        version = "1.0.0",
        lastUpdate = 0,
    },
    profile = {
        -- 当前角色设置
        enabled = true,
        scale = 1.0,
        position = { x = 0, y = 0 },
        filters = {
            showCompleted = false,
            minLevel = 0,
        },
    },
}

function MyAddon:InitDB()
    MyAddonDB = MyAddonDB or {}
    self.db = MyAddonDB

    -- 合并默认值
    for key, value in pairs(DEFAULTS.global) do
        if self.db[key] == nil then
            self.db[key] = value
        end
    end

    -- 初始化 profile
    self.db.profile = self.db.profile or {}
    for key, value in pairs(DEFAULTS.profile) do
        if self.db.profile[key] == nil then
            self.db.profile[key] = value
        end
    end
end
```

### 避免嵌套过深

```lua
-- 不推荐：深层嵌套
self.db.characters[player].quests[zone].completed[id] = true

-- 推荐：扁平键
local key = player .. "_" .. zone .. "_" .. id
self.db.completedQuests[key] = true
```

## AceDB-3.0 框架

推荐使用 AceDB-3.0 简化数据库管理：

### 基本用法

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon")

function MyAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MyAddonDB", {
        profile = {
            enabled = true,
            scale = 1.0,
            position = { x = 0, y = 0 },
            filters = {
                showCompleted = false,
            },
        },
    })

    -- 注册回调
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end

function MyAddon:RefreshConfig()
    -- 重新加载配置
    self:UpdatePosition(self.db.profile.position)
end
```

### 配置文件管理

```lua
-- 获取配置列表
local profiles = MyAddon.db:GetProfiles()

-- 创建新配置
MyAddon.db:SetProfile("Alternate")

-- 复制配置
MyAddon.db:CopyProfile("Main", "Alternate")

-- 删除配置
MyAddon.db:DeleteProfile("OldProfile")

-- 重置当前配置
MyAddon.db:ResetProfile()
```

### 默认值

```lua
-- 使用 defaults 表自动合并
local defaults = {
    profile = {
        items = {
            ["*"] = {  -- 通配符默认值
                enabled = true,
                count = 0,
            },
        },
    },
}

self.db = LibStub("AceDB-3.0"):New("MyAddonDB", defaults)

-- 自动获得默认值
print(self.db.profile.items["sword"].enabled)  -- true (默认值)
print(self.db.profile.items["sword"].count)    -- 0 (默认值)
```

## 保存时机

SavedVariables 在以下时机保存：
- 退出游戏
- 重新登录
- 重载界面 (`/reload`)

### 手动触发保存

```lua
-- 请求立即保存（下一帧）
RequestIOSFileFlush()

-- 注意：这会触发游戏暂停
C_UI.Reload()
```

## 数据迁移

### 版本迁移

```lua
function MyAddon:MigrateData()
    local oldVersion = self.db.version or "0.0.0"

    if oldVersion < "1.0.0" then
        -- 迁移旧数据格式
        if self.db.oldSettings then
            self.db.profile = self.db.profile or {}
            self.db.profile.settings = self.db.oldSettings
            self.db.oldSettings = nil
        end
    end

    if oldVersion < "1.1.0" then
        -- 添加新字段
        self.db.profile.newFeature = true
    end

    self.db.version = "1.2.0"
end
```

### 重置过期数据

```lua
function MyAddon:CleanOldData()
    local currentWeek = C_DateAndTime.GetCurrentCalendarTime().monthDay

    -- 清理过期数据
    if self.db.lastCleanup ~= currentWeek then
        for key, data in pairs(self.db.cache or {}) do
            if data.expiry and data.expiry < time() then
                self.db.cache[key] = nil
            end
        end
        self.db.lastCleanup = currentWeek
    end
end
```

## 性能优化

### 减少数据量

```lua
-- 不推荐：保存完整对象
self.db.quests[questID] = questInfo  -- questInfo 包含大量数据

-- 推荐：只保存必要字段
self.db.quests[questID] = {
    id = questInfo.id,
    title = questInfo.title,
    completed = questInfo.completed,
}
```

### 避免频繁写入

```lua
-- 使用脏标记减少写入
local settingsDirty = false

function MyAddon:SetSetting(key, value)
    if self.db.profile[key] ~= value then
        self.db.profile[key] = value
        settingsDirty = true
    end
end

-- 批量保存
function MyAddon:SaveIfDirty()
    if settingsDirty then
        -- 数据会在退出时自动保存
        settingsDirty = false
    end
end
```

### 分离热数据和冷数据

```lua
-- 热：运行时频繁访问
local runtimeCache = {}

-- 冷：持久化存储
MyAddonDB = {}

function MyAddon:GetItem(id)
    -- 先查缓存
    if runtimeCache[id] then
        return runtimeCache[id]
    end

    -- 再查持久化数据
    if MyAddonDB.items[id] then
        runtimeCache[id] = MyAddonDB.items[id]
        return runtimeCache[id]
    end

    return nil
end
```

## 实际案例

参考 `WorldQuestTab` 项目：

```lua
-- WorldQuestTab 使用 AceDB-3.0
function WorldQuestTab:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WorldQuestTabDB", {
        profile = {
            general = {
                sortBy = "rewards",
                showFavorites = true,
                zoneQuests = "expansion",
            },
            filters = {
                gold = { enabled = true, minValue = 100 },
                currency = { enabled = true },
                equipment = { enabled = true, minIlvl = 400 },
            },
        },
        char = {
            favorites = {},
            hidden = {},
        },
    })
end
```

## 注意事项

### 战斗中保存

SavedVariables 在战斗中无法正常保存，但数据修改会被缓存到下次保存时机。

### 数据大小限制

单个 SavedVariables 变量的大小受 Lua 内存限制，建议：
- 单个变量不超过 1MB
- 定期清理过期数据

### 特殊字符

键名避免使用特殊字符：

```lua
-- 不推荐
self.db["account:name"] = data

-- 推荐
self.db.accountName = data
```

## 相关链接

- [Warcraft Wiki - Saving variables](https://warcraft.wiki.gg/wiki/Saving_variables)
- [AceDB-3.0 文档](../libraries/ace3/README.md)
- [TOC 文件详解](../getting-started/03-toc-format.md)
