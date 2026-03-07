# 魔兽世界插件开发快速参考

## 常用命令

### 游戏内调试
```lua
/reload                    -- 重载UI
/dump var                  -- 打印变量
/fstack                    -- 显示帧层级
/console scriptErrors 1    -- 启用错误显示
```

### API 快速查询
```lua
/dump GetBuildInfo()                 -- 版本信息
/dump C_AddOns.GetAddOnInfo("name")  -- 插件信息
/dump UnitName("player")             -- 玩家名称
/dump UnitClass("player")            -- 玩家职业
/dump GetTime()                      -- 游戏时间
```

---

## TOC 头部模板

```toc
## Interface: 120001
## Title: Addon Name
## Title-zhCN: 中文名
## Notes: Description
## Notes-zhCN: 描述
## Author: YourName
## Version: 1.0.0
## SavedVariables: AddonDB
## OptionalDeps: Ace3
```

---

## 核心事件

| 事件 | 说明 |
|------|------|
| `ADDON_LOADED` | 插件加载完成 |
| `PLAYER_LOGIN` | 玩家登录 |
| `PLAYER_ENTERING_WORLD` | 进入世界 |
| `QUEST_LOG_UPDATE` | 任务更新 |
| `BAG_UPDATE` | 背包更新 |
| `UNIT_HEALTH` | 血量变化 |
| `UNIT_AURA` | BUFF/DEBUFF变化 |
| `CHAT_MSG_*` | 聊天消息 |

---

## 常用 API

### 角色信息
```lua
UnitName("player")           -- 名字
UnitClass("player")          -- 职业
UnitRace("player")           -- 种族
UnitLevel("player")          -- 等级
UnitHealth("player")         -- 当前血量
UnitHealthMax("player")      -- 最大血量
UnitPower("player")          -- 当前能量
UnitExists("target")         -- 目标是否存在
```

### 任务相关
```lua
C_QuestLog.GetNumQuestLogEntries()      -- 任务数量
C_QuestLog.GetTitleForQuestID(id)       -- 任务标题
C_QuestLog.IsComplete(id)               -- 是否完成
C_QuestLog.GetQuestObjectives(id)       -- 目标列表
C_SuperTrack.SetSuperTrackedQuestID(id) -- 设置追踪
```

### 地图相关
```lua
C_Map.GetBestMapForUnit("player")       -- 当前地图ID
C_Map.GetMapInfo(mapID)                 -- 地图信息
GetPlayerMapPosition("player")          -- 玩家坐标
```

### 背包相关
```lua
GetContainerNumSlots(bagID)             -- 背包槽数量
GetContainerItemLink(bagID, slot)       -- 物品链接
GetItemCount(itemID)                    -- 物品数量
C_Container.GetContainerItemInfo()      -- 物品信息
```

---

## 帧创建

```lua
-- 基础帧
local frame = CreateFrame("Frame", "MyFrame", UIParent)
frame:SetSize(200, 100)
frame:SetPoint("CENTER")
frame:Show()

-- 带背景
frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints()
frame.bg:SetColorTexture(0, 0, 0, 0.5)

-- 文字
frame.text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
frame.text:SetPoint("CENTER")
frame.text:SetText("Hello World")
```

---

## 事件注册

```lua
-- 传统方式
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        print("Logged in!")
    end
end)

-- EventRegistry（现代方式）
EventRegistry:RegisterCallback("Event.Name", callback, owner)
```

---

## 数据持久化

```lua
-- TOC声明: ## SavedVariables: MyDB

-- 使用
if not MyDB then MyDB = {} end
MyDB.setting = "value"

-- AceDB方式
self.db = LibStub("AceDB-3.0"):New("MyDB", defaults, true)
self.db.profile.setting = "value"
```

---

## 帧池模式

```lua
-- 创建池
local pool = CreateFramePool("BUTTON", parent, "Template", resetFunc)

-- 获取
local frame = pool:Acquire()
frame:SetPoint("CENTER")
frame:Show()

-- 释放
pool:Release(frame)
```

---

## Mixin 模式

```lua
-- 定义 Mixin
MyFrameMixin = {}

function MyFrameMixin:OnLoad()
    self:RegisterEvent("SOME_EVENT")
end

function MyFrameMixin:OnEvent(event, ...)
    -- 处理事件
end

-- 在XML中使用
-- <Frame name="MyFrame" inherits="MyFrameTemplate" parentArray="Frames">
--     <Scripts>
--         <OnLoad>self:OnLoad()</OnLoad>
--         <OnEvent>self:OnEvent(event, ...)</OnEvent>
--     </Scripts>
-- </Frame>
```

---

## 性能优化

1. **缓存全局变量**
   ```lua
   local _G = _G
   local pairs = pairs
   ```

2. **避免OnUpdate创建表**
   ```lua
   -- 错误
   frame:SetScript("OnUpdate", function()
       local t = {}  -- 每帧创建表！
   end)

   -- 正确
   local t = {}
   frame:SetScript("OnUpdate", function()
       wipe(t)  -- 复用表
   end)
   ```

3. **事件去重**
   ```lua
   local nextUpdate = 0
   frame:SetScript("OnUpdate", function(self, elapsed)
       nextUpdate = nextUpdate - elapsed
       if nextUpdate > 0 then return end
       nextUpdate = 0.1  -- 每0.1秒更新一次
       -- 处理逻辑
   end)
   ```

---

## 错误处理

```lua
-- 安全调用
local success, err = pcall(function()
    -- 可能出错的代码
end)

if not success then
    print("Error:", err)
end

-- 战斗检查
if InCombatLockdown() then return end
```

---

## 版本兼容

```lua
local interfaceVersion = select(4, GetBuildInfo())

if interfaceVersion >= 120000 then
    -- Midnight (12.x) API
elseif interfaceVersion >= 110000 then
    -- The War Within (11.x) API
else
    -- Dragonflight (10.x) API
end
```
