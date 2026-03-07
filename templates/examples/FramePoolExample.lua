-- ============================================================================
-- 帧池使用示例
-- ============================================================================
-- 帧池是魔兽世界插件开发中重要的性能优化技术
-- 避免频繁创建和销毁帧，而是复用已有的帧
-- ============================================================================

local addonName, addon = ...

-- 帧池示例模块
addon.FramePoolExample = {}

local FramePoolExample = addon.FramePoolExample

-- 创建物品按钮模板
local ItemButtonTemplate = "ItemButtonTemplate"

-- 帧池
local itemPool = nil

-- 活动中的按钮
local activeButtons = {}

-- ============================================================================
-- 初始化帧池
-- ============================================================================
function FramePoolExample:Initialize(parent)
    self.parent = parent or UIParent

    -- 创建帧池
    -- 参数: 帧类型, 父帧, 模板名称, 重置函数
    itemPool = CreateFramePool("BUTTON", self.parent, ItemButtonTemplate, function(pool, button)
        -- 重置函数：释放时调用
        button:ClearAllPoints()
        button:Hide()
        button.itemID = nil
        button.itemLink = nil
        button:SetNormalTexture(nil)
        button:SetScript("OnEnter", nil)
        button:SetScript("OnLeave", nil)
        button:SetScript("OnClick", nil)
    end)

    -- 设置初始位置
    self.spacing = 4
    self.buttonSize = 36
    self.maxItems = 20
end

-- ============================================================================
-- 获取一个按钮
-- ============================================================================
function FramePoolExample:AcquireButton(itemInfo)
    if not itemPool then
        self:Initialize()
    end

    -- 从池中获取按钮
    local button = itemPool:Acquire()

    -- 设置按钮属性
    button.itemID = itemInfo.itemID
    button.itemLink = itemInfo.itemLink

    -- 设置图标
    button:SetNormalTexture(itemInfo.icon)

    -- 设置提示
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(self.itemID)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- 设置点击
    button:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            -- 左键使用
            if IsModifiedClick("CHATLINK") then
                ChatEdit_InsertLink(self.itemLink)
            end
        elseif mouseButton == "RightButton" then
            -- 右键菜单
            addon:ShowItemMenu(self.itemID)
        end
    end)

    button:Show()
    return button
end

-- ============================================================================
-- 释放一个按钮
-- ============================================================================
function FramePoolExample:ReleaseButton(button)
    if itemPool then
        itemPool:Release(button)
    end
end

-- ============================================================================
-- 更新物品列表
-- ============================================================================
function FramePoolExample:UpdateItems(itemList)
    -- 释放所有当前按钮
    for i, button in ipairs(activeButtons) do
        itemPool:Release(button)
        activeButtons[i] = nil
    end

    -- 创建新按钮
    local count = 0
    local prevButton = nil

    for i, itemInfo in ipairs(itemList) do
        if i > self.maxItems then break end

        local button = self:AcquireButton(itemInfo)
        activeButtons[i] = button

        -- 布局
        if prevButton then
            button:SetPoint("LEFT", prevButton, "RIGHT", self.spacing, 0)
        else
            button:SetPoint("TOPLEFT", self.parent, "TOPLEFT", 10, -10)
        end

        prevButton = button
        count = count + 1
    end

    addon:Debug("Updated items, showing:", count)
end

-- ============================================================================
-- 获取当前活动按钮数量
-- ============================================================================
function FramePoolExample:GetActiveCount()
    return #activeButtons
end

-- ============================================================================
-- 释放所有按钮
-- ============================================================================
function FramePoolExample:ReleaseAll()
    if itemPool then
        itemPool:ReleaseAll()
    end
    wipe(activeButtons)
end

-- ============================================================================
-- 遍历活动按钮
-- ============================================================================
function FramePoolExample:ForEachActive(func)
    for i, button in ipairs(activeButtons) do
        func(button, i)
    end
end
