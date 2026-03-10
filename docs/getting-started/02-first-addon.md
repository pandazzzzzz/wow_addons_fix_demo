# 第一个插件

> 从模板创建你的第一个魔兽世界插件

## 创建插件

### 1. 复制模板

使用项目中的基础模板：

```bash
# 进入项目目录
cd N:\code-temp\addon_retail

# 复制模板
cp -r templates/basic-addon addons/MyFirstAddon
```

### 2. 重命名文件

```
MyFirstAddon/
├── basic-addon.toc  → MyFirstAddon.toc
└── main.lua         → MyFirstAddon.lua
```

### 3. 修改 TOC 文件

编辑 `MyFirstAddon.toc`:

```toc
## Interface: 120001
## Title: My First Addon
## Title-zhCN: 我的第一个插件
## Notes: A simple addon to get started
## Author: YourName
## Version: 1.0.0
## Category: Miscellaneous

MyFirstAddon.lua
```

### 4. 编写主文件

编辑 `MyFirstAddon.lua`:

```lua
-- 插件命名空间
local ADDON_NAME, addon = ...

-- 创建主帧
local frame = CreateFrame("Frame")

-- 注册事件
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- 事件处理
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == ADDON_NAME then
            print("|cFF00FF00My First Addon|r loaded!")
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        print("Welcome to Azeroth!")
    end
end)

-- 注册 slash 命令
SLASH_MWFIRST1 = "/myfirst"
SlashCmdList["MWFIRST"] = function(msg)
    print("My First Addon says: " .. (msg ~= "" and msg or "Hello!"))
end
```

## 测试插件

### 1. 安装插件

创建符号链接到游戏目录：

```powershell
New-Item -ItemType SymbolicLink -Path "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\MyFirstAddon" -Target "N:\code-temp\addon_retail\addons\MyFirstAddon"
```

### 2. 启动游戏

1. 启动魔兽世界（Retail）
2. 在角色选择界面，点击左下角的"插件"按钮
3. 确认"My First Addon"已启用

### 3. 验证运行

进入游戏后：
1. 查看聊天框是否显示插件加载消息
2. 输入 `/myfirst` 测试命令
3. 输入 `/myfirst Hello World` 测试参数

## 添加功能

### 创建配置界面

```lua
-- 添加设置面板
local function CreateSettingsPanel()
    local panel = CreateFrame("Frame", "MyFirstAddonSettingsPanel")
    panel.name = "My First Addon"

    -- 标题
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("My First Addon Settings")

    -- 复选框示例
    local checkbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    checkbox.Text:SetText("Enable Feature")
    checkbox:SetChecked(true)
    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        print("Feature enabled:", checked)
    end)

    -- 注册到设置界面
    InterfaceOptions_AddCategory(panel)
end

-- 在插件加载时创建
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == ADDON_NAME then
            CreateSettingsPanel()
        end
    end
end)
```

### 添加数据持久化

修改 TOC:

```toc
## SavedVariables: MyFirstAddonDB
```

添加保存逻辑:

```lua
-- 默认配置
local DEFAULTS = {
    enabled = true,
    message = "Hello World!"
}

-- 初始化数据库
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == ADDON_NAME then
            -- 合并默认值
            MyFirstAddonDB = MyFirstAddonDB or {}
            for key, value in pairs(DEFAULTS) do
                if MyFirstAddonDB[key] == nil then
                    MyFirstAddonDB[key] = value
                end
            end
            addon.db = MyFirstAddonDB
            print("Settings loaded:", addon.db.message)
        end
    end
end)
```

### 添加小地图按钮

```lua
-- 创建小地图按钮
local function CreateMinimapButton()
    local button = CreateFrame("Button", "MyFirstAddonMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)

    -- 设置图标
    button:SetNormalTexture("Interface/Icons/INV_Misc_QuestionMark")

    -- 设置位置
    button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -5, 5)

    -- 拖拽功能
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    -- 点击事件
    button:SetScript("OnClick", function(self)
        print("Minimap button clicked!")
    end)

    return button
end
```

## 使用 Ace3 框架

对于更复杂的插件，推荐使用 Ace3 框架：

```lua
-- 使用 Ace3 模板后的简化代码
local MyFirstAddon = LibStub("AceAddon-3.0"):NewAddon("MyFirstAddon", "AceConsole-3.0")

function MyFirstAddon:OnInitialize()
    -- 初始化数据库
    self.db = LibStub("AceDB-3.0"):New("MyFirstAddonDB", {
        profile = {
            enabled = true,
            message = "Hello World!"
        }
    })

    -- 注册命令
    self:RegisterChatCommand("myfirst", "SlashCommand")
end

function MyFirstAddon:OnEnable()
    self:Print("Addon enabled!")
end

function MyFirstAddon:SlashCommand(msg)
    self:Print("Command received: " .. msg)
end
```

参考 [Ace3 框架入门](../libraries/ace3/README.md) 了解更多。

## 项目结构

添加更多文件后的完整结构：

```
MyFirstAddon/
├── MyFirstAddon.toc
├── MyFirstAddon.lua      # 主入口
├── Config.lua            # 配置面板
├── Minimap.lua           # 小地图按钮
├── Loca/
│   ├── enUS.lua          # 英语
│   └── zhCN.lua          # 中文
└── Libs/
    └── (第三方库)
```

更新 TOC:

```toc
## Interface: 120001
## Title: My First Addon
## SavedVariables: MyFirstAddonDB

Libs\LibStub\LibStub.lua

Loca\enUS.lua
Loca\zhCN.lua

MyFirstAddon.lua
Config.lua
Minimap.lua
```

## 下一步

- [TOC 文件详解](03-toc-format.md) - 了解更多配置选项
- [Mixin 模式](../tutorials/patterns/mixin-pattern.md) - 学习面向对象编程
- [帧池模式](../tutorials/patterns/frame-pool.md) - 性能优化技巧

## 相关链接

- [开发环境搭建](01-environment-setup.md)
- [Ace3 框架入门](../libraries/ace3/README.md)
- [Warcraft Wiki - Getting Started](https://warcraft.wiki.gg/wiki/Getting_started_with_addon_programming)
