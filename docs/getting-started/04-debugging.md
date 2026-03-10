# 调试技巧

> 魔兽世界插件开发中的常用调试方法

## 游戏内置调试

### 显示错误

启用 Lua 错误显示：

```
/console scriptErrors 1
```

或通过界面：
- `Esc` → 选项 → 帮助 → 显示 Lua 错误

### 控制台调试

```
/console scriptProfile 1     # 启用性能分析
/console taintLog 1          # 启用污染日志
```

## print 调试

### 基本用法

```lua
print("message")                    -- 简单消息
print("value:", variable)           -- 多个值
print(type(obj), obj ~= nil)        -- 类型检查
```

### 格式化输出

```lua
print(string.format("Quest %d: %s", questID, title))
print(string.format("Position: (%.2f, %.2f)", x, y))
```

### 带颜色输出

```lua
-- 使用颜色代码
print("|cFF00FF00绿色|r |cFFFF0000红色|r")

-- 封装函数
local function PrintColor(msg, colorHex)
    print("|c" .. colorHex .. msg .. "|r")
end

PrintColor("Success!", "FF00FF00")
PrintColor("Error!", "FFFF0000")
```

### 调试工具函数

```lua
local Debug = {
    enabled = true
}

function Debug:Print(...)
    if not self.enabled then return end
    print("|cFF00FFFF[Debug]|r", ...)
end

function Debug:DumpTable(t, indent)
    if not self.enabled then return end
    indent = indent or ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. k .. ":")
            self:DumpTable(v, indent .. "  ")
        else
            print(indent .. k .. ":", v)
        end
    end
end

function Debug:StackTrace()
    print(debug.traceback())
end

-- 使用
Debug:Print("Loading quest", questID)
Debug:DumpTable(questInfo)
```

## DevTools 插件

### 安装

安装 Blizzard Development Tools 或第三方 DevTools 插件。

### 使用方法

```lua
-- 导出表
DevTools_Dump({ key = "value", nested = { a = 1, b = 2 } })

-- 运行代码片段
DevTools_RunSnippet("print(GetTime(), UnitName('player'))")

-- 检查表达式
DevTools_TableSize(largeTable)
```

## 错误处理

### pcall 安全调用

```lua
-- 安全调用函数
local success, result = pcall(function()
    return SomeRiskyFunction(arg1, arg2)
end)

if not success then
    print("Error:", result)
end
```

### xpcall 带堆栈

```lua
-- 获取完整错误堆栈
local function errorhandler(err)
    return debug.traceback(err, 2)
end

local success, result = xpcall(function()
    return ProcessQuest(questID)
end, errorhandler)

if not success then
    print("Error occurred:")
    print(result)  -- 包含堆栈信息
end
```

### 全局错误捕获

```lua
-- 保存原始函数
local originalErrorHandler = geterrorhandler()

-- 设置自定义错误处理器
seterrorhandler(function(err)
    print("|cFFFF0000Addon Error:|r", err)
    -- 调用原始处理器
    return originalErrorHandler(err)
end)
```

## 性能分析

### 计时

```lua
-- 简单计时
local startTime = GetTimePreciseSec()
-- ... 代码 ...
local elapsed = GetTimePreciseSec() - startTime
print(string.format("Took %.4f seconds", elapsed))

-- 计时工具
local Timer = {}

function Timer:Start(name)
    self[name] = GetTimePreciseSec()
end

function Timer:Stop(name)
    local elapsed = GetTimePreciseSec() - self[name]
    print(string.format("[Timer] %s: %.4fs", name, elapsed))
    return elapsed
end

Timer:Start("LoadQuests")
LoadAllQuests()
Timer:Stop("LoadQuests")
```

### 内存分析

```lua
-- 内存使用
local beforeMem = GetAddOnMemoryUsage("MyAddon")
-- ... 代码 ...
local afterMem = GetAddOnMemoryUsage("MyAddon")
print(string.format("Memory changed: %.2f KB", afterMem - beforeMem))

-- 强制垃圾回收后测量
collectgarbage()
local mem = GetAddOnMemoryUsage("MyAddon")
print(string.format("Current memory: %.2f KB", mem))
```

### 更新频率分析

```lua
-- 监控 OnUpdate 性能
local frame = CreateFrame("Frame")
local frameCount = 0
local totalTime = 0
local lastTime = GetTime()

frame:SetScript("OnUpdate", function(self, elapsed)
    totalTime = totalTime + elapsed
    frameCount = frameCount + 1

    if totalTime > 1 then
        print(string.format("OnUpdate: %.2f ms/frame",
            (totalTime / frameCount) * 1000))
        frameCount = 0
        totalTime = 0
    end
end)
```

