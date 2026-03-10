# 帧池模式 (Frame Pool)

> 帧池是魔兽世界插件性能优化的核心模式
> 参考实现: `addons/WorldQuestTab/Dataprovider.lua`

## 概述

帧池（Object Pool）是一种对象复用模式，通过预先创建对象并在需要时"借用"，用完后"归还"池中，避免频繁的内存分配和垃圾回收。这在需要动态创建大量 UI 元素时尤为重要。

## 为什么需要帧池

### 问题场景

```lua
-- 错误做法：每次更新创建新对象
function MyAddon:UpdateQuestList(quests)
    -- 清空现有列表
    for _, frame in ipairs(self.frames) do
        frame:Hide();
        frame:SetParent(nil);
    end
    self.frames = {};

    -- 创建新帧 - 每次都是新的内存分配
    for i, quest in ipairs(quests) do
        local frame = CreateFrame("Button", nil, self);
        -- 设置帧...
        table.insert(self.frames, frame);
    end
end
-- 这会导致：
-- 1. 频繁的内存分配
-- 2. 旧对象成为垃圾，触发 GC
-- 3. 游戏卡顿
```

### 帧池解决方案

```lua
-- 正确做法：使用帧池复用
function MyAddon:UpdateQuestList(quests)
    -- 归还所有帧到池中
    for _, frame in ipairs(self.activeFrames) do
        self.pool:Release(frame);
    end
    wipe(self.activeFrames);

    -- 从池中获取帧
    for i, quest in ipairs(quests) do
        local frame = self.pool:Acquire();
        frame:SetQuest(quest);
        table.insert(self.activeFrames, frame);
    end
end
-- 优点：
-- 1. 内存复用，减少 GC 压力
-- 2. 性能稳定
-- 3. 适合频繁更新的列表
```

## 基础用法

### 创建帧池

```lua
-- 简单帧池
local pool = CreateObjectPool();

-- 带创建函数的帧池
local pool = CreateObjectPool(function(pool)
    local frame = CreateFrame("Button", nil, UIParent);
    frame:SetSize(200, 30);
    return frame;
end);

-- 带创建和重置函数的帧池
local pool = CreateObjectPool(
    function(pool)
        -- 创建函数
        local frame = CreateFrame("Button", nil, UIParent);
        frame:SetSize(200, 30);
        return frame;
    end,
    function(pool, frame)
        -- 重置函数
        frame:ClearAllPoints();
        frame:Hide();
        frame.questID = nil;
    end
);
```

### 使用帧池

```lua
-- 获取对象
local obj = pool:Acquire();

-- 使用对象
obj:SetPoint("TOPLEFT", 0, -30 * i);
obj:SetText(quest.title);
obj:Show();

-- 归还对象
pool:Release(obj);

-- 批量获取
local count = pool:GetActiveObjectsCount();
for obj in pool:EnumerateActive() do
    -- 遍历所有活跃对象
    obj:Update();
end
```

## 实际案例

### 任务列表帧池

参考 `WorldQuestTab/Dataprovider.lua`:

```lua
----------------------------
-- QuestInfoMixin - 定义对象行为
----------------------------
local QuestInfoMixin = {};

-- 创建函数
function WQT_Utils:QuestCreationFunc(questId)
    local questInfo = CreateFromMixins(QuestInfoMixin);
    questInfo:OnCreate();
    return questInfo;
end

-- 重置函数
local function QuestResetFunc(pool, questInfo)
    questInfo:Reset();
end

-- 初始化方法 - 分配内存
function QuestInfoMixin:OnCreate()
    self.time = {};
    self.reward = { ["typeBits"] = WQT_REWARDTYPE.missing };
    self.rewardList = {};
    self.hasRewardData = false;
    self.searchResults = {};
end

-- 重置方法 - 清理数据但保留表
function QuestInfoMixin:Reset()
    wipe(self.rewardList);
    wipe(self.searchResults);

    -- 递归清理（保留颜色表）
    WipeQuestInfoRecursive(self);

    -- 重置默认值
    self.reward.typeBits = WQT_REWARDTYPE.missing;
    self.hasRewardData = false;
    self.isValid = false;
end

-- 初始化业务数据
function QuestInfoMixin:Init(questID, qInfo)
    self.questID = questID;
    self.mapID = qInfo and qInfo.mapID;
    self:UpdateTitleAndFaction();
    self.tagInfo = C_QuestLog.GetQuestTagInfo(questID);
    -- ...
end

----------------------------
-- DataProvider - 管理帧池
----------------------------
WQT_DataProvider = {};

function WQT_DataProvider:Init()
    -- 创建帧池
    self.pool = CreateObjectPool(
        WQT_Utils.QuestCreationFunc,
        QuestResetFunc
    );

    -- 其他初始化...
end

-- 获取新任务
local questInfo = self.pool:Acquire();
questInfo:Init(apiInfo.questID, apiInfo);

-- 释放不需要的任务
self.pool:Release(questInfo);

-- 遍历活跃任务
for questInfo in self.pool:EnumerateActive() do
    questInfo:LoadRewards(true);
end
```

