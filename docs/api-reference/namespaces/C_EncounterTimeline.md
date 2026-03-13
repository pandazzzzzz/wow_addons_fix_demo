# C_EncounterTimeline API

## 概述

遭遇战时间轴系统API，12.0 Midnight 新增功能。用于管理副本/团队副本中的时间轴视图。

## 函数

### IsViewingTimeline

检查当前是否正在查看时间轴。

```lua
local isViewing = C_EncounterTimeline.IsViewingTimeline()
```

**返回值：**
- `isViewing` (boolean) - 是否正在查看时间轴

---

### GetEncounterTimelines

获取当前遭遇战的时间轴数据。

```lua
local timelines = C_EncounterTimeline.GetEncounterTimelines()
```

**返回值：**
- `timelines` (table) - 时间轴数据数组

---

## 事件

### ENCOUNTER_TIMELINE_VIEW_ACTIVATED

当时间轴视图激活时触发。

```lua
EventRegistry:RegisterFrameEventAndCallback("ENCOUNTER_TIMELINE_VIEW_ACTIVATED", function()
    print("时间轴视图已激活")
end)
```

---

### ENCOUNTER_TIMELINE_VIEW_DEACTIVATED

当时间轴视图关闭时触发。

```lua
EventRegistry:RegisterFrameEventAndCallback("ENCOUNTER_TIMELINE_VIEW_DEACTIVATED", function()
    print("时间轴视图已关闭")
end)
```

---

## 使用示例

```lua
-- 检查是否正在查看时间轴
if C_EncounterTimeline.IsViewingTimeline() then
    local timelines = C_EncounterTimeline.GetEncounterTimelines()
    for _, timeline in ipairs(timelines) do
        print("时间轴事件:", timeline.name, timeline.time)
    end
end

-- 监听时间轴事件
local MyAddon = {}

function MyAddon:OnEnable()
    EventRegistry:RegisterFrameEventAndCallback(
        "ENCOUNTER_TIMELINE_VIEW_ACTIVATED",
        function() self:OnTimelineActivated() end,
        self
    )
    EventRegistry:RegisterFrameEventAndCallback(
        "ENCOUNTER_TIMELINE_VIEW_DEACTIVATED",
        function() self:OnTimelineDeactivated() end,
        self
    )
end

function MyAddon:OnTimelineActivated()
    print("时间轴已激活")
    -- 获取时间轴数据
    self.timelines = C_EncounterTimeline.GetEncounterTimelines()
end

function MyAddon:OnTimelineDeactivated()
    print("时间轴已关闭")
    self.timelines = nil
end
```

## 相关链接

- [C_DamageMeter](C_DamageMeter.md) - 伤害统计API
- [Warcraft Wiki - EncounterTimeline](https://warcraft.wiki.gg)
