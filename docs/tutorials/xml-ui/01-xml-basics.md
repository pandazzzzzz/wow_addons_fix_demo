# XML UI 基础

> 魔兽世界 XML 界面开发入门
> 权威来源: [Warcraft Wiki - XML](https://warcraft.wiki.gg/wiki/XML)

## 概述

魔兽世界支持使用 XML 定义 UI 布局，配合 Lua 脚本实现交互。XML 方式适合复杂的布局定义。

## 基本结构

### XML 文件

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.blizzard.com/wow/ui/
    ..\FrameXML\UI.xsd">

    <!-- 脚本文件 -->
    <Script file="MyFrame.lua"/>

    <!-- 帧定义 -->
    <Frame name="MyFrame">
        <!-- 帧内容 -->
    </Frame>
</Ui>
```

### TOC 加载

```toc
MyUI.xml
MyUI.lua
```

## 基础元素

### Frame（帧）

最基础的 UI 容器：

```xml
<Frame name="MyFrame" parent="UIParent">
    <Size x="200" y="100"/>
    <Anchors>
        <Anchor point="CENTER"/>
    </Anchors>
    <Layers>
        <Layer level="BACKGROUND">
            <Texture file="Interface\DialogFrame\UI-DialogBox-Background"/>
        </Layer>
    </Layers>
    <Scripts>
        <OnLoad>print("Frame loaded")</OnLoad>
    </Scripts>
</Frame>
```

### Button（按钮）

```xml
<Button name="MyButton" inherits="UIPanelButtonTemplate">
    <Size x="100" y="30"/>
    <Anchors>
        <Anchor point="CENTER"/>
    </Anchors>
    <Scripts>
        <OnClick>print("Clicked!")</OnClick>
    </Scripts>
</Button>
```

### EditBox（输入框）

```xml
<EditBox name="MyEditBox" inherits="InputBoxTemplate">
    <Size x="200" y="30"/>
    <Anchors>
        <Anchor point="CENTER"/>
    </Anchors>
    <Scripts>
        <OnEnterPressed>
            print(self:GetText())
            self:ClearFocus()
        </OnEnterPressed>
    </Scripts>
</EditBox>
```

## 布局

### 尺寸

```xml
<!-- 固定尺寸 -->
<Size x="200" y="100"/>

<!-- 相对尺寸（需要设置 Anchor） -->
<Size x="200" y="100"/>
<Anchors>
    <Anchor point="TOPLEFT" relativePoint="TOPLEFT">
        <Offset x="10" y="-10"/>
    </Anchor>
</Anchors>
```

### 锚点

```xml
<Anchors>
    <!-- 简单居中 -->
    <Anchor point="CENTER"/>

    <!-- 相对于父元素 -->
    <Anchor point="TOPLEFT" relativePoint="TOPLEFT">
        <Offset x="10" y="-10"/>
    </Anchor>

    <!-- 相对于其他元素 -->
    <Anchor point="TOPLEFT" relativeTo="OtherFrame" relativePoint="BOTTOMLEFT">
        <Offset x="0" y="-5"/>
    </Anchor>

    <!-- 多锚点拉伸 -->
    <Anchor point="TOPLEFT"/>
    <Anchor point="BOTTOMRIGHT" relativePoint="BOTTOMRIGHT">
        <Offset x="-10" y="10"/>
    </Anchor>
</Anchors>
```

### Layers（层级）

```xml
<Layers>
    <!-- BACKGROUND - 最底层 -->
    <Layer level="BACKGROUND">
        <Texture>
            <Size x="200" y="100"/>
            <Color r="0" g="0" b="0" a="0.5"/>
        </Texture>
    </Layer>

    <!-- BORDER - 边框 -->
    <Layer level="BORDER">
        <Texture file="Interface\DialogFrame\UI-DialogBox-Border"/>
    </Layer>

    <!-- ARTWORK - 主要内容 -->
    <Layer level="ARTWORK">
        <FontString text="Title" font="GameFontNormal"/>
    </Layer>

    <!-- OVERLAY - 覆盖层 -->
    <Layer level="OVERLAY">
        <Texture file="Interface\Buttons\UI-Listbox-Highlight"/>
    </Layer>

    <!-- HIGHLIGHT - 高亮 -->
    <Layer level="HIGHLIGHT">
        <Texture file="Interface\Buttons\ButtonHilight-Square"/>
    </Layer>
</Layers>
```

## 继承与模板

### 虚拟模板

```xml
<!-- virtual="true" 表示这是模板，不会创建实例 -->
<Frame name="MyButtonTemplate" virtual="true">
    <Size x="100" y="30"/>
    <Layers>
        <Layer level="BACKGROUND">
            <Texture>
                <Color r="0.2" g="0.2" b="0.2" a="1"/>
            </Texture>
        </Layer>
    </Layers>
</Frame>

<!-- 使用模板 -->
<Button name="MyButton" inherits="MyButtonTemplate">
    <Anchors>
        <Anchor point="CENTER"/>
    </Anchors>
</Button>
```

### 多重继承

```xml
<Button name="MySpecialButton" inherits="MyButtonTemplate, UIPanelButtonTemplate">
</Button>
```

## Mixin 配合

### XML 定义 Mixin

```xml
<Frame name="MyFrame" mixin="MyFrameMixin">
    <Scripts>
        <OnLoad method="OnLoad"/>
        <OnEvent method="OnEvent"/>
    </Scripts>
</Frame>
```

### Lua 定义 Mixin

```lua
MyFrameMixin = {}

function MyFrameMixin:OnLoad()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:InitWidgets()
end

function MyFrameMixin:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:Refresh()
    end
end

function MyFrameMixin:InitWidgets()
    -- 访问子元素（通过 $parent 前缀）
    self.Title:SetText("My Frame")
end

function MyFrameMixin:Refresh()
    -- 刷新逻辑
end
```

### 子元素访问

```xml
<Frame name="MyFrame" mixin="MyFrameMixin">
    <Layers>
        <Layer level="ARTWORK">
            <!-- 使用 $parent 前缀自动关联 -->
            <FontString name="$parentTitle" text="Title" font="GameFontNormal">
                <Anchors>
                    <Anchor point="TOP">
                        <Offset y="-10"/>
                    </Anchor>
                </Anchors>
            </FontString>
        </Layer>
    </Layers>
    <Frames>
        <!-- 子帧 -->
        <Button name="$parentCloseButton" inherits="UIPanelCloseButton">
            <Anchors>
                <Anchor point="TOPRIGHT">
                    <Offset x="2" y="-2"/>
                </Anchor>
            </Anchors>
        </Button>
    </Frames>
</Frame>
```

```lua
-- 在 Lua 中访问
function MyFrameMixin:InitWidgets()
    -- 自动生成的全局变量（不推荐）
    -- MyFrameTitle:SetText("Title")

    -- 通过 self 访问（推荐）
    self.Title:SetText("Title")
    self.CloseButton:SetScript("OnClick", function()
        self:Hide()
    end)
end
```

## 脚本事件

### 常用事件

```xml
<Scripts>
    <!-- 生命周期 -->
    <OnLoad>self:OnLoad()</OnLoad>
    <OnShow>self:OnShow()</OnShow>
    <OnHide>self:OnHide()</OnHide>

    <!-- 事件 -->
    <OnEvent>self:OnEvent(event, ...)</OnEvent>

    <!-- 鼠标 -->
    <OnEnter>self:OnEnter()</OnEnter>
    <OnLeave>self:OnLeave()</OnLeave>
    <OnClick>self:OnClick()</OnClick>
    <OnDoubleClick>self:OnDoubleClick()</OnDoubleClick>

    <!-- 拖拽 -->
    <OnDragStart>self:StartMoving()</OnDragStart>
    <OnDragStop>self:StopMovingOrSizing()</OnDragStop>

    <!-- 更新 -->
    <OnUpdate>self:OnUpdate(elapsed)</OnUpdate>

    <!-- 键盘 -->
    <OnKeyDown>self:OnKeyDown(key)</OnKeyDown>
    <OnKeyUp>self:OnKeyUp(key)</OnKeyUp>

    <!-- 输入 -->
    <OnTextChanged>self:OnTextChanged()</OnTextChanged>
    <OnEnterPressed>self:OnEnterPressed()</OnEnterPressed>
</Scripts>
```

### 内联 vs 外部

```xml
<!-- 方式1：内联脚本 -->
<Button>
    <Scripts>
        <OnClick>print("Clicked")</OnClick>
    </Scripts>
</Button>

<!-- 方式2：方法调用 -->
<Button mixin="MyButtonMixin">
    <Scripts>
        <OnClick method="OnClick"/>
    </Scripts>
</Button>

<!-- 方式3：Lua 中注册 -->
```
```lua
-- Lua 中设置
MyButton:SetScript("OnClick", function(self)
    print("Clicked")
end)
```

## 动态创建

通常推荐在 Lua 中动态创建 UI：

```lua
local function CreateMyFrame()
    local frame = CreateFrame("Frame", "MyDynamicFrame", UIParent)
    frame:SetSize(200, 100)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

    -- 标题
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Dynamic Frame")

    -- 关闭按钮
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 2, -2)

    return frame
