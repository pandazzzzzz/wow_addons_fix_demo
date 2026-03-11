# 事件系统概述

> 魔兽世界事件系统是插件与游戏交互的核心机制
> 权威来源: [Warcraft Wiki - Events](https://warcraft.wiki.gg/wiki/Events)

## 概述

事件系统采用发布-订阅模式，游戏在特定状态变化时触发事件，插件可以注册监听器响应这些事件。

## 传统事件系统

### 基本用法

```lua
-- 创建帧并注册事件
local frame = CreateFrame("Frame");

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local isLogin, isReload = ...;
        print("Entered world, login:", isLogin);
    elseif event == "PLAYER_REGEN_DISABLED" then
        print("Entered combat");
    end
end);

-- 注册事件
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_REGEN_DISABLED");

-- 取消注册
frame:UnregisterEvent("PLAYER_ENTERING_WORLD");

-- 注册所有事件（调试用）
frame:RegisterAllEvents();
```

### 常用事件

| 事件 | 说明 | 参数 |
|------|------|------|
| `PLAYER_ENTERING_WORLD` | 进入世界/重载UI | isLogin, isReload |
| `PLAYER_REGEN_DISABLED` | 进入战斗 | 无 |
| `PLAYER_REGEN_ENABLED` | 离开战斗 | 无 |
| `UNIT_AURA` | 单位光环变化 | unitTarget |
| `QUEST_LOG_UPDATE` | 任务日志更新 | 无 |
| `BAG_UPDATE` | 背包更新 | bagID |
| `CHAT_MSG_CHANNEL` | 频道消息 | text, playerName, languageName, channelName |

### 事件处理模式

```lua
local MyAddon = {};
MyAddon.events = {
    PLAYER_ENTERING_WORLD = "OnPlayerEnteringWorld",
    PLAYER_REGEN_DISABLED = "OnEnterCombat",
    PLAYER_REGEN_ENABLED = "OnLeaveCombat",
};

function MyAddon:OnPlayerEnteringWorld(isLogin, isReload)
    if isLogin then
        self:Initialize();
    end
end

function MyAddon:OnEnterCombat()
    self.inCombat = true;
end

function MyAddon:OnLeaveCombat()
    self.inCombat = false;
end

function MyAddon:RegisterEvents()
    local frame = CreateFrame("Frame");
    frame:SetScript("OnEvent", function(self, event, ...)
        local handler = MyAddon.events[event];
        if handler then
            MyAddon[handler](MyAddon, ...);
        end
    end);

    for event in pairs(self.events) do
        frame:RegisterEvent(event);
    end

    self.eventFrame = frame;
end
```

## EventRegistry 系统

12.x 推荐使用现代事件系统 `EventRegistry`，提供更清晰的 API 和更好的性能。

### RegisterFrameEventAndCallback

无需创建帧即可监听游戏事件：

```lua
-- 注册游戏事件回调（无需创建帧）
-- 参数: event, callback, owner, ... (额外参数)
local token = EventRegistry:RegisterFrameEventAndCallback(
    "PLAYER_ENTERING_WORLD",
    function(ownerID, isLogin, isReload)
        print("玩家进入世界", isLogin, isReload)
    end,
    nil,  -- owner（可选）
    "extra", "args"  -- 额外参数会传递给回调
)

-- 注销回调
EventRegistry:UnregisterCallback("PLAYER_ENTERING_WORLD", nil)

-- 批量注册多个事件
EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", function()
    print("进入战斗")
end)

EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function()
    print("离开战斗")
end)
```

**与传统 frame:RegisterEvent 的区别**:
| 方式 | 优点 | 缺点 |
|------|------|------|
| `frame:RegisterEvent` | 兼容性好，支持 `UnregisterAllEvents` | 需要创建帧 |
| `RegisterFrameEventAndCallback` | 无需创建帧，代码更简洁 | 11.0+ 才支持 |

### 注册自定义回调

```lua
-- 注册回调
local callbackToken = EventRegistry:RegisterCallback(
    "MyCustomEvent",           -- 事件名称
    function(owner, ...)
        print("Event triggered!");
    end,
    self                       -- owner（可选）
);

-- 注销回调
EventRegistry:UnregisterCallback("MyCustomEvent", self);
```

### 触发事件

```lua
-- 触发自定义事件
EventRegistry:TriggerEvent("MyCustomEvent", arg1, arg2, arg3);
```

### 内置事件

游戏内建了一些 EventRegistry 事件：

```lua
-- 地图切换
EventRegistry:RegisterCallback("MapCanvas.MapSet", function()
    -- 地图已切换
end, self);

-- 世界地图打开
EventRegistry:RegisterCallback("WorldMapOnShow", function()
    -- 世界地图已打开
end, self);
```

## 实际案例

### 结合传统事件与 EventRegistry

参考 `WorldQuestTab/Dataprovider.lua`:

```lua
WQT_DataProvider = {};

function WQT_DataProvider:Init()
    -- 创建事件帧（传统事件）
    self.frame = CreateFrame("FRAME");
    self.frame:SetScript("OnEvent", function(frame, ...)
        self:OnEvent(...);
    end);

    -- 注册游戏事件
    self.frame:RegisterEvent("QUEST_LOG_UPDATE");
    self.frame:RegisterEvent("QUEST_DATA_LOAD_RESULT");
    self.frame:RegisterEvent("TOOLTIP_DATA_UPDATE");
    self.frame:RegisterEvent("CVAR_UPDATE");

    -- 注册回调事件（自定义事件系统）
    WQT_CallbackRegistry:RegisterCallback("WQT.SearchUpdated", function()
        self:RequestFilterUpdate();
    end, self);

    WQT_CallbackRegistry:RegisterCallback("WQT.FiltersUpdated", function()
        self:RequestFilterUpdate();
    end, self);

    -- 注册 EventRegistry 事件（12.x现代系统）
    EventRegistry:RegisterCallback("MapCanvas.MapSet", function()
        self:RequestDataUpdate();
    end, self);
end

function WQT_DataProvider:OnEvent(event, ...)
    if event == "QUEST_LOG_UPDATE" then
        self:RequestDataUpdate();
    elseif event == "QUEST_DATA_LOAD_RESULT" then
        self:RequestDataUpdate();
    elseif event == "TOOLTIP_DATA_UPDATE" then
        local id = ...;
        -- 处理 tooltip 更新
    elseif event == "CVAR_UPDATE" then
        local cvar = ...;
        if self:IsRelevantCvar(cvar) then
            self:RequestFilterUpdate();
        end
    end
end
```

### 创建自定义回调系统

```lua
-- 创建 CallbackRegistry
MyAddon_CallbackRegistry = CreateFromMixins(CallbackRegistryMixin);
MyAddon_CallbackRegistry:OnLoad();

-- 定义事件常量
local MY_EVENTS = {
    DATA_UPDATED = "MyAddon.DataUpdated",
    SETTINGS_CHANGED = "MyAddon.SettingsChanged",
};

-- 注册监听器
MyAddon_CallbackRegistry:RegisterCallback(
    MY_EVENTS.DATA_UPDATED,
    function(owner, dataType)
        print("Data updated:", dataType);
    end,
    self
);

-- 触发事件
MyAddon_CallbackRegistry:TriggerEvent(
    MY_EVENTS.DATA_UPDATED,
    "quests"
);
```

## 事件与帧池配合

```lua
function MyDataProvider:OnEvent(event, ...)
    if event == "ITEM_DATA_LOAD_RESULT" then
        local itemID, success = ...;
        if success then
            -- 遍历帧池中所有活跃对象
            for frame in self.pool:EnumerateActive() do
                if frame.itemID == itemID then
                    frame:UpdateIcon();
                end
            end
        end
    end
end
```

## 战斗锁定

某些操作在战斗中无法执行，需要处理 `PLAYER_REGEN_DISABLED/ENABLED`：

```lua
local MyAddon = {
    pendingActions = {},
    inCombat = false,
};

function MyAddon:RegisterCombatEvents()
    local frame = CreateFrame("Frame");
    frame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            MyAddon.inCombat = true;
        elseif event == "PLAYER_REGEN_ENABLED" then
            MyAddon.inCombat = false;
            MyAddon:ProcessPendingActions();
        end
    end);
    frame:RegisterEvent("PLAYER_REGEN_DISABLED");
    frame:RegisterEvent("PLAYER_REGEN_ENABLED");
end

function MyAddon:DoAction(action)
    if self.inCombat then
        table.insert(self.pendingActions, action);
    else
        action();
    end
end

function MyAddon:ProcessPendingActions()
    for _, action in ipairs(self.pendingActions) do
        action();
    end
    wipe(self.pendingActions);
end
```

## API 参考

| 函数 | 说明 |
|------|------|
| `frame:RegisterEvent(event)` | 注册事件监听 |
| `frame:UnregisterEvent(event)` | 取消事件监听 |
| `frame:RegisterAllEvents()` | 注册所有事件 |
| `EventRegistry:RegisterCallback(event, callback, owner)` | 注册自定义事件回调 |
| `EventRegistry:UnregisterCallback(event, owner)` | 取消回调 |
| `EventRegistry:TriggerEvent(event, ...)` | 触发自定义事件 |
| `EventRegistry:RegisterFrameEventAndCallback(event, callback, owner, ...)` | 注册游戏事件回调 (11.0+) |

## 相关链接

- [Warcraft Wiki - Events](https://warcraft.wiki.gg/wiki/Events)
- [Warcraft Wiki - EventRegistry](https://warcraft.wiki.gg/wiki/EventRegistry)
- [wow-ui-source - CallbackRegistry.lua](https://github.com/Gethe/wow-ui-source)