## 高级用法

### 帧池与 Mixin 结合

```lua
local ItemButtonMixin = {};

function ItemButtonMixin:OnCreate()
    self:SetSize(40, 40);
    self:SetScript("OnClick", function()
        self:OnClick();
    end);
end

function ItemButtonMixin:Reset()
    self:ClearAllPoints();
    self:Hide();
    self.itemID = nil;
    self:SetNormalTexture(nil);
end

function ItemButtonMixin:SetItem(itemID)
    self.itemID = itemID;
    local _, _, _, _, _, _, _, _, _, texture = C_Item.GetItemInfo(itemID);
    self:SetNormalTexture(texture);
    self:Show();
end

function ItemButtonMixin:OnClick()
    if self.itemID then
        print("Clicked item:", self.itemID);
    end
end

-- 创建帧池
local itemPool = CreateObjectPool(
    function(pool)
        local frame = CreateFrame("Button", nil, UIParent);
        Mixin(frame, ItemButtonMixin);
        frame:OnCreate();
        return frame;
    end,
    function(pool, frame)
        frame:Reset();
    end
);
```

### 动态帧数量管理

```lua
function MyList:UpdateItems(items)
    local activeCount = 0;

    -- 更新或创建项目
    for i, item in ipairs(items) do
        local frame = self.pool:Acquire();
        frame:SetPoint("TOPLEFT", 0, -30 * (i - 1));
        frame:SetItem(item);
        frame:Show();
        activeCount = activeCount + 1;
    end

    -- 释放多余的项目
    local currentCount = 0;
    for frame in self.pool:EnumerateActive() do
        currentCount = currentCount + 1;
        if currentCount > activeCount then
            self.pool:Release(frame);
        end
    end
end
```

## API 参考

| 函数 | 说明 |
|------|------|
| `CreateObjectPool(createFunc, resetFunc)` | 创建帧池 |
| `pool:Acquire()` | 获取一个对象 |
| `pool:Release(object)` | 归还一个对象 |
| `pool:EnumerateActive()` | 枚举所有活跃对象（迭代器） |
| `pool:GetActiveObjectsCount()` | 获取活跃对象数量 |
| `pool:ReleaseAll()` | 归还所有活跃对象 |

## 性能对比

| 操作 | 无帧池 | 有帧池 |
|------|--------|--------|
| 创建100个按钮 | ~5ms | ~0.5ms (首次) |
| 更新列表(频繁) | 每次~3ms | 每次~0.3ms |
| GC 压力 | 高 | 低 |
| 内存碎片化 | 高 | 低 |

## 最佳实践

### 1. 分离创建和重置逻辑

```lua
-- 创建：分配内存，设置不变属性
function MyMixin:OnCreate()
    self.data = {};           -- 分配一次
    self:SetSize(100, 30);    -- 不变属性
end

-- 重置：清理数据，保留表结构
function MyMixin:Reset()
    wipe(self.data);          -- 复用表
    self:Hide();              -- 状态重置
end
```

### 2. 避免在 OnUpdate 中创建表

```lua
-- 错误
frame:SetScript("OnUpdate", function(self, elapsed)
    local pos = {}  -- 每帧创建新表！
    pos.x, pos.y = self:GetCenter();
    self:CheckPosition(pos);
end);

-- 正确：在创建时分配表
function MyFrame:OnCreate()
    self.position = { x = 0, y = 0 };
end

frame:SetScript("OnUpdate", function(self, elapsed)
    self.position.x, self.position.y = self:GetCenter();
    self:CheckPosition(self.position);
end);
```

### 3. 批量操作

```lua
-- 批量释放比逐个释放更高效
function MyList:Clear()
    for frame in self.pool:EnumerateActive() do
        self.pool:Release(frame);
    end
end
```

## 相关模式

- [Mixin模式](mixin-pattern.md) - 与帧池配合定义对象行为
- [EventRegistry系统](event-registry.md) - 事件驱动的数据更新

## 参考链接

- [Warcraft Wiki - ObjectPool](https://warcraft.wiki.gg/wiki/ObjectPool)
- [wow-ui-source - ObjectPool.lua](https://github.com/Gethe/wow-ui-source)
