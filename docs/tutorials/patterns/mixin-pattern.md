# Mixin 设计模式

> Mixin 是魔兽世界插件开发中的核心面向对象模式
> 参考实现: `addons/WorldQuestTab/Dataprovider.lua`

## 概述

Mixin（混入）是一种代码复用模式，允许将方法和属性"混入"到对象中，实现类似多重继承的效果。魔兽世界提供了原生的 `CreateFromMixins` 函数支持这种模式。

## 基础用法

### 定义 Mixin

```lua
-- 定义一个基本的 Mixin 表
local QuestInfoMixin = {};

function QuestInfoMixin:OnCreate()
    self.questID = nil;
    self.title = "";
    self.rewardList = {};
end

function QuestInfoMixin:Init(questID)
    self.questID = questID;
    self.title = C_TaskQuest.GetQuestInfoByQuestID(questID);
end

function QuestInfoMixin:GetTitle()
    return self.title;
end
```

### 创建实例

```lua
-- 使用 CreateFromMixins 创建实例
local questInfo = CreateFromMixins(QuestInfoMixin);
questInfo:OnCreate();  -- 手动调用初始化
questInfo:Init(12345); -- 业务初始化
```

## Mixin 继承

### 单层继承

```lua
-- 基础 Mixin
local BaseMixin = {
    name = "",
    enabled = true
};

function BaseMixin:Enable()
    self.enabled = true;
end

function BaseMixin:Disable()
    self.enabled = false;
end

-- 派生 Mixin
local ExtendedMixin = CreateFromMixins(BaseMixin);

ExtendedMixin.powerLevel = 0;

function ExtendedMixin:SetPower(level)
    self.powerLevel = level;
end

function ExtendedMixin:IsActive()
    return self.enabled and self.powerLevel > 0;
end
```

### 多重继承

```lua
local ClickableMixin = {};

function ClickableMixin:OnClick()
    if self.OnClickCallback then
        self:OnClickCallback();
    end
end

local DraggableMixin = {};

function DraggableMixin:OnDragStart()
    self:StartMoving();
end

-- 组合多个 Mixin
local MyButtonMixin = CreateFromMixins(ClickableMixin, DraggableMixin);
```

## 实际案例

### 帧池模式中的 Mixin

参考 `WorldQuestTab/Dataprovider.lua` 的实现：

```lua
-- 定义 Mixin
local QuestInfoMixin = {};

-- 创建工厂函数
function WQT_Utils:QuestCreationFunc(questId)
    local questInfo = CreateFromMixins(QuestInfoMixin);
    questInfo:OnCreate();
    return questInfo;
end

-- 重置函数（用于帧池）
local function QuestResetFunc(pool, questInfo)
    questInfo:Reset();
end

-- Mixin 方法
function QuestInfoMixin:Reset()
    wipe(self.rewardList);
    wipe(self.searchResults);
    self.reward.typeBits = WQT_REWARDTYPE.missing;
    self.hasRewardData = false;
    self.isValid = false;
end

function QuestInfoMixin:Init(questID, qInfo)
    self.questID = questID;
    self.mapID = qInfo and qInfo.mapID;
    self:UpdateTitleAndFaction();
    self.tagInfo = C_QuestLog.GetQuestTagInfo(questID);
    -- ... 更多初始化逻辑
end

function QuestInfoMixin:UpdateValidity()
    local correctClassification = self.classification == Enum.QuestClassification.WorldQuest;
    self.isValid = correctClassification and not self.isBanned and HaveQuestData(self.questID);
    return self.isValid;
end

-- 创建帧池
self.pool = CreateObjectPool(WQT_Utils.QuestCreationFunc, QuestResetFunc);
```

## 帧的 Mixin

### XML 中定义

```xml
<Frame name="MyFrameTemplate" mixin="MyFrameMixin" virtual="true">
    <Scripts>
        <OnLoad method="OnLoad"/>
        <OnEvent method="OnEvent"/>
    </Scripts>
</Frame>
```

### Lua 中定义

```lua
MyFrameMixin = {};

function MyFrameMixin:OnLoad()
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self.widgets = {};
end

function MyFrameMixin:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:Refresh();
    end
end

function MyFrameMixin:Refresh()
    -- 刷新逻辑
end
```

### 继承帧模板

```lua
local MyExtendedMixin = CreateFromMixins(MyFrameMixin);

function MyExtendedMixin:OnLoad()
    -- 调用父类方法
    MyFrameMixin.OnLoad(self);

    -- 添加额外逻辑
    self:RegisterEvent("BAG_UPDATE");
end
```

## 最佳实践

### 1. 命名规范

```lua
-- Mixin 名称以 Mixin 结尾
local QuestInfoMixin = {};
local FrameControllerMixin = {};

-- 内部方法使用下划线前缀表示私有
function QuestInfoMixin:_calculateBonus()
    -- 私有方法
end
```

### 2. 初始化方法

```lua
local MyMixin = {};

-- 推荐使用 OnCreate 进行内存分配
function MyMixin:OnCreate()
    self.data = {};      -- 创建表
    self.callbacks = {}; -- 创建表
    self.count = 0;      -- 初始化数值
end

-- 使用 Init 进行业务初始化
function MyMixin:Init(config)
    self.config = config;
    self:Refresh();
end
```

### 3. 避免循环引用

```lua
-- 错误：Mixin A 和 B 相互引用
local MixinA = CreateFromMixins(MixinB); -- MixinB 未定义
local MixinB = CreateFromMixins(MixinA);

-- 正确：延迟引用或使用注入
local MixinA = {};
function MixinA:SetDependency(dep)
    self.dependency = dep;
end
```

### 4. 表内存管理

```lua
-- 在 Reset 方法中清理表而不是创建新表
function MyMixin:Reset()
    wipe(self.data);      -- 复用表
    -- 不要使用 self.data = {}，这会创建新表
end
```

## 相关模式

- [帧池模式](frame-pool.md) - Mixin 通常与帧池配合使用
- [EventRegistry 系统](event-registry.md) - 结合事件系统实现松耦合

## API 参考

| 函数 | 说明 |
|------|------|
| `CreateFromMixins(...)` | 从多个 Mixin 创建新对象 |
| `Mixin(dest, src)` | 将 src 混入 dest（原地修改） |

## 参考链接

- [Warcraft Wiki - Mixin](https://warcraft.wiki.gg/wiki/Mixin)
- [wow-ui-source - FrameXML Mixins](https://github.com/Gethe/wow-ui-source)
