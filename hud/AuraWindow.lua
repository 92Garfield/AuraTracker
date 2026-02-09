-- AuraWindow class: Aura display window
-- Author: Demonperson a.k.a. 92Garfield

-- Namespace
if not AuraTracker then
    AuraTracker = {}
end

-- AuraWindow class
local AuraWindow = {}
AuraWindow.__index = AuraWindow

-- Constructor
function AuraTracker:CreateWindow()
    local instance = setmetatable({}, AuraWindow)
    
    instance.auras = {}
    instance.visible = true
    
    -- New flexible filter system
    -- filters = {
    --     blizzard = { "HELPFUL", "HARMFUL" },  -- Which Blizzard API filters to query
    --     preCombat = "EXCLUDE",                -- Include/Exclude pre-combat auras (nil = ignore)
    --     permanent = "EXCLUDE",                -- Include/Exclude permanent auras (nil = ignore)
    --     consumable = "EXCLUDE"                -- Include/Exclude consumable auras (nil = ignore)
    -- }
    instance.filters = {
        blizzard = { "HELPFUL" },  -- Default: only helpful buffs
        preCombat = nil,
        permanent = nil,
        consumable = nil
    }
    
    instance.config = {}

    -- Don't create frames here - manager will call CreateAuraFrames after setting config
    
    return instance
end

function AuraWindow:CreateAuraFrames()
    -- Use unique name for each window
    local frameName = "AuraTrackerAuraWindow_" .. tostring(self):sub(-8)
    self.frame = CreateFrame("Frame", frameName, UIParent)
    local parent = self.frame
    
    -- Get config with defaults
    local auraSize = self.config.auraSize or 30
    local columns = self.config.columns or 10
    local growDirection = self.config.growDirection or "RIGHT"
    local spacing = 5
    
    -- Calculate frame size based on grow direction
    local maxAuras = 40
    local rows = math.ceil(maxAuras / columns)
    
    if growDirection == "RIGHT" or growDirection == "LEFT" then
        parent:SetSize(auraSize * columns + spacing * (columns - 1), auraSize * rows + spacing * (rows - 1))
    else
        parent:SetSize(auraSize * rows + spacing * (rows - 1), auraSize * columns + spacing * (columns - 1))
    end
    
    -- Set position from config
    local position = self.config.position or { point = "CENTER", x = 0, y = 0 }
    parent:SetPoint(
        position.point or "CENTER",
        UIParent,
        position.point or "CENTER",
        position.x or 0,
        position.y or 0
    )

    -- Create background texture
    local background = parent:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(parent)
    background:SetColorTexture(0.529, 0.808, 0.922, 0.5)  -- Light blue (135, 206, 235) with 0.5 alpha
    self.background = background
    
    -- Update background visibility based on config
    self:UpdateBackgroundVisibility()

    for i = 1, maxAuras do
        local auraFrameName = frameName .. "_Aura" .. i
        local auraFrame = CreateFrame("Frame", auraFrameName, parent)
        auraFrame:SetSize(auraSize, auraSize)
        
        -- Calculate position based on grow direction and column count
        if i == 1 then
            -- First icon anchors to parent
            if growDirection == "RIGHT" then
                auraFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
            elseif growDirection == "LEFT" then
                auraFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
            elseif growDirection == "DOWN" then
                auraFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
            elseif growDirection == "UP" then
                auraFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
            end
        else
            local prevFrame = self.auras[i - 1]
            local col = (i - 1) % columns
            
            if col == 0 then
                -- Start new row/column
                if growDirection == "RIGHT" then
                    auraFrame:SetPoint("TOPLEFT", self.auras[i - columns], "BOTTOMLEFT", 0, -spacing)
                elseif growDirection == "LEFT" then
                    auraFrame:SetPoint("TOP", self.auras[i - columns], "BOTTOM", 0, -spacing)
                elseif growDirection == "DOWN" then
                    auraFrame:SetPoint("TOPLEFT", self.auras[i - columns], "TOPRIGHT", spacing, 0)
                elseif growDirection == "UP" then
                    auraFrame:SetPoint("BOTTOMLEFT", self.auras[i - columns], "BOTTOMRIGHT", spacing, 0)
                end
            else
                -- Continue in same row/column
                if growDirection == "RIGHT" then
                    auraFrame:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0)
                elseif growDirection == "LEFT" then
                    auraFrame:SetPoint("RIGHT", prevFrame, "LEFT", -spacing, 0)
                elseif growDirection == "DOWN" then
                    auraFrame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing)
                elseif growDirection == "UP" then
                    auraFrame:SetPoint("BOTTOM", prevFrame, "TOP", 0, spacing)
                end
            end
        end

        local icon = auraFrame:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        auraFrame.icon = icon
        
        -- Create timer text below the icon
        local timerText = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- timerText:SetPoint("BOTTOM", auraFrame, "BOTTOM", 0, -15)
        timerText:SetPoint("BOTTOM", auraFrame, "BOTTOM", 0, -14)
        timerText:SetTextColor(1, 1, 1, 1)
        timerText:SetFont(timerText:GetFont(), 13, "OUTLINE")
        auraFrame.timerText = timerText
        
        -- Create stacks text in lower right corner
        local stacksText = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        stacksText:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", -2, 2)
        stacksText:SetTextColor(1, 1, 1, 1)
        stacksText:SetFont(stacksText:GetFont(), 13, "OUTLINE")
        auraFrame.stacksText = stacksText
        
        -- Enable mouse interaction for tooltips and right-click cancel
        auraFrame:EnableMouse(true)
        auraFrame.enableMouseClicks = True
        
        auraFrame:SetScript("OnEnter", function(frame)
            if frame.auraInfo and self.config.showTooltips then
                GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT")
                
                if frame.auraInfo.isWeaponEnchant then
                    -- For weapon enchants, show the enchant spell
                    GameTooltip:SetSpellByID(frame.auraInfo.spellId)
                else
                    -- For regular auras, use the spell ID
                    GameTooltip:SetSpellByID(frame.auraInfo.spellId)
                end
                
                GameTooltip:Show()
            end
        end)
        
        auraFrame:SetScript("OnLeave", function(frame)
            if self.config.showTooltips then
                GameTooltip:Hide()
            end
        end)
        
        auraFrame:SetScript("OnMouseUp", function(frame, button)
            if button == "RightButton" and frame.auraInfo then
                local auraInfo = frame.auraInfo

                -- Weapon enchants cannot be canceled
                if auraInfo.isWeaponEnchant then
                    return
                end

                -- Use CancelUnitBuff with index and filter string
                if auraInfo.auraIndex and auraInfo.filterString then
                    CancelUnitBuff("player", auraInfo.auraIndex, auraInfo.filterString)
                end
            end
        end)

        self.auras[i] = auraFrame
        auraFrame:Hide()
    end
