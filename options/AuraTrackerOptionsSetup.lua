-- AuraTrackerOptionsSetup: Helper functions and initialization for AuraTracker options
-- Author: Demonperson a.k.a. 92Garfield

local name, addon = ...

-- Namespace
AuraTracker.OptionsSetup = {}

--[[----------------------------------------------------------------------------
Helper Functions
------------------------------------------------------------------------------]]
local function GetAuraBarConfig(barIndex)
    return AuraTracker.db.profile.auraBars[barIndex]
end

local function SetAuraBarConfig(barIndex, key, value)
    AuraTracker.db.profile.auraBars[barIndex][key] = value
    AuraTracker:RecreateWindows()
end

local function GetAuraBarFilter(barIndex, filterKey)
    return AuraTracker.db.profile.auraBars[barIndex][filterKey]
end

local function SetAuraBarFilter(barIndex, filterKey, value)
    AuraTracker.db.profile.auraBars[barIndex][filterKey] = value
    AuraTracker:RecreateWindows()
end

-- Build blizzardFilters array from individual boolean flags
local function BuildBlizzardFiltersArray(barConfig)
    local filters = {}
    
    if barConfig.filterHelpful then
        table.insert(filters, "HELPFUL")
    end
    
    if barConfig.filterHarmful then
        table.insert(filters, "HARMFUL")
    end
    
    if barConfig.filterPlayer then
        table.insert(filters, "PLAYER")
    end
    
    if barConfig.filterRaid then
        table.insert(filters, "RAID")
    end
    
    if barConfig.filterCancelable then
        table.insert(filters, "CANCELABLE")
    end
    
    if barConfig.filterNotCancelable then
        table.insert(filters, "NOT_CANCELABLE")
    end
    
    if barConfig.filterMaw then
        table.insert(filters, "MAW")
    end
    
    -- If no filters are enabled, default to HELPFUL
    if #filters == 0 then
        filters = { "HELPFUL" }
    end
    
    return filters
end

-- Get dropdown values for AuraGroups
local function GetAuraGroupDropdownValues()
    local values = {
        ["nil"] = "None"
    }
    
    if AuraTracker.db and AuraTracker.db.profile.auraGroups then
        for key, group in pairs(AuraTracker.db.profile.auraGroups) do
            values[key] = group.name or ("Group " .. key)
        end
    end
    
    return values
end

-- Export helper functions
AuraTracker.OptionsSetup.GetAuraBarConfig = GetAuraBarConfig
AuraTracker.OptionsSetup.SetAuraBarConfig = SetAuraBarConfig
AuraTracker.OptionsSetup.GetAuraBarFilter = GetAuraBarFilter
AuraTracker.OptionsSetup.SetAuraBarFilter = SetAuraBarFilter
AuraTracker.OptionsSetup.BuildBlizzardFiltersArray = BuildBlizzardFiltersArray
AuraTracker.OptionsSetup.GetAuraGroupDropdownValues = GetAuraGroupDropdownValues

--[[----------------------------------------------------------------------------
Initialize Options
------------------------------------------------------------------------------]]
function AuraTracker.OptionsSetup:Initialize()
    -- Initialize AceDB with defaults from separate file
    local defaults = AuraTracker.OptionsDefaults.defaults
    AuraTracker.db = LibStub("AceDB-3.0"):New("AuraTrackerDB", defaults)
    
    -- Register profile change callbacks
    AuraTracker.db.RegisterCallback(AuraTracker, "OnProfileChanged", "RecreateWindows")
    AuraTracker.db.RegisterCallback(AuraTracker, "OnProfileCopied", "RecreateWindows")
    AuraTracker.db.RegisterCallback(AuraTracker, "OnProfileReset", "RecreateWindows")
    
    -- Get the options table from AuraTracker.Options
    local options = AuraTracker.Options.GetOptionsTable()
    
    -- Register options table
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AuraTracker", options)
    
    -- Add profile options from AceDBOptions
    local AceDBOptions = LibStub("AceDBOptions-3.0")
    options.args.profiles = AceDBOptions:GetOptionsTable(AuraTracker.db)
    options.args.profiles.order = 100
    
    -- Add to Blizzard options
    AuraTracker.Options.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AuraTracker", "AuraTracker")
    
    print("AuraTracker options panel registered!")
end

-- Open the options panel
function AuraTracker.OptionsSetup:Open()
    -- Open to Interface -> AddOns -> AuraTracker
    -- InterfaceOptionsFrame_OpenToCategory(AuraTracker.Options.optionsFrame)
    -- InterfaceOptionsFrame_OpenToCategory(AuraTracker.Options.optionsFrame) -- Called twice due to Blizzard bug
end
