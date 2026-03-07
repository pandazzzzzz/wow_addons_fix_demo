# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

魔兽世界插件开发项目，用于正式服（Retail）版本的插件开发与维护。

## Development Commands

- `/wqt debug` - Toggle debug mode (示例，具体命令因插件而异)

## 魔兽世界插件开发规范

### TOC文件结构

```
## Interface: 100207        # 正式服版本号
## Title: Addon Name
## Author: Author Name
## Version: 1.0.0
## SavedVariables: AddonDB
## OptionalDeps: Ace3, LibStub

File1.lua
File2.xml
```

### 核心架构模式

**帧池（Frame Pool）**
```lua
-- 创建帧池优化内存复用
local pool = CreateFramePool("BUTTON", parent, "Template", resetFunc)
local frame = pool:Acquire()
pool:Release(frame)
```

**Mixin模式**
```lua
MyFrameMixin = {}

function MyFrameMixin:OnLoad()
    -- 初始化逻辑
end

function MyFrameMixin:OnEvent(event, ...)
    -- 事件处理
end
```

**事件注册**
```lua
-- 传统事件
frame:RegisterEvent("EVENT_NAME")
frame:SetScript("OnEvent", function(self, event, ...) end)

-- EventRegistry回调（推荐）
EventRegistry:RegisterCallback("Event.Name", callback, owner)
```

### 常用API命名空间

- `C_QuestLog` - 任务相关
- `C_Map` - 地图相关
- `C_Timer` - 定时器
- `C_SuperTrack` - 超级追踪
- `C_CVar` - CVar设置

### XML模板结构

```xml
<Frame name="MyTemplate" virtual="true">
    <Scripts>
        <OnLoad>self:OnLoad()</OnLoad>
        <OnEvent>self:OnEvent(event, ...)</OnEvent>
    </Scripts>
</Frame>
```

### SavedVariables

在TOC中声明的变量会持久化到 `WTF/Account/账号名/SavedVariables/插件名.lua`

### 开发注意事项

1. **战斗锁定** - 部分操作无法在战斗中进行
2. **安全代码** - `secure`属性的限制
3. **版本兼容** - 使用 `select(4, GetBuildInfo())` 检测版本
4. **内存优化** - 避免在OnUpdate中创建表，使用帧池
5. **事件节流** - 频繁触发的事件需要去重处理

### 第三方库

- **LibStub** - 库管理
- **AceAddon-3.0** - 插件框架
- **AceDB-3.0** - 数据库管理
- **CallbackHandler-1.0** - 回调系统
