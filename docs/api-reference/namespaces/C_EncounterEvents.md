# C_EncounterEvents API

## 概述

遭遇战事件系统API，12.0 Midnight 新增功能。用于处理副本/团队副本中的遭遇战事件。

## 函数

### GetEncounterEvents

获取当前遭遇战的事件列表。

```lua
local events = C_EncounterEvents.GetEncounterEvents()
```

**返回值：**
- `events` (table) - 遭遇战事件数组

---

### GetActiveEncounterEvent

获取当前激活的遭遇战事件。

```lua
local event = C_EncounterEvents.GetActiveEncounterEvent()
```

**返回值：**
- `event` (EncounterEventInfo|nil) - 当前激活的事件，如果没有则为nil

---

## 数据结构

### EncounterEventInfo

```lua
{
    eventID = 123,
    name = "事件名称",
    description = "事件描述",
    timestamp = 1234567890,
}
```

## 使用示例

```lua
-- 获取遭遇战事件
local events = C_EncounterEvents.GetEncounterEvents()
for _, event in ipairs(events) do
    print("事件:", event.name)
end

-- 获取当前激活事件
local activeEvent = C_EncounterEvents.GetActiveEncounterEvent()
if activeEvent then
    print("当前事件:", activeEvent.name)
end
```

## 相关链接

- [C_EncounterTimeline](C_EncounterTimeline.md) - 遭遇战时间轴API
- [Warcraft Wiki - EncounterEvents](https://warcraft.wiki.gg)
