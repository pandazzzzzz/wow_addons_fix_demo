# EventRegistry 系统

> 12.x 现代事件系统
> 权威来源: [Warcraft Wiki - EventRegistry](https://warcraft.wiki.gg/wiki/EventRegistry)

## 概述

EventRegistry 是魔兽世界 12.x 推荐使用的事件系统，相比传统的 `frame:RegisterEvent`，提供了更清晰的 API 和更好的模块化支持。

## 传统方式 vs EventRegistry

### 传统方式

```lua
-- 需要创建帧
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "QUEST_LOG_UPDATE" then
        -- 处理事件
    end
end)
frame:RegisterEvent("QUEST_LOG_UPDATE")
```

### EventRegistry 方式

```lua
-- 直接注册回调
EventRegistry:RegisterCallback("QUEST_LOG_UPDATE", function(owner, ...)
    -- 处理事件
end, self)
```

## 基本用法

### 注册回调

```lua
-- 注册事件回调
local token = EventRegistry:RegisterCallback("EVENT_NAME", callback, owner)
```

参数说明：
- `EVENT_NAME` - 事件名称
- `callback` - 回调函数，签名为 `function(owner, ...) end`
- `owner` - 可选，回调的所有者，用于注销

### 注销回调

```lua
-- 按 owner 注销
EventRegistry:UnregisterCallback("EVENT_NAME", owner)

-- 注销指定 token
EventRegistry:UnregisterCallbackByToken(token)
```

### 触发自定义事件

```lua
-- 定义事件名称
local MY_EVENT = "MyAddon.DataUpdated"

-- 触发事件
EventRegistry:TriggerEvent(MY_EVENT, arg1, arg2, arg3)

-- 监听事件
EventRegistry:RegisterCallback(MY_EVENT, function(owner, data1, data2)
    print("Data updated:", data1, data2)
end, self)
```

## 内置事件

EventRegistry 提供了一些内置事件：

| 事件 | 说明 |
|------|------|
| `MapCanvas.MapSet` | 地图切换 |
| `WorldMapOnShow` | 世界地图打开 |
| `WorldMapOnHide` | 世界地图关闭 |

### 使用示例

```lua
EventRegistry:RegisterCallback("MapCanvas.MapSet", function(owner)
    local mapID = WorldMapFrame:GetMapID()
    print("Map changed to:", mapID)
end, self)
```

## 创建自定义 CallbackRegistry

大型插件建议创建独立的 CallbackRegistry：

```lua
-- 创建命名空间
MyAddon_CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
MyAddon_CallbackRegistry:OnLoad()

-- 定义事件常量（推荐）
local MyEvents = {
    DATA_LOADED = "MyAddon.DataLoaded",
    QUEST_UPDATED = "MyAddon.QuestUpdated",
    FILTER_CHANGED = "MyAddon.FilterChanged",
    SETTINGS_CHANGED = "MyAddon.SettingsChanged",
}

-- 注册监听器
MyAddon_CallbackRegistry:RegisterCallback(
    MyEvents.DATA_LOADED,
    function(owner, dataType)
        print("Data loaded:", dataType)
    end,
    self
)

-- 触发事件
MyAddon_CallbackRegistry:TriggerEvent(
    MyEvents.DATA_LOADED,
    "quests"
)
```

## 实际案例

参考 `WorldQuestTab/Dataprovider.lua`:

```lua
WQT_DataProvider = {};

function WQT_DataProvider:Init()
    -- 传统事件（游戏事件）
    self.frame = CreateFrame("FRAME");
    self.frame:SetScript("OnEvent", function(frame, ...)
        self:OnEvent(...);
    end);
    self.frame:RegisterEvent("QUEST_LOG_UPDATE");
    self.frame:RegisterEvent("QUEST_DATA_LOAD_RESULT");

    -- 自定义回调系统（插件内部事件）
    WQT_CallbackRegistry:RegisterCallback("WQT.SearchUpdated", function()
        self:RequestFilterUpdate();
    end, self);

    WQT_CallbackRegistry:RegisterCallback("WQT.FiltersUpdated", function()
        self:RequestFilterUpdate();
    end, self);

    WQT_CallbackRegistry:RegisterCallback("WQT.SortUpdated", function()
        self:RequestFilterUpdate();
    end, self);

    WQT_CallbackRegistry:RegisterCallback("WQT.SettingChanged",
        function(_, _, tag)
            if tag == "ZONE_QUESTS" then
                self:RequestDataUpdate();
            elseif tag == "GENERIC_ANIMA" then
                self:RequestRewardsUpdate();
            end
        end,
        self
    );

    -- EventRegistry（系统事件）
    EventRegistry:RegisterCallback("MapCanvas.MapSet", function()
        self:RequestDataUpdate();
    end, self);
end

-- 更新完成后触发事件
function WQT_DataProvider:FilterAndSortQuestList()
    -- ... 处理逻辑 ...

    WQT_CallbackRegistry:TriggerEvent("WQT.DataProvider.FilteredListUpdated");
end
```

## 回调携带数据

```lua
-- 触发事件时携带多个参数
MyAddon_CallbackRegistry:TriggerEvent(
    MyEvents.QUEST_UPDATED,
    questID,      -- 参数1
    questInfo,    -- 参数2
    wasUpdated    -- 参数3
)

-- 接收参数
MyAddon_CallbackRegistry:RegisterCallback(
    MyEvents.QUEST_UPDATED,
    function(owner, questID, questInfo, wasUpdated)
        if wasUpdated then
            print("Quest updated:", questID, questInfo.title)
        end
    end,
    self
)
```

## 多监听器

同一个事件可以有多个监听器：

```lua
-- 模块 A 监听
MyAddon_CallbackRegistry:RegisterCallback(MyEvents.SETTINGS_CHANGED, function(owner, key, value)
    print("Module A: Setting changed", key, value)
end, moduleA)

-- 模块 B 同时监听
MyAddon_CallbackRegistry:RegisterCallback(MyEvents.SETTINGS_CHANGED, function(owner, key, value)
    print("Module B: Setting changed", key, value)
end, moduleB)

-- 触发时，两个监听器都会被调用
MyAddon_CallbackRegistry:TriggerEvent(MyEvents.SETTINGS_CHANGED, "scale", 1.2)
```

## 与 Mixin 配合

```lua
local MyModuleMixin = {}

-- 注册事件
function MyModuleMixin:RegisterEvents()
    MyAddon_CallbackRegistry:RegisterCallback(
        MyEvents.DATA_LOADED,
        self.OnDataLoaded,
        self  -- owner 是 self，回调中访问 self
    )
end

-- 回调方法
function MyModuleMixin:OnDataLoaded()
    -- self 是模块实例
    self:Refresh()
end

-- 注销事件
function MyModuleMixin:UnregisterEvents()
    MyAddon_CallbackRegistry:UnregisterCallback(
        MyEvents.DATA_LOADED,
        self
    )
end
```

## API 参考

| 方法 | 说明 |
|------|------|
| `RegisterCallback(event, callback, owner)` | 注册回调 |
| `UnregisterCallback(event, owner)` | 按 owner 注销 |
| `UnregisterCallbackByToken(token)` | 按 token 注销 |
| `TriggerEvent(event, ...)` | 触发事件 |
| `DoesCallbackExist(event, owner)` | 检查回调是否存在 |

## 最佳实践

### 1. 使用常量定义事件名

```lua
-- 错误：字符串分散
EventRegistry:RegisterCallback("myaddon-loaded", ...)
EventRegistry:TriggerEvent("myaddon_loaded", ...)  -- 拼写错误！

-- 正确：使用常量
local Events = {
    LOADED = "MyAddon.Loaded",
}
EventRegistry:RegisterCallback(Events.LOADED, ...)
EventRegistry:TriggerEvent(Events.LOADED, ...)
```

### 2. 及时注销

```lua
function MyModule:OnDisable()
    -- 模块禁用时注销所有事件
    for event in pairs(self.registeredEvents) do
        MyAddon_CallbackRegistry:UnregisterCallback(event, self)
    end
end
```

### 3. 避免循环触发

```lua
-- 危险：可能造成无限循环
MyAddon_CallbackRegistry:RegisterCallback(
    Events.SETTINGS_CHANGED,
    function(owner, key, value)
        if key == "autoUpdate" then
            -- 修改设置又会触发 SETTINGS_CHANGED！
            db.settings.lastAutoUpdate = time()
        end
    end,
    self
)

-- 正确：使用标志防止循环
local isUpdating = false
MyAddon_CallbackRegistry:RegisterCallback(
    Events.SETTINGS_CHANGED,
    function(owner, key, value)
        if isUpdating then return end
        isUpdating = true
        -- 安全修改设置
        db.settings.lastAutoUpdate = time()
        isUpdating = false
    end,
    self
)
```

## 相关链接

- [事件系统概述](../../api-reference/events/README.md)
- [Mixin模式](mixin-pattern.md)
- [Warcraft Wiki - CallbackRegistry](https://warcraft.wiki.gg/wiki/CallbackRegistry)
