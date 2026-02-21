-- AuraTracker: A WoW addon to track and display auras
-- Main addon file
-- Author: Demonperson a.k.a. 92Garfield

-- Namespace
AuraTracker = AuraTracker or {}

-- Addon variables
AuraTracker.version = "1.0.0"
AuraTracker.windowManager = nil

-- Initialize the addon
function AuraTracker:Initialize()
    C_Timer.After(1, function()
        self:PostInitialize()
    end)
end

function AuraTracker:PostInitialize()
    print("AuraTracker v" .. self.version .. " loaded!")

    -- Initialize options panel (this also initializes AceDB)
    self.OptionsSetup:Initialize()

    -- Create aura window
    self:CreateAuraWindow()

    -- Update Blizzard BuffFrame visibility
    self:UpdateBlizzardBuffFrame()

    -- Start the update timer
    self:StartUpdateTimer()

    print("> Aura window created and initialized.")
end

-- Create aura window
function AuraTracker:CreateAuraWindow()
    if not self.db then
        return
    end

    -- Create the window manager
    self.windowManager = self:CreateWindowManager()
    
    -- Create windows for each enabled AuraBar (1-5)
    for barIndex = 1, 5 do
        local barConfig = self.db.profile.auraBars[barIndex]
        
        if barConfig and barConfig.enabled then
            -- Build filter configuration from saved settings
            local filters = {
                blizzard = self.OptionsSetup.BuildBlizzardFiltersArray(barConfig),
                preCombat = barConfig.preCombatFilter,
                permanent = barConfig.permanentFilter,
                consumable = barConfig.consumableFilter,
                excludePlayer = barConfig.excludePlayer,
                showOnlyGroup = barConfig.showOnlyGroup,
                excludeGroup = barConfig.excludeGroup,
                weaponEnchants = barConfig.filterWeaponEnchants
            }
            
            local windowId, window = self.windowManager:AddWindow(
                filters,
                {
                    position = barConfig.position,
                    auraSize = barConfig.auraSize,
                    columns = barConfig.columns,
                    maxAuras = barConfig.maxAuras,
                    growDirection = barConfig.growDirection,
                    showInCombat = barConfig.showInCombat,
                    showTooltips = barConfig.showTooltips
                }
            )
        end
    end
    
    self.windowManager:ShowAllWindows()
end

-- Recreate all windows (called when settings change)
function AuraTracker:RecreateWindows()
    if not self.windowManager then
        return
    end
    
    -- Clear existing windows
    self.windowManager:ClearAllWindows()
    
    -- Recreate windows with new settings
    self:CreateAuraWindow()
    
    -- Update visibility
    self:UpdateAuraWindowVisibility()
end

-- Update aura window visibility based on combat state
function AuraTracker:UpdateAuraWindowVisibility()
    if not self.db or not self.windowManager then
        return
    end

    local inCombat = AuraTracker.AuraFilter.ImInCombat()

    -- If global hide out of combat is enabled, hide everything
    if self.db.profile.hideOutOfCombat and not inCombat then
        self.windowManager:HideAllWindows()
        return
    end

    --self.windowManager:ShowAllWindows()
    --individual window visibility based on their config
    for _, window in pairs(self.windowManager.windows) do
        if window.config.showInCombat then
            if inCombat then
                window:Show()
            else
                window:Hide()
            end
        else
            window:Show()
        end
    end
end

-- Update Blizzard BuffFrame visibility
function AuraTracker:UpdateBlizzardBuffFrame()
    if not self.db then
        return
    end

    if BuffFrame then
        if self.db.profile.hideBlizzardBuffFrame then
            BuffFrame:Hide()
            hooksecurefunc(BuffFrame, "Show", function()
                BuffFrame:Hide()
            end)
        else
            BuffFrame:Show()
        end
    end
end

-- Start the update timer
function AuraTracker:StartUpdateTimer()
    if not self.db then
        return
    end

    -- Cancel existing timer if any
    if self.combatTicker then
        self.combatTicker:Cancel()
    end
    
    local interval = 0.1
    
    -- Create repeating timer
    self.combatTicker = C_Timer.NewTicker(interval, function()
        AuraTracker:UpdateAuraWindowVisibility()
    end)
    
    print("AuraTracker: Update timer started (interval: " .. interval .. "s)")
end

-- Restart the update timer (called when settings change)
function AuraTracker:RestartUpdateTimer()
    self:StartUpdateTimer()
end

-- Event handler
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "AuraTracker" then
        AuraTracker:Initialize()
    end
end)

-- Slash commands
SLASH_AURATRACKER1 = "/auratracker"
SLASH_AURATRACKER2 = "/at"
SlashCmdList["AURATRACKER"] = function(msg)
    msg = msg:lower():trim()
    
    if msg == "" or msg == "config" or msg == "options" then
        AuraTracker.Options:Open()
    elseif msg == "show" then
        if AuraTracker.windowManager then
            AuraTracker.windowManager:ShowAllWindows()
            print("AuraTracker: Aura windows shown")
        end
    elseif msg == "hide" then
        if AuraTracker.windowManager then
            AuraTracker.windowManager:HideAllWindows()
            print("AuraTracker: Aura windows hidden")
        end
    elseif msg == "help" then
        print("AuraTracker commands:")
        print("  /at config - Open options panel")
        print("  /at show - Show aura windows")
        print("  /at hide - Hide aura windows")
        print("  /at help - Show this help")
    else
        print("AuraTracker: Unknown command. Type /at help for commands")
    end
end