end
```

## 完整示例

### MyUI.xml

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
    <Script file="MyUI.lua"/>

    <!-- 主帧模板 -->
    <Frame name="MyMainFrameTemplate" virtual="true" mixin="MyMainFrameMixin">
        <Size x="300" y="200"/>
        <Layers>
            <Layer level="BACKGROUND">
                <Texture>
                    <Color r="0.1" g="0.1" b="0.1" a="0.9"/>
                </Texture>
            </Layer>
            <Layer level="ARTWORK">
                <FontString name="$parentTitle" font="GameFontNormalLarge">
                    <Anchors>
                        <Anchor point="TOP">
                            <Offset y="-15"/>
                        </Anchor>
                    </Anchors>
                </FontString>
            </Layer>
        </Layers>
        <Frames>
            <Button name="$parentCloseButton" inherits="UIPanelCloseButton">
                <Anchors>
                    <Anchor point="TOPRIGHT">
                        <Offset x="2" y="-2"/>
                    </Anchor>
                </Anchors>
            </Button>
        </Frames>
        <Scripts>
            <OnLoad method="OnLoad"/>
            <OnShow method="OnShow"/>
            <OnHide method="OnHide"/>
        </Scripts>
    </Frame>

    <!-- 实例 -->
    <Frame name="MyMainFrame" inherits="MyMainFrameTemplate" parent="UIParent" hidden="true">
        <Anchors>
            <Anchor point="CENTER"/>
        </Anchors>
    </Frame>
</Ui>
```

### MyUI.lua

```lua
MyMainFrameMixin = {}

function MyMainFrameMixin:OnLoad()
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true)
    self:SetClampedToScreen(true)

    self.Title:SetText("My UI")
    self.CloseButton:SetScript("OnClick", function()
        self:Hide()
    end)
end

function MyMainFrameMixin:OnShow()
    self:Refresh()
end

function MyMainFrameMixin:OnHide()
    -- 保存位置等
end

function MyMainFrameMixin:Refresh()
    -- 刷新内容
end

-- Slash 命令
SLASH_MYUI1 = "/myui"
SlashCmdList["MYUI"] = function()
    if MyMainFrame:IsShown() then
        MyMainFrame:Hide()
    else
        MyMainFrame:Show()
    end
end
```

## 相关链接

- [Warcraft Wiki - XML](https://warcraft.wiki.gg/wiki/XML)
- [Warcraft Wiki - XML elements](https://warcraft.wiki.gg/wiki/XML_elements)
- [Mixin模式](../patterns/mixin-pattern.md)
- [wow-ui-source](https://github.com/Gethe/wow-ui-source)
