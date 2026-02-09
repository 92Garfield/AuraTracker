-- AuraWindowManager: Manages multiple aura windows with different filter presets
-- Author: Demonperson a.k.a. 92Garfield

-- Namespace
if not AuraTracker then
    AuraTracker = {}
end

-- AuraWindowManager class
local AuraWindowManager = {}
AuraWindowManager.__index = AuraWindowManager

-- Constructor
function AuraTracker:CreateWindowManager()
    local instance = setmetatable({}, AuraWindowManager)
    
    instance.windows = {}
    instance.windowCount = 0
    
    return instance
end

-- Add a new aura window with flexible filter configuration
-- filters = {
--     blizzard = { "HELPFUL", "HARMFUL" },    -- Blizzard API filters to query
--     preCombat = "EXCLUDE",                  -- INCLUDE/EXCLUDE pre-combat auras (nil = ignore)
--     permanent = "EXCLUDE",                  -- INCLUDE/EXCLUDE permanent auras (nil = ignore)
--     consumable = "EXCLUDE"                  -- INCLUDE/EXCLUDE consumable auras (nil = ignore)
-- }
function AuraWindowManager:AddWindow(filters, config)
    config = config or {}
    filters = filters or {}
    
    -- Create the window
    local window = AuraTracker:CreateWindow()
    
    -- Set filter configuration
    window.filters = {
        blizzard = filters.blizzard or { "HELPFUL" },
        preCombat = filters.preCombat,
        permanent = filters.permanent,
        consumable = filters.consumable,
        excludePlayer = filters.excludePlayer,
        showOnlyGroup = filters.showOnlyGroup,
        excludeGroup = filters.excludeGroup,
        weaponEnchants = filters.weaponEnchants
    }
    
    -- Set config before creating frames
    window.config = {
        position = config.position or { point = "CENTER", x = 0, y = 0 },
        auraSize = config.auraSize or 30,
        columns = config.columns or 10,
        growDirection = config.growDirection or "RIGHT",
        showInCombat = config.showInCombat or false,
        showTooltips = config.showTooltips ~= false  -- Default to true
    }
    
    -- Now create frames with the config
    window:CreateAuraFrames()
    
    self.windowCount = self.windowCount + 1
    local windowId = "window_" .. self.windowCount
    self.windows[windowId] = window
    
    return windowId, window
end

-- Remove a window by ID
function AuraWindowManager:RemoveWindow(windowId)
    local window = self.windows[windowId]
    if not window then
        return false
    end
    
    window:Hide()
    if window.frame then
        window.frame:Hide()
        window.frame = nil
    end
    
    self.windows[windowId] = nil
    return true
end

-- Get a window by ID
function AuraWindowManager:GetWindow(windowId)
    return self.windows[windowId]
end

-- Update all windows
function AuraWindowManager:UpdateAllWindows()
    for windowId, window in pairs(self.windows) do
        if window.visible then
            window:UpdateAuras()
        end
    end
end

-- Show all windows
function AuraWindowManager:ShowAllWindows()
    for windowId, window in pairs(self.windows) do
        window:Show()
    end
end

-- Hide all windows
function AuraWindowManager:HideAllWindows()
    for windowId, window in pairs(self.windows) do
        window:Hide()
    end
end

-- Show specific window
function AuraWindowManager:ShowWindow(windowId)
    local window = self.windows[windowId]
    if window then
        window:Show()
        return true
    end
    return false
end

-- Hide specific window
function AuraWindowManager:HideWindow(windowId)
    local window = self.windows[windowId]
    if window then
        window:Hide()
        return true
    end
    return false
end

-- Get all windows
function AuraWindowManager:GetAllWindows()
    return self.windows
end

-- Get window count
function AuraWindowManager:GetWindowCount()
    local count = 0
    for _ in pairs(self.windows) do
        count = count + 1
    end
    return count
end

-- Clear all windows
function AuraWindowManager:ClearAllWindows()
    for windowId, window in pairs(self.windows) do
        self:RemoveWindow(windowId)
    end
    self.windows = {}
end