## 污染检测

### 检查污染

```lua
-- 检查变量是否被污染
print(issecurevariable("UNIT_TOKEN_TABLE"))

-- 检查表是否被污染
local t = {}
print(issecurevariable(t, "key"))
```

### 避免污染

```lua
-- 错误：污染全局命名空间
function MyFunction() end  -- 全局函数

-- 正确：使用本地命名空间
local MyAddon = {}
MyAddon.MyFunction = function() end

-- 或使用 local
local function myLocalFunction() end
```

## 日志记录

### 简单日志系统

```lua
local Logger = {
    logLevel = 2,  -- 1: ERROR, 2: WARN, 3: INFO, 4: DEBUG
    logFile = {},
}

local LEVELS = { ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4 }
local LEVEL_COLORS = { ERROR = "FFFF0000", WARN = "FFFFFF00", INFO = "FF00FF00", DEBUG = "FF808080" }

function Logger:Log(level, msg, ...)
    local levelValue = LEVELS[level]
    if levelValue > self.logLevel then return end

    local formatted = string.format(msg, ...)
    local timestamp = date("%H:%M:%S")
    local logEntry = string.format("[%s] [%s] %s", timestamp, level, formatted)

    table.insert(self.logFile, logEntry)
    print("|c" .. LEVEL_COLORS[level] .. logEntry .. "|r")
end

function Logger:Error(msg, ...) self:Log("ERROR", msg, ...) end
function Logger:Warn(msg, ...)  self:Log("WARN", msg, ...)  end
function Logger:Info(msg, ...)  self:Log("INFO", msg, ...)  end
function Logger:Debug(msg, ...) self:Log("DEBUG", msg, ...) end

function Logger:Export()
    return table.concat(self.logFile, "\n")
end

-- 使用
Logger:Info("Addon loaded")
Logger:Debug("Processing quest %d", questID)
Logger:Error("Failed to load data: %s", err)
```

## 事件追踪

```lua
-- 追踪所有事件
local EventTracker = CreateFrame("Frame")
EventTracker:RegisterAllEvents()

EventTracker:SetScript("OnEvent", function(self, event, ...)
    if EventTracker.enabled then
        print("[Event]", event, ...)
    end
end)

EventTracker.enabled = false

-- Slash 命令控制
SLASH_EVENTRACK1 = "/eventrack"
SlashCmdList["EVENTRACK"] = function(msg)
    EventTracker.enabled = not EventTracker.enabled
    print("Event tracking:", EventTracker.enabled and "ON" or "OFF")
end
```

## 断点模拟

```lua
-- 条件断点
local function conditionalBreak(condition, message)
    if condition then
        print("|cFFFF0000[BREAKPOINT]|r", message)
        -- 暂停等待输入
        debug.debug()
    end
end

-- 使用
conditionalBreak(questID == 12345, "Quest 12345 reached")
```

## 常见问题

### 问题：事件不触发

```lua
-- 检查事件是否注册
print(frame:IsEventRegistered("QUEST_LOG_UPDATE"))

-- 列出所有注册的事件
for event in pairs(frame.registeredEvents or {}) do
    print("Registered:", event)
end
```

### 问题：变量为 nil

```lua
-- 检查变量链
if questInfo and questInfo.reward and questInfo.reward.item then
    print("Item found:", questInfo.reward.item)
else
    print("Missing data at:", questInfo and "reward" or "questInfo")
end
```

### 问题：帧未显示

```lua
-- 调试帧状态
local function DebugFrame(frame, name)
    print(string.format("[%s] Shown: %s, Visible: %s, Alpha: %.2f",
        name,
        frame:IsShown() and "Yes" or "No",
        frame:IsVisible() and "Yes" or "No",
        frame:GetAlpha()))
    print(string.format("[%s] Size: %.0fx%.0f, Point: %s",
        name,
        frame:GetWidth(), frame:GetHeight(),
        frame:GetPoint() or "none"))
end
```

## 相关链接

- [Warcraft Wiki - Debugging](https://warcraft.wiki.gg/wiki/Debugging)
- [Warcraft Wiki - taint](https://warcraft.wiki.gg/wiki/Taint)
- [开发环境搭建](01-environment-setup.md)
