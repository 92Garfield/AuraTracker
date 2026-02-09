-- AuraGroupsOptions: Manage spell groups for AuraTracker
-- Author: Demonperson a.k.a. 92Garfield

local name, addon = ...

-- Namespace
AuraTracker.AuraGroupsOptions = {}

-- Local state
local selectedGroupKey = nil
local tempGroupName = ""
local tempSpellIds = ""

--[[----------------------------------------------------------------------------
Helper Functions
------------------------------------------------------------------------------]]

-- Get all aura groups
local function GetAuraGroups()
    if not AuraTracker.db then
        return {}
    end
    return AuraTracker.db.profile.auraGroups or {}
end

-- Get dropdown values for existing groups
local function GetGroupDropdownValues()
    local values = {
        ["__new__"] = "< Create New Group >"
    }
    
    local groups = GetAuraGroups()
    for key, group in pairs(groups) do
        values[key] = group.name or ("Group " .. key)
    end
    
    return values
end

-- Generate a new unique group key
local function GenerateNewGroupKey()
    local groups = GetAuraGroups()
    local count = 0
    
    for _ in pairs(groups) do
        count = count + 1
    end
    
    return "group_" .. (count + 1)
end

-- Get or create aura groups table
local function EnsureAuraGroupsTable()
    if not AuraTracker.db.profile.auraGroups then
        AuraTracker.db.profile.auraGroups = {}
    end
    return AuraTracker.db.profile.auraGroups
end

-- Save current group
local function SaveCurrentGroup()
    if not selectedGroupKey then
        return
    end
    
    local groups = EnsureAuraGroupsTable()
    
    -- Parse spell IDs from comma-separated string
    local spellIds = {}
    if tempSpellIds and tempSpellIds ~= "" then
        for id in string.gmatch(tempSpellIds, "([^,]+)") do
            local trimmed = string.match(id, "^%s*(.-)%s*$") -- trim whitespace
            local numId = tonumber(trimmed)
            if numId then
                table.insert(spellIds, numId)
            end
        end
    end
    
    groups[selectedGroupKey] = {
        name = tempGroupName,
        spellIds = spellIds
    }
    
    AuraTracker.db.profile.auraGroups = groups
end

-- Load group data into temp variables
local function LoadGroup(groupKey)
    selectedGroupKey = groupKey
    
    if groupKey == "__new__" then
        -- Create new group
        local newKey = GenerateNewGroupKey()
        local groups = GetAuraGroups()
        local count = 0
        for _ in pairs(groups) do
            count = count + 1
        end
        
        selectedGroupKey = newKey
        tempGroupName = "AuraGroup " .. (count + 1)
        tempSpellIds = ""
    else
        -- Load existing group
        local groups = GetAuraGroups()
        local group = groups[groupKey]
        
        if group then
            tempGroupName = group.name or ""
            
            -- Convert spell IDs array to comma-separated string
            if group.spellIds and #group.spellIds > 0 then
                tempSpellIds = table.concat(group.spellIds, ", ")
            else
                tempSpellIds = ""
            end
        else
            tempGroupName = ""
            tempSpellIds = ""
        end
    end
end

-- Delete current group
local function DeleteCurrentGroup()
    if not selectedGroupKey or selectedGroupKey == "__new__" then
        return
    end
    
    local groups = EnsureAuraGroupsTable()
    groups[selectedGroupKey] = nil
    
    -- Reset selection
    selectedGroupKey = nil
    tempGroupName = ""
    tempSpellIds = ""
end

--[[----------------------------------------------------------------------------
Options Generation
------------------------------------------------------------------------------]]

local function GenerateAuraGroupsOptions()
    return {
        name = "Aura Groups",
        type = "group",
        order = 7,
        args = {
            description = {
                name = "Create and manage spell ID groups for filtering auras.",
                type = "description",
                order = 1
            },
            groupSelector = {
                name = "Select Group",
                desc = "Select an existing group or create a new one.",
                type = "select",
                order = 2,
                width = 1.5,
                values = function()
                    return GetGroupDropdownValues()
                end,
                get = function(info)
                    return selectedGroupKey or "__new__"
                end,
                set = function(info, value)
                    LoadGroup(value)
                end
            },
            addButton = {
                name = "+",
                desc = "Create a new aura group.",
                type = "execute",
                order = 3,
                width = 0.3,
                func = function()
                    LoadGroup("__new__")
                end
            },
            spacer1 = {
                name = "",
                type = "description",
                order = 4,
                width = "full"
            },
            groupDetails = {
                name = "Group Details",
                type = "group",
                order = 5,
                inline = true,
                hidden = function()
                    return selectedGroupKey == nil
                end,
                args = {
                    groupName = {
                        name = "Group Name",
                        desc = "Name for this aura group.",
                        type = "input",
                        order = 1,
                        width = "full",
                        get = function(info)
                            return tempGroupName
                        end,
                        set = function(info, value)
                            tempGroupName = value
                        end
                    },
                    spellIds = {
                        name = "Spell IDs (comma-separated)",
                        desc = "Enter spell IDs separated by commas. Example: 12345, 67890, 11223",
                        type = "input",
                        order = 2,
                        width = "full",
                        multiline = 8,
                        get = function(info)
                            return tempSpellIds
                        end,
                        set = function(info, value)
                            tempSpellIds = value
                        end
                    },
                    spacer = {
                        name = "",
                        type = "description",
                        order = 3
                    },
                    saveButton = {
                        name = "Save Group",
                        desc = "Save changes to this group.",
                        type = "execute",
                        order = 4,
                        width = 1,
                        func = function()
                            SaveCurrentGroup()
                            print("AuraTracker: Group saved successfully!")
                        end
                    },
                    deleteButton = {
                        name = "Delete Group",
                        desc = "Delete this group permanently.",
                        type = "execute",
                        order = 5,
                        width = 1,
                        confirm = true,
                        confirmText = "Are you sure you want to delete this group?",
                        func = function()
                            DeleteCurrentGroup()
                            print("AuraTracker: Group deleted.")
                        end
                    }
                }
            }
        }
    }
end

-- Export the options generator
AuraTracker.AuraGroupsOptions.GenerateOptions = GenerateAuraGroupsOptions
