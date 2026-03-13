# WoW插件开发速查表

> 魔兽世界正式服 (Retail 12.x) 插件开发速查表
> Interface: 120001 (Midnight)

## 目录

- [版本检测](#版本检测)
- [TOC格式](#toc格式)
- [常见API](#常见api)
- [事件系统](#事件系统)
- [战斗锁定](#战斗锁定)
- [常用库](#常用库)

## 版本检测

```lua
-- 获取客户端版本信息
local version, build, date, tocversion = GetBuildInfo()
-- tocversion >= 120001 表示 Midnight (12.x)

-- 检查是否为正式服
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

-- 12.0.1 移除的API (注意避免使用)
-- BNSetAFK/BNSetDND → 使用 C_BattleNet.SetAFK/SetDND
-- GetCurrentGraphicsSetting/SetCurrentGraphicsSetting (已移除)
```

## TOC格式

```
## Interface: 120001
## Title: MyAddon
## Notes: 我的插件描述
## Author: YourName
## Version: 1.0.0
## SavedVariables: MyAddonDB
## Dependencies: Blizzard_ObjectiveTracker

main.lua
```

## 常见API

### 基础函数
```lua
-- 打印
print("Hello WoW")

-- 创建帧
local frame = CreateFrame("Frame", "MyFrame", UIParent)
frame:SetSize(200, 100)
frame:SetPoint("CENTER")

-- 创建按钮
local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
button:SetSize(100, 30)
button:SetPoint("CENTER")
button:SetText("Click")
```

### 12.0 新增API
```lua
-- 获取图腾槽位数量
local numSlots = GetNumTotemSlots()

-- 调试对象转储
dumpobject(obj)

-- 获取战斗统计会话时长
local seconds = C_DamageMeter.GetSessionDurationSeconds()

-- 遭遇战时间轴
-- C_EncounterTimeline - 遭遇战时间轴系统
```

### C_QuestLog 任务日志
```lua
local numQuests = C_QuestLog.GetNumQuestLogEntries()
local questInfo = C_QuestLog.GetInfo(questLogIndex)
C_QuestLog.IsOnQuest(questID)
C_QuestLog.IsComplete(questID)
```

### C_Map 地图
```lua
local mapID = C_Map.GetBestMapForUnit("player")
local mapInfo = C_Map.GetMapInfo(mapID)
local position = C_Map.GetPlayerMapPosition(mapID, "player")
```

### C_Timer 定时器
```lua
-- 单次延迟执行
C_Timer.After(3, function()
    print("3秒后执行")
end)

-- 循环定时器
local ticker = C_Timer.NewTicker(1, function()
    print("每秒执行")
end, 5) -- 执行5次

-- 停止循环定时器
ticker:Cancel()
```

### 单位信息
```lua
local name = UnitName("player")
local health = UnitHealth("player")
local maxHealth = UnitHealthMax("player")
local level = UnitLevel("player")
local class = UnitClass("player")
local isDead = UnitIsDead("player")
```

### 战斗相关
```lua
-- 检查是否在战斗中
local inCombat = InCombatLockdown()

-- 施法信息 (12.0新增返回值 delayTimeMs)
local name, text, texture, startTime, endTime, isTradeSkill, 
      castID, notInterruptible, spellId, isChargeValue, delayTimeMs = UnitCastingInfo("player")
```

## 事件系统

### 传统方式
```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local isLogin, isReload = ...
        print("Entering world")
    end
end)
```

### EventRegistry (12.x 推荐)
```lua
-- 无需创建帧
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
    print("玩家进入世界")
end)

-- 带owner的注册
EventRegistry:RegisterFrameEventAndCallback(
    "PLAYER_REGEN_DISABLED",
    function(ownerID)
        print("进入战斗")
    end,
    "MyAddon"
)

-- 注销
EventRegistry:UnregisterCallback("PLAYER_ENTERING_WORLD", "MyAddon")
```

### 常用事件
| 事件 | 说明 |
|------|------|
| `PLAYER_ENTERING_WORLD` | 玩家进入世界 |
| `PLAYER_REGEN_DISABLED` | 进入战斗 |
| `PLAYER_REGEN_ENABLED` | 离开战斗 |
| `QUEST_LOG_UPDATE` | 任务日志更新 |
| `BAG_UPDATE` | 背包更新 |
| `UNIT_AURA` | 单位光环变化 |

### 12.0.1 新增事件
| 事件 | 说明 |
|------|------|
| `ENCOUNTER_TIMELINE_VIEW_ACTIVATED` | 时间轴视图激活 |
| `ENCOUNTER_TIMELINE_VIEW_DEACTIVATED` | 时间轴视图关闭 |
| `PLAYER_MAX_LEVEL_UPDATE` | 玩家最高等级更新 |

## 战斗锁定

```lua
-- 战斗中不能执行的操作
-- 1. 创建/显示/隐藏安全按钮
-- 2. 修改按钮属性
-- 3. 某些API调用

-- 处理战斗状态
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        -- 进入战斗
    else
        -- 离开战斗，执行待处理操作
    end
end)
```

## 常用库

### LibStub
```lua
local LibStub = LibStub
local myLib = LibStub("MyLib-1.0")
```

### AceAddon-3.0
```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceEvent-3.0")

function MyAddon:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function MyAddon:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    -- 处理事件
end
```

### AceDB-3.0
```lua
local defaults = {
    profile = {
        enabled = true,
        scale = 1.0,
    }
}

MyAddon.db = LibStub("AceDB-3.0"):New("MyAddonDB", defaults, true)
```

## API变更 (12.0.1)

### 已弃用/移除的API
```lua
-- 以下API已移除，需要替换:
-- BNSetAFK → C_BattleNet.SetAFK
-- BNSetDND → C_BattleNet.SetDND
-- GetCurrentGraphicsSetting (已移除)
-- SetCurrentGraphicsSetting (已移除)
-- C_NamePlate.GetTargetClampingInsets (已移除)
-- C_NamePlate.SetTargetClampingInsets (已移除)
```

### 参数变更
```lua
-- C_DamageMeter.GetCombatSessionSourceFromID
-- sourceGUID 参数现在为可选
-- 新增 sourceCreatureID 参数

-- C_StringUtil.StripHyperlinks
-- 新增 maintainTextures 参数 (arg 6)

-- C_CombatAudioAlert.SpeakText
-- 新增 category 参数 (arg 2)
```

## 参考链接

- [Warcraft Wiki](https://warcraft.wiki.gg)
- [wago.tools](https://wago.tools)
- [Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source)
