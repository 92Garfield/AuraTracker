-- AuraTrackerOptionsDefaults: Default configuration for AuraTracker
-- Author: Demonperson a.k.a. 92Garfield

local name, addon = ...

-- Namespace
AuraTracker.OptionsDefaults = {}

--[[----------------------------------------------------------------------------
Defaults
------------------------------------------------------------------------------]]
local defaults = {
    profile = {
        enabled = true,
        hideOutOfCombat = false,
        hideBlizzardBuffFrame = false,
        showArea = false,
        auraGroups = {},
        auraBars = {
            [1] = {
                name = "AuraBar 1",
                enabled = true,
                showInCombat = false,
                position = { point = "CENTER", x = 0, y = 0 },
                auraSize = 30,
                columns = 10,
                growDirection = "RIGHT",
                showTooltips = true,
                -- Blizzard filter flags (individual booleans)
                filterHelpful = true,
                filterHarmful = nil,
                filterPlayer = nil,
                excludePlayer = nil,  -- Exclude player-cast auras
                filterRaid = nil,
                filterCancelable = nil,
                filterNotCancelable = nil,
                filterMaw = nil,
                -- Special filters
                preCombatFilter = nil,  -- nil, "INCLUDE", or "EXCLUDE"
                permanentFilter = nil,  -- nil, "INCLUDE", or "EXCLUDE"
                consumableFilter = nil,  -- nil, "INCLUDE", or "EXCLUDE"
                -- AuraGroup filters
                showOnlyGroup = nil,  -- Show only auras from this group
                excludeGroup = nil,  -- Exclude auras from this group
                -- Weapon enchants
                filterWeaponEnchants = nil  -- Show weapon enchants
            },
            [2] = {
                name = "AuraBar 2",
                enabled = false,
                showInCombat = false,
                position = { point = "CENTER", x = 0, y = 100 },
                auraSize = 30,
                columns = 10,
                growDirection = "RIGHT",
                showTooltips = true,
                filterHelpful = nil,
                filterHarmful = true,
                filterPlayer = nil,
                excludePlayer = nil,
                filterRaid = nil,
                filterCancelable = nil,
                filterNotCancelable = nil,
                filterMaw = nil,
                preCombatFilter = nil,
                permanentFilter = nil,
                consumableFilter = nil,
                showOnlyGroup = nil,
                excludeGroup = nil,
                filterWeaponEnchants = nil
            },
            [3] = {
                name = "AuraBar 3",
                enabled = false,
                showInCombat = false,
                position = { point = "CENTER", x = 0, y = -100 },
                auraSize = 30,
                columns = 8,
                growDirection = "RIGHT",
                showTooltips = true,
                filterHelpful = true,
                filterHarmful = true,
                filterPlayer = nil,
                excludePlayer = nil,
                filterRaid = nil,
                filterCancelable = nil,
                filterNotCancelable = nil,
                filterMaw = nil,
                preCombatFilter = nil,
                permanentFilter = nil,
                consumableFilter = nil,
                showOnlyGroup = nil,
                excludeGroup = nil,
                filterWeaponEnchants = nil
            },
            [4] = {
                name = "AuraBar 4",
                enabled = false,
                showInCombat = true,
                position = { point = "CENTER", x = 0, y = 200 },
                auraSize = 40,
                columns = 5,
                growDirection = "RIGHT",
                showTooltips = true,
                filterHelpful = nil,
                filterHarmful = true,
                filterPlayer = nil,
                excludePlayer = nil,
                filterRaid = nil,
                filterCancelable = nil,
                filterNotCancelable = nil,
                filterMaw = nil,
                preCombatFilter = nil,
                permanentFilter = nil,
                consumableFilter = nil,
                showOnlyGroup = nil,
                excludeGroup = nil,
                filterWeaponEnchants = nil
            },
            [5] = {
                name = "AuraBar 5",
                enabled = false,
                showInCombat = false,
                position = { point = "CENTER", x = 0, y = -200 },
                auraSize = 30,
                columns = 8,
                growDirection = "RIGHT",
                showTooltips = true,
                filterHelpful = true,
                filterHarmful = nil,
                filterPlayer = nil,
                excludePlayer = nil,
                filterRaid = nil,
                filterCancelable = nil,
                filterNotCancelable = nil,
                filterMaw = nil,
                preCombatFilter = "EXCLUDE",
                permanentFilter = "EXCLUDE",
                consumableFilter = nil,
                showOnlyGroup = nil,
                excludeGroup = nil,
                filterWeaponEnchants = nil
            }
        }
    }
}

-- Export defaults
AuraTracker.OptionsDefaults.defaults = defaults
