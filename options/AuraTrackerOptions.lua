-- AuraTrackerOptions: Options panel for AuraTracker addon
-- Author: Demonperson a.k.a. 92Garfield

local name, addon = ...

-- Namespace
AuraTracker.Options = {}

-- Helper function references (imported from AuraTrackerOptionsSetup)
local GetAuraBarConfig
local SetAuraBarConfig
local GetAuraBarFilter
local SetAuraBarFilter
local GetAuraGroupDropdownValues

-- Initialize helper function references
local function InitializeHelpers()
    GetAuraBarConfig = AuraTracker.OptionsSetup.GetAuraBarConfig
    SetAuraBarConfig = AuraTracker.OptionsSetup.SetAuraBarConfig
    GetAuraBarFilter = AuraTracker.OptionsSetup.GetAuraBarFilter
    SetAuraBarFilter = AuraTracker.OptionsSetup.SetAuraBarFilter
    GetAuraGroupDropdownValues = AuraTracker.OptionsSetup.GetAuraGroupDropdownValues
end

-- Helper function to create option entries with order
local function GetOptionEntry(info, order)
    info.order = order
    return info
end

-- Generate options for a single AuraBar
local function GenerateAuraBarOptions(barIndex, order)
    -- Define all option definitions in a map
    local optionsMap = {
        enabled = {
            name = "Enable AuraBar",
            desc = "Enable or disable this aura bar.",
            type = "toggle",
            width = "full",
            get = function(info)
                return GetAuraBarConfig(barIndex).enabled
            end,
            set = function(info, value)
                SetAuraBarConfig(barIndex, "enabled", value)
            end
        },
        showInCombat = {
            name = "Show Only in Combat",
            desc = "Show this aura bar only when in combat.",
            type = "toggle",
            width = "full",
            get = function(info)
                return GetAuraBarConfig(barIndex).showInCombat
            end,
            set = function(info, value)
                SetAuraBarConfig(barIndex, "showInCombat", value)
            end
        },
        showTooltips = {
            name = "Show Tooltips",
            desc = "Show tooltips when hovering over aura icons.",
            type = "toggle",
            width = "full",
            get = function(info)
                return GetAuraBarConfig(barIndex).showTooltips
            end,
            set = function(info, value)
                SetAuraBarConfig(barIndex, "showTooltips", value)
            end
        },
        headerFilters = {
            name = "Filters",
            type = "header"
        },
        blizzardFiltersDesc = {
            name = "Blizzard Filters (what to query from API):",
            type = "description"
        },
        blizzardHelpful = {
            name = "Show Helpful (Buffs)",
            desc = "Query helpful auras (buffs) from the Blizzard API.",
            type = "toggle",
            get = function(info)
                return GetAuraBarFilter(barIndex, "filterHelpful")
            end,
            set = function(info, value)
                SetAuraBarFilter(barIndex, "filterHelpful", value)
            end
        },
        blizzardHarmful = {
            name = "Show Harmful (Debuffs)",
            desc = "Query harmful auras (debuffs) from the Blizzard API.",
            type = "toggle",
            get = function(info)
                return GetAuraBarFilter(barIndex, "filterHarmful")
            end,
            set = function(info, value)
                SetAuraBarFilter(barIndex, "filterHarmful", value)
            end
        },
        blizzardPlayer = {
            name = "Show Player Cast",
            desc = "Query auras cast by the player.",
            type = "toggle",
            get = function(info)
                return GetAuraBarFilter(barIndex, "filterPlayer")
            end,
            set = function(info, value)
                SetAuraBarFilter(barIndex, "filterPlayer", value)
            end
        },
        excludePlayer = {
            name = "-- Exclude Player",
            desc = "Exclude auras cast by the player (show only auras from others).",
            type = "toggle",
            width = "full",
            get = function(info)
                return GetAuraBarFilter(barIndex, "excludePlayer")
            end,
            set = function(info, value)
                SetAuraBarFilter(barIndex, "excludePlayer", value)
            end
        },
        blizzardRaid = {
            name = "Show Raid",
            desc = "Query auras that are relevant to raid members.",
            type = "toggle",
            get = function(info)
                return GetAuraBarFilter(barIndex, "filterRaid")
            end,
            set = function(info, value)
                SetAuraBarFilter(barIndex, "filterRaid", value)
            end
        },
        blizzardCancelable = {
            name = "Show Cancelable",
            desc = "Query auras that can be canceled by the player.",
            type = "toggle",
            get = function(info)
                return GetAuraBarFilter(barIndex, "filterCancelable")
            end,
            set = function(info, value)
                SetAuraBarFilter(barIndex, "filterCancelable", value)
            end
        },
        blizzardNotCancelable = {
            name = "Show Not Cancelable",
            desc = "Query auras that cannot be canceled by the player.",
            type = "toggle",
            get = function(info)
                return GetAuraBarFilter(barIndex, "filterNotCancelable")
            end,
            set = function(info, value)
                SetAuraBarFilter(barIndex, "filterNotCancelable", value)
            end
        },
        blizzardMaw = {
            name = "Show Maw",
            desc = "Query auras related to the Maw.",
            type = "toggle",
            get = function(info)
                return GetAuraBarFilter(barIndex, "filterMaw")
            end,
            set = function(info, value)
                SetAuraBarFilter(barIndex, "filterMaw", value)
            end
        },
        specialFiltersDesc = {
            name = "Special Filters (include/exclude modifiers):",
            type = "description"
        },
        preCombatFilter = {
            name = "Pre-Combat Filter",
            desc = "Filter auras based on whether they existed before combat started.",
            type = "select",
            values = {
                ["nil"] = "Ignore (show all)",
                ["INCLUDE"] = "Include Only (show only pre-combat auras)",
                ["EXCLUDE"] = "Exclude (hide pre-combat auras)"
            },
            get = function(info)
                local value = GetAuraBarFilter(barIndex, "preCombatFilter")
                if value == nil then
                    return "nil"
                end
                return value
            end,
            set = function(info, value)
                if value == "nil" then
                    value = nil
                end
                SetAuraBarFilter(barIndex, "preCombatFilter", value)
            end
        },
        permanentFilter = {
            name = "Permanent Filter",
            desc = "Filter auras based on whether they are permanent or long-duration (>5 min).",
            type = "select",
            values = {
                ["nil"] = "Ignore (show all)",
                ["INCLUDE"] = "Include Only (show only permanent auras)",
                ["EXCLUDE"] = "Exclude (hide permanent auras)"
            },
            get = function(info)
                local value = GetAuraBarFilter(barIndex, "permanentFilter")
                if value == nil then
                    return "nil"
                end
                return value
            end,
            set = function(info, value)
                if value == "nil" then
                    value = nil
                end
                SetAuraBarFilter(barIndex, "permanentFilter", value)
            end
        },
        consumableFilter = {
            name = "Consumable Filter",
            desc = "Filter auras based on whether they are consumables (food, flasks, 2-60 min duration).",
            type = "select",
            values = {
                ["nil"] = "Ignore (show all)",
                ["INCLUDE"] = "Include Only (show only consumable auras)",
                ["EXCLUDE"] = "Exclude (hide consumable auras)"
            },
            get = function(info)
                local value = GetAuraBarFilter(barIndex, "consumableFilter")
                if value == nil then
                    return "nil"
                end
                return value
            end,
            set = function(info, value)
                if value == "nil" then
                    value = nil
                end
                SetAuraBarFilter(barIndex, "consumableFilter", value)
            end
        },
        filterWeaponEnchants = {
            name = "Weapon Enchants",
            desc = "Show temporary weapon enchant auras (e.g. oil, sharpening stones).",
            type = "toggle",
            get = function(info)
                return GetAuraBarFilter(barIndex, "filterWeaponEnchants")
            end,
            set = function(info, value)
                SetAuraBarFilter(barIndex, "filterWeaponEnchants", value)
            end
        },
        auraGroupFiltersDesc = {
            name = "Aura Group Filters:",
            type = "description"
        },
        showOnlyGroup = {
            name = "Show Only",
            desc = "Show only auras from the selected group.",
            type = "select",
            width = 1.5,
            values = function()
                return GetAuraGroupDropdownValues()
            end,
            get = function(info)
                local value = GetAuraBarFilter(barIndex, "showOnlyGroup")
                if value == nil then
                    return "nil"
                end
                return value
            end,
            set = function(info, value)
                if value == "nil" then
                    value = nil
                end
                SetAuraBarFilter(barIndex, "showOnlyGroup", value)
            end
        },
        excludeGroup = {
            name = "Exclude",
            desc = "Exclude auras from the selected group.",
            type = "select",
            width = 1.5,
            values = function()
                return GetAuraGroupDropdownValues()
            end,
            get = function(info)
                local value = GetAuraBarFilter(barIndex, "excludeGroup")
                if value == nil then
                    return "nil"
                end
                return value
            end,
            set = function(info, value)
                if value == "nil" then
                    value = nil
                end
                SetAuraBarFilter(barIndex, "excludeGroup", value)
            end
        },
        headerAppearance = {
            name = "Appearance",
            type = "header"
        },
        auraSize = {
            name = "Aura Size",
            desc = "Size of each aura icon in pixels.",
            type = "range",
            min = 10,
            max = 80,
            step = 1,
            get = function(info)
                return GetAuraBarConfig(barIndex).auraSize
            end,
            set = function(info, value)
                SetAuraBarConfig(barIndex, "auraSize", value)
            end
        },
        columns = {
            name = "Columns",
            desc = "Number of columns before wrapping (for horizontal grow) or rows (for vertical grow).",
            type = "range",
            min = 1,
            max = 40,
            step = 1,
            get = function(info)
                return GetAuraBarConfig(barIndex).columns
            end,
            set = function(info, value)
                SetAuraBarConfig(barIndex, "columns", value)
            end
        },
        growDirection = {
            name = "Grow Direction",
            desc = "Direction in which auras are added.",
            type = "select",
            values = {
                RIGHT = "Right",
                LEFT = "Left",
                DOWN = "Down",
                UP = "Up"
            },
            get = function(info)
                return GetAuraBarConfig(barIndex).growDirection
            end,
            set = function(info, value)
                SetAuraBarConfig(barIndex, "growDirection", value)
            end
        },
        headerPosition = {
            name = "Position",
            type = "header"
        },
        posX = {
            name = "X Position",
            desc = "Horizontal position offset from anchor point.",
            type = "range",
            min = -2000,
            max = 2000,
            step = 1,
            get = function(info)
                return GetAuraBarConfig(barIndex).position.x
            end,
            set = function(info, value)
                GetAuraBarConfig(barIndex).position.x = value
                AuraTracker:RecreateWindows()
            end
        },
        posY = {
            name = "Y Position",
            desc = "Vertical position offset from anchor point.",
            type = "range",
            min = -2000,
            max = 2000,
            step = 1,
            get = function(info)
                return GetAuraBarConfig(barIndex).position.y
            end,
            set = function(info, value)
                GetAuraBarConfig(barIndex).position.y = value
                AuraTracker:RecreateWindows()
            end
        },
        posAnchor = {
            name = "Anchor Point",
            desc = "The anchor point for this aura bar.",
            type = "select",
            values = {
                CENTER = "Center",
                TOP = "Top",
                BOTTOM = "Bottom",
                LEFT = "Left",
                RIGHT = "Right",
                TOPLEFT = "Top Left",
                TOPRIGHT = "Top Right",
                BOTTOMLEFT = "Bottom Left",
                BOTTOMRIGHT = "Bottom Right"
            },
            get = function(info)
                return GetAuraBarConfig(barIndex).position.point
            end,
            set = function(info, value)
                GetAuraBarConfig(barIndex).position.point = value
                AuraTracker:RecreateWindows()
            end
        }
    }
    
    -- Define the sort order (list of option keys only)
    local sortOrder = {
        "enabled",
        "showInCombat",
        "showTooltips",
        "headerFilters",
        "blizzardFiltersDesc",
        "blizzardHelpful",
        "blizzardHarmful",
        "blizzardPlayer",
        "excludePlayer",
        "blizzardRaid",
        "blizzardCancelable",
        "blizzardNotCancelable",
        "blizzardMaw",
        "specialFiltersDesc",
        "preCombatFilter",
        "permanentFilter",
        "consumableFilter",
        "filterWeaponEnchants",
        "auraGroupFiltersDesc",
        "showOnlyGroup",
        "excludeGroup",
        "headerAppearance",
        "auraSize",
        "columns",
        "growDirection",
        "headerPosition",
        "posX",
        "posY",
        "posAnchor"
    }
    
    -- Build args table by iterating through the sort order
    local args = {}
    for i, key in ipairs(sortOrder) do
        args[key] = GetOptionEntry(optionsMap[key], i)
    end
    
    return {
        name = "AuraBar " .. barIndex,
        type = "group",
        order = order,
        args = args
    }
