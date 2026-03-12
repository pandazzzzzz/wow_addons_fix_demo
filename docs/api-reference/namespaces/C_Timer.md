# C_Timer 命名空间

> 定时器 API 参考
> 权威来源: [Warcraft Wiki - Timer](https://warcraft.wiki.gg/wiki/Category:API_functions/Timers)

## 概述

C_Timer 提供定时执行代码的功能，是传统 `OnUpdate` 脚本的现代替代方案。

> **注意**: `C_Timer.After` 是原生 API，但 `NewTimer` 和 `NewTicker` 是 FrameXML 定义的辅助函数（位于 `FrameXML/Timer.lua`），非原生 C API。

## 基本用法

### After - 延迟执行

```lua
-- 延迟执行一次
C_Timer.After(1.0, function()
    print("1秒后执行")
end)

-- 带参数
C_Timer.After(0.5, function()
    MyAddon:DoSomething()
end)
```

### NewTimer - 可取消定时器

```lua
-- 创建定时器
local timer = C_Timer.NewTimer(5.0, function()
    print("5秒后执行")
end)

-- 取消定时器
timer:Cancel()

-- 检查是否已取消
local cancelled = timer:IsCancelled()
```

### NewTicker - 重复定时器

```lua
-- 创建重复执行的定时器
local ticker = C_Timer.NewTicker(1.0, function()
    print("每秒执行一次")
end)

-- 带回调停止
local ticker = C_Timer.NewTicker(0.5, function(self)
    if someCondition then
        self:Cancel()  -- 满足条件后停止
    end
end)

-- 取消重复定时器
ticker:Cancel()
```

## 返回对象

### Timer 对象

```lua
local timer = C_Timer.NewTimer(1.0, callback)

-- 方法
timer:Cancel()           -- 取消定时器
timer:IsCancelled()      -- 检查是否已取消
```

### Ticker 对象

```lua
local ticker = C_Timer.NewTicker(1.0, callback)

-- 方法
ticker:Cancel()          -- 取消
ticker:IsCancelled()     -- 检查是否取消
```

## 实际案例

### 延迟初始化

```lua
local MyAddon = {}

function MyAddon:OnLoad()
    -- 延迟初始化，等待其他插件加载
    C_Timer.After(1.0, function()
        self:Initialize()
    end)
end

function MyAddon:Initialize()
    -- 现在其他插件都已加载
    if TomTom then
        self.tomTomAvailable = true
    end
end
```

### 防抖（Debounce）

```lua
local MyList = {
    updateQueued = false,
}

function MyList:RequestUpdate()
    if self.updateQueued then return end

    self.updateQueued = true
    C_Timer.After(0.1, function()
        self.updateQueued = false
        self:UpdateList()
    end)
end

-- 高频调用时只执行最后一次更新
MyList:RequestUpdate()
MyList:RequestUpdate()
MyList:RequestUpdate()  -- 只会执行一次 UpdateList
```

### 动画效果

```lua
local function FadeIn(frame, duration)
    frame:SetAlpha(0)
    frame:Show()

    local steps = 20
    local stepTime = duration / steps
    local alphaStep = 1.0 / steps
    local currentStep = 0

    local ticker = C_Timer.NewTicker(stepTime, function(self)
        currentStep = currentStep + 1
        frame:SetAlpha(currentStep * alphaStep)

        if currentStep >= steps then
            self:Cancel()
        end
    end)

    return ticker
end
```

### 倒计时

```lua
local function StartCountdown(seconds, callback)
    local remaining = seconds

    local ticker = C_Timer.NewTicker(1.0, function(self)
        remaining = remaining - 1

        if remaining > 0 then
            print(remaining .. "...")
        else
            self:Cancel()
            if callback then callback() end
        end
    end)

    print(seconds .. "...")
    return ticker
end

-- 使用
StartCountdown(5, function()
    print("Go!")
end)
```

### 超时处理

```lua
local function FetchDataWithTimeout(timeout)
    local completed = false
    local timer

    -- 发起请求
    FetchDataFromServer(function(data)
        if not completed then
            completed = true
            timer:Cancel()
            ProcessData(data)
        end
    end)

    -- 设置超时
    timer = C_Timer.After(timeout, function()
        if not completed then
            completed = true
            print("Request timed out!")
        end
    end)
end
```

## 性能考虑

### 避免过多定时器

```lua
-- 错误：为每个项目创建定时器
for i, item in ipairs(items) do
    C_Timer.After(i * 0.1, function()
        UpdateItem(item)
    end)
end

-- 正确：使用一个 Ticker 批量处理
local index = 1
local ticker = C_Timer.NewTicker(0.1, function(self)
    if index > #items then
        self:Cancel()
        return
    end
    UpdateItem(items[index])
    index = index + 1
end)
```

### 定时器泄露

```lua
-- 潜在问题：定时器未取消
local MyFrame = CreateFrame("Frame")

MyFrame:SetScript("OnShow", function()
    C_Timer.After(5, function()
        -- 如果帧在5秒内隐藏了，这个回调仍会执行
        MyFrame:Refresh()
    end)
end)

-- 正确：保存 timer 引用以便取消
MyFrame.timer = nil

MyFrame:SetScript("OnShow", function()
    MyFrame.timer = C_Timer.NewTimer(5, function()
        MyFrame.timer = nil
        if MyFrame:IsShown() then
            MyFrame:Refresh()
        end
    end)
end)

MyFrame:SetScript("OnHide", function()
    if MyFrame.timer then
        MyFrame.timer:Cancel()
        MyFrame.timer = nil
    end
end)
```

## 与 OnUpdate 对比

### OnUpdate 方式

```lua
local frame = CreateFrame("Frame")
local elapsed = 0
local target = 5.0

frame:SetScript("OnUpdate", function(self, delta)
    elapsed = elapsed + delta
    if elapsed >= target then
        elapsed = 0
        print("5秒钟到了")
    end
end)
```

### C_Timer 方式

```lua
-- 更简洁，不占用 OnUpdate 脚本
C_Timer.NewTicker(5.0, function()
    print("5秒钟到了")
end)
```

## 相关 API

```lua
-- 获取精确时间（秒）
local time = GetTimePreciseSec()

-- 获取游戏启动后的时间（秒）
local time = GetTime()

-- 获取服务器时间
local time = GetServerTime()

-- 获取本地时间表
local timeTable = C_DateAndTime.GetCurrentCalendarTime()
```

## 相关链接

- [Warcraft Wiki - Timer](https://warcraft.wiki.gg/wiki/Category:API_functions/Timers)
- [帧池模式](../../tutorials/patterns/frame-pool.md)
- [事件系统概述](../events/README.md)
