-- ============================================================================
-- 任务追踪示例
-- ============================================================================
-- 演示如何使用任务相关API创建简单的任务追踪功能
-- ============================================================================

local addonName, addon = ...

addon.QuestTracker = {}

local QuestTracker = addon.QuestTracker

-- ============================================================================
-- 初始化
-- ============================================================================
function QuestTracker:Initialize()
    -- 创建主框架
    self.frame = CreateFrame("Frame", "MyQuestTrackerFrame", UIParent)
    self.frame:SetSize(250, 300)
    self.frame:SetPoint("RIGHT", UIParent, "RIGHT", -20, 0)

    -- 创建背景
    self.frame.bg = self.frame:CreateTexture(nil, "BACKGROUND")
    self.frame.bg:SetAllPoints()
    self.frame.bg:SetColorTexture(0, 0, 0, 0.5)

    -- 创建标题
    self.frame.title = self.frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    self.frame.title:SetPoint("TOP", 0, -5)
    self.frame.title:SetText("Quest Tracker")

    -- 创建内容区域
    self.frame.content = CreateFrame("Frame", nil, self.frame)
    self.frame.content:SetPoint("TOP", self.frame.title, "BOTTOM", 0, -5)
    self.frame.content:SetPoint("BOTTOMLEFT", 5, 5)
    self.frame.content:SetPoint("BOTTOMRIGHT", -5, 5)

    -- 追踪的任务ID列表
    self.trackedQuests = {}

    -- 设置可拖动
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(f) f:StartMoving() end)
    self.frame:SetScript("OnDragStop", function(f) f:StopMovingOrSizing() end)

    -- 默认隐藏
    self.frame:Hide()

    addon:Debug("QuestTracker initialized")
end

-- ============================================================================
-- 显示/隐藏
-- ============================================================================
function QuestTracker:Show()
    if not self.frame then
        self:Initialize()
    end
    self.frame:Show()
    self:Refresh()
end

function QuestTracker:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function QuestTracker:Toggle()
    if self.frame and self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- ============================================================================
-- 添加/移除追踪任务
-- ============================================================================
function QuestTracker:TrackQuest(questID)
    if not questID then return end

    -- 检查任务是否在日志中
    if not C_QuestLog.GetLogIndexForQuestID(questID) then
        addon:Print("Quest not found in log:", questID)
        return
    end

    -- 添加到追踪列表
    self.trackedQuests[questID] = true
    addon:Debug("Tracking quest:", questID)

    -- 刷新显示
    if self.frame and self.frame:IsShown() then
        self:Refresh()
    end
end

function QuestTracker:UntrackQuest(questID)
    self.trackedQuests[questID] = nil
    addon:Debug("Untracking quest:", questID)

    -- 刷新显示
    if self.frame and self.frame:IsShown() then
        self:Refresh()
    end
end

function QuestTracker:IsTracked(questID)
    return self.trackedQuests[questID] == true
end

-- ============================================================================
-- 刷新显示
-- ============================================================================
function QuestTracker:Refresh()
    if not self.frame then return end

    -- 清除旧内容
    -- （实际实现中应该使用帧池）

    local y = -10

    for questID in pairs(self.trackedQuests) do
        local questInfo = self:GetQuestInfo(questID)
        if questInfo then
            -- 创建任务条目（简化示例）
            local entry = self:CreateQuestEntry(questInfo, y)
            y = y - 40
        end
    end
end

-- ============================================================================
-- 获取任务信息
-- ============================================================================
function QuestTracker:GetQuestInfo(questID)
    local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    if not questLogIndex then return nil end

    local info = C_QuestLog.GetInfo(questLogIndex)
    if not info then return nil end

    local title = C_QuestLog.GetTitleForQuestID(questID)
    local level = C_QuestLog.GetQuestDifficultyLevel(questID)
    local isComplete = C_QuestLog.IsComplete(questID)
    local objectives = C_QuestLog.GetQuestObjectives(questID)

    return {
        questID = questID,
        title = title or "Unknown Quest",
        level = level or 0,
        isComplete = isComplete,
        objectives = objectives or {},
    }
end

-- ============================================================================
-- 创建任务条目
-- ============================================================================
function QuestTracker:CreateQuestEntry(questInfo, y)
    local entry = CreateFrame("Button", nil, self.frame.content)
    entry:SetSize(240, 30)
    entry:SetPoint("TOP", 0, y)

    -- 背景根据完成状态变色
    entry.bg = entry:CreateTexture(nil, "BACKGROUND")
    entry.bg:SetAllPoints()
    if questInfo.isComplete then
        entry.bg:SetColorTexture(0, 0.5, 0, 0.3)  -- 绿色表示完成
    else
        entry.bg:SetColorTexture(0.2, 0.2, 0.2, 0.3)
    end

    -- 标题
    entry.text = entry:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    entry.text:SetPoint("LEFT", 5, 0)
    entry.text:SetText(questInfo.title)

    -- 点击跳转到任务
    entry:SetScript("OnClick", function()
        C_SuperTrack.SetSuperTrackedQuestID(questInfo.questID)
    end)

    -- 提示
    entry:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetQuestByID(questInfo.questID)
        GameTooltip:Show()
    end)

    entry:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return entry
end

-- ============================================================================
-- 获取所有追踪的任务
-- ============================================================================
function QuestTracker:GetTrackedQuests()
    local list = {}
    for questID in pairs(self.trackedQuests) do
        table.insert(list, questID)
    end
    return list
end