end

--[[----------------------------------------------------------------------------
Options Table Generator
------------------------------------------------------------------------------]]
function AuraTracker.Options.GetOptionsTable()
    -- Initialize helper function references if not already done
    if not GetAuraBarConfig then
        InitializeHelpers()
    end
    
    -- Define all general option definitions in a map
    local generalOptionsMap = {
        headerGeneral = {
            name = "General Settings",
            type = "header"
        },
        hideOutOfCombat = {
            name = "Hide All Windows Out of Combat",
            desc = "Hide all aura windows when you are not in combat (overrides individual window settings).",
            type = "toggle",
            width = "full",
            get = function(info)
                return AuraTracker.db.profile.hideOutOfCombat
            end,
            set = function(info, value)
                AuraTracker.db.profile.hideOutOfCombat = value
                AuraTracker:UpdateAuraWindowVisibility()
            end
        },
        hideBlizzardBuffFrame = {
            name = "Hide Blizzard BuffFrame",
            desc = "Hide the default Blizzard buff frame (requires UI reload to take effect).",
            type = "toggle",
            width = "full",
            get = function(info)
                return AuraTracker.db.profile.hideBlizzardBuffFrame
            end,
            set = function(info, value)
                AuraTracker.db.profile.hideBlizzardBuffFrame = value
                AuraTracker:UpdateBlizzardBuffFrame()
            end
        },
        showArea = {
            name = "Show Area",
            desc = "Show a light blue background for each aurabar.",
            type = "toggle",
            width = "full",
            get = function(info)
                return AuraTracker.db.profile.showArea
            end,
            set = function(info, value)
                AuraTracker.db.profile.showArea = value
                AuraTracker:RecreateWindows()
            end
        }
    }
    
    -- Define the sort order for general options (list of option keys only)
    local generalSortOrder = {
        "headerGeneral",
        "hideOutOfCombat",
        "hideBlizzardBuffFrame",
        "showArea"
    }
    
    -- Build general args table by iterating through the sort order
    local generalArgs = {}
    for i, key in ipairs(generalSortOrder) do
        generalArgs[key] = GetOptionEntry(generalOptionsMap[key], i)
    end
    
    local options = {
        name = "AuraTracker",
        handler = AuraTracker.Options,
        type = "group",
        args = {
            general = {
                name = "General",
                type = "group",
                order = 1,
                args = generalArgs
            }
        }
    }

    -- Generate options for each AuraBar (1-5)
    for i = 1, 5 do
        options.args["aurabar" .. i] = GenerateAuraBarOptions(i, i + 1)
    end

    -- Add AuraGroups options tab
    options.args["auragroups"] = AuraTracker.AuraGroupsOptions.GenerateOptions()
    
    return options
end