end

function AuraWindow:Show()
    self.visible = true
    if self.frame then
        self.frame:Show()
        self:UpdateAuras() -- To force an update when shown
    end
end

function AuraWindow:Hide()
    self.visible = false
    if self.frame then
        self.frame:Hide()
    end
end

-- Get filtered auras based on the window's filter configuration
function AuraWindow:GetFilteredAuras()
    -- Delegate to AuraFilter module
    return AuraTracker.AuraFilter.GetFilteredAuras(self.filters)
end

function AuraWindow:UpdateAuras()
    if not self.visible or not self.frame then
        return
    end
    
    local filteredAuras = self:GetFilteredAuras()
    local currentTime = GetTime()

    -- Display filtered auras
    local frameIndex = 1
    for _, auraInfo in ipairs(filteredAuras) do
        local auraFrame = self.auras[frameIndex]
        if not auraFrame then
            -- No more frames available
            break
        end

        -- Set the icon texture using the iconID from auraInfo
        if auraInfo.icon then
            auraFrame.icon:SetTexture(auraInfo.icon)
        end
        
        -- Update timer text
        if auraFrame.timerText then
            local remainingTime

            if auraInfo.isWeaponEnchant then
                -- Weapon enchants store duration directly
                remainingTime = auraInfo.expirationTime - GetTime()
            else
                -- Regular auras use C_UnitAuras.GetAuraDuration
                local duration = C_UnitAuras.GetAuraDuration("player", auraInfo.auraInstanceID)
                remainingTime = duration:GetRemainingDuration()
            end

            auraFrame.timerText:SetText(AuraTracker.FormatNumber.Countdown(remainingTime))

            --if not AuraTracker.AuraFilter.IsTaggedPermanent(auraInfo) then
            --   auraFrame.timerText:Show()
            --else
            --   auraFrame.timerText:Hide()
            --end
            auraFrame.timerText:Show()
            auraFrame.timerText:SetAlpha(auraInfo.duration)
        end
        
        -- Update stacks text
        if auraFrame.stacksText then
            auraFrame.stacksText:SetText(C_StringUtil.TruncateWhenZero(auraInfo.applications))
        end
        
        -- Store auraInfo for tooltip
        auraFrame.auraInfo = auraInfo

        auraFrame:Show()
        frameIndex = frameIndex + 1
    end

    -- Hide unused frames and clear their auraInfo
    for i = frameIndex, #self.auras do
        self.auras[i].auraInfo = nil
        if self.auras[i].timerText then
            self.auras[i].timerText:Hide()
        end
        if self.auras[i].stacksText then
            self.auras[i].stacksText:Hide()
        end
        self.auras[i]:Hide()
    end
end

function AuraWindow:UpdateBackgroundVisibility()
    if self.background then
        if AuraTracker.db and AuraTracker.db.profile.showArea then
            self.background:Show()
        else
            self.background:Hide()
        end
    end
end