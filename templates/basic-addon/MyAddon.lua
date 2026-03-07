-- ============================================================================
-- MyAddon - Basic Addon Template
-- ============================================================================
-- 获取插件名和私有表
local addonName, addon = ...

-- 全局访问点（可选）
MyAddon = addon

-- ============================================================================
-- 局部变量缓存（性能优化）
-- ============================================================================
local _G = _G
local pairs = pairs
local ipairs = ipairs
local print = print
local CreateFrame = CreateFrame
local RegisterEvent = RegisterEvent
local RegisterUnitEvent = RegisterUnitEvent

-- ============================================================================
-- 默认配置
-- ============================================================================
local defaults = {
    enabled = true,
    showWelcome = true,
    debug = false,
}

-- ============================================================================
-- 初始化函数
-- ============================================================================
function addon:Initialize()
    -- 初始化数据库
    if not MyAddonDB then
        MyAddonDB = {}
    end

    -- 合并默认值
    for key, value in pairs(defaults) do
        if MyAddonDB[key] == nil then
            MyAddonDB[key] = value
        end
    end

    self.db = MyAddonDB

    -- 显示欢迎消息
    if self.db.showWelcome then
        print("|cFF00FF00MyAddon|r loaded successfully!")
    end

    -- 注册其他事件
    self:RegisterEvents()

    if self.db.debug then
        print("|cFFFFFF00MyAddon|r Debug mode enabled")
    end
end

-- ============================================================================
-- 事件注册
-- ============================================================================
function addon:RegisterEvents()
    local frame = self.frame

    -- 常用事件
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("QUEST_LOG_UPDATE")
    frame:RegisterEvent("BAG_UPDATE")

    -- 单位事件（只监听玩家）
    frame:RegisterUnitEvent("UNIT_HEALTH", "player")
end

-- ============================================================================
-- 事件处理
-- ============================================================================
local EventHandlers = {
    ["ADDON_LOADED"] = function(self, name)
        if name == addonName then
            addon:Initialize()
        end
    end,

    ["PLAYER_LOGIN"] = function(self)
        -- 玩家登录完成后的处理
        addon:OnLogin()
    end,

    ["PLAYER_ENTERING_WORLD"] = function(self, isLogin, isReload)
        -- 进入世界/切换区域
        if addon.db.debug then
            print("|cFFFFFF00MyAddon|r PLAYER_ENTERING_WORLD:", isLogin, isReload)
        end
    end,

    ["QUEST_LOG_UPDATE"] = function(self)
        -- 任务日志更新
        addon:OnQuestUpdate()
    end,

    ["BAG_UPDATE"] = function(self, bagID)
        -- 背包更新
        if addon.db.debug then
            print("|cFFFFFF00MyAddon|r BAG_UPDATE:", bagID)
        end
    end,

    ["UNIT_HEALTH"] = function(self, unit)
        -- 单位生命值变化
        if unit == "player" then
            addon:OnPlayerHealthChanged()
        end
    end,
}

function addon:OnLogin()
    -- 登录后初始化
    if self.db.debug then
        print("|cFFFFFF00MyAddon|r Player logged in")
    end
end

function addon:OnQuestUpdate()
    -- 任务更新处理
    if self.db.debug then
        print("|cFFFFFF00MyAddon|r Quest log updated")
    end
end

function addon:OnPlayerHealthChanged()
    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")
    local percent = (health / maxHealth) * 100

    if self.db.debug then
        print("|cFFFFFF00MyAddon|r Health:", health, "/", maxHealth, "(", percent, "%)")
    end
end

-- ============================================================================
-- 主事件框架
-- ============================================================================
local frame = CreateFrame("Frame")
addon.frame = frame

frame:SetScript("OnEvent", function(self, event, ...)
    local handler = EventHandlers[event]
    if handler then
        handler(self, ...)
    end
end)

-- 注册加载事件
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

-- ============================================================================
-- 斜杠命令
-- ============================================================================
SLASH_MYADDON1 = "/myaddon"
SLASH_MYADDON2 = "/ma"

SlashCmdList["MYADDON"] = function(msg)
    msg = msg:lower():trim()

    if msg == "debug" then
        addon.db.debug = not addon.db.debug
        print("|cFF00FF00MyAddon|r Debug mode:", addon.db.debug and "ON" or "OFF")

    elseif msg == "reset" then
        MyAddonDB = nil
        addon:Initialize()
        print("|cFF00FF00MyAddon|r Settings reset to defaults")

    elseif msg == "help" then
        print("|cFF00FF00MyAddon|r Commands:")
        print("  /myaddon debug - Toggle debug mode")
        print("  /myaddon reset - Reset settings")
        print("  /myaddon help - Show this help")

    else
        print("|cFF00FF00MyAddon|r Version 1.0.0")
        print("Type /myaddon help for commands")
    end
end

-- ============================================================================
-- 工具函数
-- ============================================================================

-- 安全调用
function addon:SafeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        print("|cFFFF0000MyAddon|r Error:", err)
    end
    return success, err
end

-- 战斗检查
function addon:InCombat()
    return InCombatLockdown()
end

-- 调试输出
function addon:Debug(...)
    if self.db and self.db.debug then
        print("|cFFFFFF00MyAddon|r", ...)
    end
end
