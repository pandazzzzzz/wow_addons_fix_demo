# C_QuestLog 命名空间

> 任务日志 API 参考
> 权威来源: [Warcraft Wiki - Quests](https://warcraft.wiki.gg/wiki/Category:API_functions/Quests)

## 概述

C_QuestLog 提供任务日志相关的操作 API。

## 常用函数

### 任务查询

```lua
-- 获取任务数量
local numQuests = C_QuestLog.GetNumQuestLogEntries()

-- 获取任务信息
local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
local info = C_QuestLog.GetInfo(questLogIndex)
-- info.questID, info.title, info.isHeader, info.isComplete, etc.

-- 检查任务是否在日志中
local isOnQuest = C_QuestLog.IsOnQuest(questID)

-- 获取任务标题
local title = C_QuestLog.GetTitleForQuestID(questID)
```

### 任务标签

```lua
-- 获取任务标签信息
local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
-- tagInfo.tagID, tagInfo.tagName, tagInfo.worldQuestType, tagInfo.quality

-- 检查任务分类
local classification = C_QuestInfoSystem.GetQuestClassification(questID)
-- Enum.QuestClassification: WorldQuest, BonusObjective, etc.
```

### 任务奖励

```lua
-- 获取奖励物品数量
local numRewards = GetNumQuestLogRewards(questID)

-- 获取奖励物品信息
local name, texture, count, quality, isUsable, itemID = GetQuestLogRewardInfo(rewardIndex, questID)

-- 获取奖励货币
local currencies = C_QuestLog.GetQuestRewardCurrencies(questID)

-- 获取奖励金币
local money = GetQuestLogRewardMoney(questID)

-- 获取奖励经验
local xp = GetQuestLogRewardXP(questID)

-- 检查是否有奖励数据
local hasData = HaveQuestRewardData(questID)
```

### 世界任务

```lua
-- 获取地图上的世界任务
local taskPOIs = C_TaskQuest.GetQuestsOnMap(mapID)
-- returns: { { questID, x, y, mapID }, ... }

-- 获取世界任务时间
local seconds = C_TaskQuest.GetQuestTimeLeftSeconds(questID)

-- 获取世界任务信息
local title, factionID = C_TaskQuest.GetQuestInfoByQuestID(questID)

-- 检查是否为世界任务标准
local isCriteria = C_QuestLog.IsQuestCriteriaForBounty(questID, bountyQuestID)
```

### 任务状态

```lua
-- 检查任务是否完成
local isComplete = C_QuestLog.IsComplete(questID)

-- 检查任务是否有数据
local hasData = HaveQuestData(questID)

-- 检查任务是否过期
local isExpired = C_TaskQuest.GetQuestTimeLeftSeconds(questID) == 0
```

### 追踪任务

```lua
-- 设置追踪任务
C_QuestLog.SetSelectedQuest(questID)

-- 获取当前选中的任务
local questID = C_QuestLog.GetSelectedQuest()

-- 超级追踪
C_SuperTrack.SetSuperTrackedQuestID(questID)
local superTrackedID = C_SuperTrack.GetSuperTrackedQuestID()
```

## 示例用法

### 获取所有追踪任务

```lua
local function GetTrackedQuests()
    local trackedQuests = {}
    local numEntries = C_QuestLog.GetNumQuestLogEntries()

    for i = 1, numEntries do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader then
            if C_QuestLog.IsQuestWatched(info.questID) then
                table.insert(trackedQuests, {
                    id = info.questID,
                    title = info.title,
                    level = info.level,
                })
            end
        end
    end

    return trackedQuests
end
```

### 获取世界任务奖励

```lua
local function GetWorldQuestRewards(questID)
    local rewards = {}

    -- 物品奖励
    local numItems = GetNumQuestLogRewards(questID)
    for i = 1, numItems do
        local name, texture, count, quality, _, itemID = GetQuestLogRewardInfo(i, questID)
        table.insert(reards, {
            type = "item",
            name = name,
            texture = texture,
            count = count,
            quality = quality,
            id = itemID,
        })
    end

    -- 货币奖励
    local currencies = C_QuestLog.GetQuestRewardCurrencies(questID)
    for _, currency in ipairs(currencies) do
        table.insert(rewards, {
            type = "currency",
            name = currency.name,
            texture = currency.texture,
            count = currency.totalRewardAmount,
            id = currency.currencyID,
        })
    end

    -- 金币
    local money = GetQuestLogRewardMoney(questID)
    if money > 0 then
        table.insert(rewards, {
            type = "money",
            amount = money,
        })
    end

    -- 经验
    local xp = GetQuestLogRewardXP(questID)
    if xp > 0 then
        table.insert(rewards, {
            type = "xp",
            amount = xp,
        })
    end

    return rewards
end
```

## 事件

| 事件 | 说明 |
|------|------|
| `QUEST_LOG_UPDATE` | 任务日志更新 |
| `QUEST_WATCH_UPDATE` | 追踪任务更新 |
| `QUEST_DATA_LOAD_RESULT` | 任务数据加载完成 |
| `QUEST_ACCEPTED` | 接受任务 |
| `QUEST_REMOVED` | 任务移除 |
| `QUEST_TURNED_IN` | 任务提交 |
| `QUEST_COMPLETE` | 任务完成 |

## 枚举

### QuestClassification

```lua
Enum.QuestClassification = {
    None = 0,
    Quest = 1,
    WorldQuest = 2,
    BonusObjective = 3,
}
```

### QuestTag

```lua
Enum.QuestTag = {
    Group = 1,
    PVP = 41,
    Raid = 62,
    Dungeon = 81,
    Scenario = 98,
    Delves = 285,
}
```

## 相关链接

- [Warcraft Wiki - Quest API](https://warcraft.wiki.gg/wiki/Category:API_functions/Quests)
- [事件系统概述](../events/README.md)
