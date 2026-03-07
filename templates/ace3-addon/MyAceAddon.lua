-- ============================================================================
-- MyAceAddon - Ace3 Framework Based Addon Template
-- ============================================================================
-- Ace3 框架提供了丰富的功能：
-- - AceAddon-3.0: 插件生命周期管理
-- - AceDB-3.0: 数据库和配置持久化
-- - AceEvent-3.0: 事件处理
-- - AceConsole-3.0: 斜杠命令和打印
-- - AceTimer-3.0: 定时器
-- - AceHook-3.0: 钩子函数
-- ============================================================================

local addon = LibStub("AceAddon-3.0"):NewAddon("MyAceAddon", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")

-- ============================================================================
-- 默认数据库配置
-- ============================================================================
local defaults = {
    profile = {
        enabled = true,
        showWelcome = true,
        debug = false,
        -- 更多配置项...
    },
    global = {
        -- 全局数据（所有角色共享）
    },
    char = {
        -- 角色特定数据
        lastLogin = nil,
    }
}

-- ============================================================================
-- 初始化（数据库第一次创建时调用）
-- ============================================================================
function addon:OnInitialize()
    -- 初始化数据库
    self.db = LibStub("AceDB-3.0"):New("MyAceAddonDB", defaults, true)

    -- 注册配置文件变化回调
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileCopied")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileReset")

    -- 注册斜杠命令
    self:RegisterChatCommand("myaceaddon", "SlashCommand")
    self:RegisterChatCommand("maa", "SlashCommand")

    -- 显示初始化消息
    if self.db.profile.showWelcome then
        self:Print("Initialized! Use /maa help for commands.")
    end
end

-- ============================================================================
-- 启用（插件启用时调用）
-- ============================================================================
function addon:OnEnable()
    -- 注册事件
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("QUEST_LOG_UPDATE", "OnQuestLogUpdate")
    self:RegisterEvent("BAG_UPDATE", "OnBagUpdate")

    -- 注册单位事件
    self:RegisterUnitEvent("UNIT_HEALTH", "OnUnitHealth", "player")

    -- 钩子示例
    -- self:HookFunc("WorldFrame", "OnShow", function() ... end)
    -- self:HookScript(SomeFrame, "OnShow", function() ... end)

    -- 定时器示例
    -- self:ScheduleRepeatingTimer("OnTimerTick", 1)

    self:Debug("Addon enabled")
end

-- ============================================================================
-- 禁用（插件禁用时调用）
-- ============================================================================
function addon:OnDisable()
    -- 取消所有定时器
    self:CancelAllTimers()

    -- 注销所有事件
    self:UnregisterAllEvents()

    self:Debug("Addon disabled")
end

-- ============================================================================
-- 事件处理
-- ============================================================================
function addon:OnPlayerEnteringWorld(event, isLogin, isReload)
    if isLogin then
        self:Debug("Player logged in")
        self.db.char.lastLogin = time()
    end

    if isReload then
        self:Debug("UI reloaded")
    end
end

function addon:OnQuestLogUpdate(event)
    local numQuests = C_QuestLog.GetNumQuestLogEntries()
    self:Debug("Quest log updated, quests:", numQuests)
end

function addon:OnBagUpdate(event, bagID)
    self:Debug("Bag updated:", bagID)
end

function addon:OnUnitHealth(event, unit)
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local percent = (health / maxHealth) * 100
    self:Debug("Health:", health, "/", maxHealth, "(", percent, "%)")
end

-- ============================================================================
-- 定时器回调示例
-- ============================================================================
function addon:OnTimerTick()
    -- 每秒执行一次
    self:Debug("Timer tick")
end

-- ============================================================================
-- 配置文件回调
-- ============================================================================
function addon:OnProfileChanged(event, db, newProfileKey)
    self:Print("Profile changed to:", newProfileKey)
end

function addon:OnProfileCopied(event, db, sourceProfileKey)
    self:Print("Profile copied from:", sourceProfileKey)
end

function addon:OnProfileReset(event, db)
    self:Print("Profile reset to defaults")
end

-- ============================================================================
-- 斜杠命令处理
-- ============================================================================
function addon:SlashCommand(input)
    input = input:trim():lower()

    if input == "debug" then
        self.db.profile.debug = not self.db.profile.debug
        self:Print("Debug mode:", self.db.profile.debug and "ON" or "OFF")

    elseif input == "reset" then
        self.db:ResetProfile()
        self:Print("Profile reset to defaults")

    elseif input == "config" then
        -- 打开配置界面（如果有）
        self:Print("Config UI not implemented yet")

    elseif input == "status" then
        self:Print("=== Status ===")
        self:Print("Enabled:", self.db.profile.enabled)
        self:Print("Debug:", self.db.profile.debug)
        self:Print("Last login:", self.db.char.lastLogin and date("%Y-%m-%d %H:%M:%S", self.db.char.lastLogin) or "Never")

    elseif input == "timer test" then
        self:Print("Starting 3 second timer...")
        self:ScheduleTimer(function()
            addon:Print("Timer fired!")
        end, 3)

    elseif input == "help" then
        self:Print("=== Commands ===")
        self:Print("/maa debug - Toggle debug mode")
        self:Print("/maa reset - Reset profile")
        self:Print("/maa config - Open config")
        self:Print("/maa status - Show status")
        self:Print("/maa timer test - Test timer")
        self:Print("/maa help - Show this help")

    else
        self:Print("MyAceAddon v1.0.0 - Type /maa help for commands")
    end
end

-- ============================================================================
-- 工具方法
-- ============================================================================

-- 调试输出（只在debug模式启用时显示）
function addon:Debug(...)
    if self.db and self.db.profile.debug then
        self:Print("|cFFFFCC00[DEBUG]|r", ...)
    end
end

-- 检查是否在战斗中
function addon:InCombat()
    return InCombatLockdown()
end

-- 安全调用
function addon:SafeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        self:Print("|cFFFF0000[ERROR]|r", err)
    end
    return success, err
end

-- 创建帧池辅助函数
function addon:CreateFramePool(frameType, parent, template, resetFunc)
    return CreateFramePool(frameType, parent, template, resetFunc)
end
