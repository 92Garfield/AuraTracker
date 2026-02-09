-- AuraFilter: Aura filtering logic
-- Author: Demonperson a.k.a. 92Garfield

-- Namespace
if not AuraTracker then
    AuraTracker = {}
end

AuraTracker.AuraFilter = {}

-- Tracking tables for special filters
local preCombatAuras = {}
local permanentAuras = {}
local consumableAuras = {}
local auraGroupMembership = {}  -- [auraInstanceID] = { [groupKey] = true }
local lastOutOfCombat = nil

--[[----------------------------------------------------------------------------
Aura Type Detection Functions
------------------------------------------------------------------------------]]

-- Check if aura is permanent or long-duration (>5 hours or infinite)
function AuraTracker.AuraFilter.IsPermanentAura(auraInfo)
    if auraInfo.duration < 0 or auraInfo.duration == 0 or auraInfo.duration > 5 * 60 * 60 then
        return true
    end
    return false
end

-- Check if aura is consumable (food, flasks, etc - typically 2-300 minutes)
function AuraTracker.AuraFilter.IsConsumableAura(auraInfo)
    if auraInfo.duration > 2 * 60 and auraInfo.duration <= 5 * 60 * 60 then
        return true
    end
    return false
end

--[[----------------------------------------------------------------------------
Tracking Functions
------------------------------------------------------------------------------]]

-- Update tracking tables when out of combat
function AuraTracker.AuraFilter.UpdateTracking(auraInfo, inCombat, currentTime)
    if not inCombat then
        -- Reset tracking at start of new out-of-combat period
        if not lastOutOfCombat then
            preCombatAuras = {}
            permanentAuras = {}
            consumableAuras = {}
            auraGroupMembership = {}
        end
        lastOutOfCombat = currentTime
        
        -- Track pre-combat auras when out of combat
        if auraInfo.icon then
            preCombatAuras[auraInfo.auraInstanceID] = {
                timestamp = currentTime,
                auraInfo = auraInfo
            }

            -- Track permanent auras
            if AuraTracker.AuraFilter.IsPermanentAura(auraInfo) then
                permanentAuras[auraInfo.auraInstanceID] = true
            end
            
            -- Track consumable auras
            if AuraTracker.AuraFilter.IsConsumableAura(auraInfo) then
                consumableAuras[auraInfo.auraInstanceID] = true
            end
        end

        -- Track AuraGroup membership (both in and out of combat)
        if auraInfo.spellId and AuraTracker.db and AuraTracker.db.profile.auraGroups then
            if not auraGroupMembership[auraInfo.auraInstanceID] then
                auraGroupMembership[auraInfo.auraInstanceID] = {}
            end

            -- Check membership in all groups
            for groupKey, group in pairs(AuraTracker.db.profile.auraGroups) do
                if group.spellIds then
                    for _, spellId in ipairs(group.spellIds) do
                        if spellId == auraInfo.spellId then
                            auraGroupMembership[auraInfo.auraInstanceID][groupKey] = true
                            break
                        end
                    end
                end
            end
        end

    else
        lastOutOfCombat = nil
    end
end

-- Clear all tracking tables
function AuraTracker.AuraFilter.ClearTracking()
    preCombatAuras = {}
    permanentAuras = {}
    consumableAuras = {}
    auraGroupMembership = {}
    lastOutOfCombat = nil
end

--[[----------------------------------------------------------------------------
Filter Application Functions
------------------------------------------------------------------------------]]

-- Apply pre-combat filter
function AuraTracker.AuraFilter.ApplyPreCombatFilter(auraInfo, filterMode)
    if not filterMode then
        return true
    end
    
    local isPreCombat = preCombatAuras[auraInfo.auraInstanceID] ~= nil
    
    if filterMode == AuraTracker.FilterMode.INCLUDE then
        return isPreCombat
    elseif filterMode == AuraTracker.FilterMode.EXCLUDE then
        return not isPreCombat
    end
    
    return true
end

-- Apply permanent filter
function AuraTracker.AuraFilter.ApplyPermanentFilter(auraInfo, filterMode)
    if not filterMode then
        return true
    end
    
    local isPermanent = permanentAuras[auraInfo.auraInstanceID] ~= nil
    
    if filterMode == AuraTracker.FilterMode.INCLUDE then
        return isPermanent
    elseif filterMode == AuraTracker.FilterMode.EXCLUDE then
        return not isPermanent
    end
    
    return true
end

function AuraTracker.AuraFilter.IsTaggedPermanent(auraInfo)
    return permanentAuras[auraInfo.auraInstanceID] ~= nil
end

-- Apply consumable filter
function AuraTracker.AuraFilter.ApplyConsumableFilter(auraInfo, filterMode)
    if not filterMode then
        return true
    end
    
    local isConsumable = consumableAuras[auraInfo.auraInstanceID] ~= nil
    
    if filterMode == AuraTracker.FilterMode.INCLUDE then
        return isConsumable
    elseif filterMode == AuraTracker.FilterMode.EXCLUDE then
        return not isConsumable
    end
    
    return true
end

-- Apply all special filters to an aura
function AuraTracker.AuraFilter.ApplySpecialFilters(auraInfo, preCombatMode, permanentMode, consumableMode)
    if not AuraTracker.AuraFilter.ApplyPreCombatFilter(auraInfo, preCombatMode) then
        return false
    end
    
    if not AuraTracker.AuraFilter.ApplyPermanentFilter(auraInfo, permanentMode) then
        return false
    end
    
    if not AuraTracker.AuraFilter.ApplyConsumableFilter(auraInfo, consumableMode) then
        return false
    end
    
    return true
end

--[[----------------------------------------------------------------------------
AuraGroup Filter Functions
------------------------------------------------------------------------------]]

-- Check if an aura is in a specific aura group (using tracked membership)
function AuraTracker.AuraFilter.IsAuraInGroup(auraInfo, groupKey)
    if not groupKey or not auraInfo.auraInstanceID then
        return false
    end
    
    local membership = auraGroupMembership[auraInfo.auraInstanceID]
    if not membership then
        return false
    end
    
    return membership[groupKey] == true
end

-- Apply show only group filter
function AuraTracker.AuraFilter.ApplyShowOnlyGroupFilter(auraInfo, groupKey)
    if not groupKey then
        return true
    end
    
    return AuraTracker.AuraFilter.IsAuraInGroup(auraInfo, groupKey)
end

-- Apply exclude group filter
function AuraTracker.AuraFilter.ApplyExcludeGroupFilter(auraInfo, groupKey)
    if not groupKey then
        return true
    end
    
    return not AuraTracker.AuraFilter.IsAuraInGroup(auraInfo, groupKey)
end

--[[----------------------------------------------------------------------------
Weapon Enchant Functions
------------------------------------------------------------------------------]]

-- Add weapon enchants to the aura list
function AuraTracker.AuraFilter.AddWeaponEnchants(filteredAuras, inCombat, currentTime, preCombatMode, permanentMode, consumableMode)
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID,
          hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID = GetWeaponEnchantInfo()
    
    -- Process main hand enchant
    if hasMainHandEnchant and mainHandEnchantID then
        local enchantAura = AuraTracker.AuraFilter.CreateWeaponEnchantAura(
            mainHandEnchantID,
            mainHandExpiration,
            mainHandCharges,
            "mainhand",
            inCombat,
            currentTime
        )
        
        if enchantAura and AuraTracker.AuraFilter.ApplySpecialFilters(enchantAura, preCombatMode, permanentMode, consumableMode) then
            table.insert(filteredAuras, enchantAura)
        end
    end
    
    -- Process off hand enchant
    if hasOffHandEnchant and offHandEnchantID then
        local enchantAura = AuraTracker.AuraFilter.CreateWeaponEnchantAura(
            offHandEnchantID,
            offHandExpiration,
            offHandCharges,
            "offhand",
            inCombat,
            currentTime
        )
        
        if enchantAura and AuraTracker.AuraFilter.ApplySpecialFilters(enchantAura, preCombatMode, permanentMode, consumableMode) then
            table.insert(filteredAuras, enchantAura)
        end
    end
end

-- Create an aura-like structure for weapon enchants
function AuraTracker.AuraFilter.CreateWeaponEnchantAura(enchantID, expiration, charges, slot, inCombat, currentTime)
    -- Get icon for the enchant using the enchant ID
    -- local icon, originalIcon = C_Spell.GetSpellTexture(enchantID)
    local itemsSlot = 16
    if slot == "offhand" then
        itemsSlot = 17
    end

    local itemID = GetInventoryItemID("player", itemsSlot)
    local _, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)


    if not icon then
        return nil
    end
    
    -- Convert expiration from milliseconds to seconds
    local expirationTime = GetTime() + (expiration / 1000)
    local duration = expiration / 1000
    
    -- Create a unique aura instance ID for the weapon enchant
    local auraInstanceID = "weaponenchant_" .. slot
    
    -- Create aura-like structure matching C_UnitAuras.GetAuraDataByIndex format
    local enchantAura = {
        auraInstanceID = auraInstanceID,
        spellId = itemID,
        name = "Weapon Enchant (" .. slot .. ")",
        icon = icon,
        applications = charges or 0,
        duration = duration,
        expirationTime = expirationTime,
        -- Additional fields for compatibility
        isHelpful = true,
        isHarmful = false,
        canApplyAura = false,
        isBossAura = false,
        isFromPlayerOrPlayerPet = true,
        nameplateShowAll = false,
        nameplateShowPersonal = false,
        timeMod = 1,
        points = {},
        -- Mark as weapon enchant for special handling
        isWeaponEnchant = true,

        itemSlot = itemsSlot,
    }
    
    -- Update tracking - always tag as consumable regardless of duration
    AuraTracker.AuraFilter.UpdateTracking(enchantAura, inCombat, currentTime)

    return enchantAura
end

--[[----------------------------------------------------------------------------
Main Filtering Function
------------------------------------------------------------------------------]]

-- Get filtered auras based on filter configuration
-- filters = {
--     blizzard = { "HELPFUL", "HARMFUL", "PLAYER", "RAID", "CANCELABLE", "NOT_CANCELABLE", "MAW" },
--     preCombat = "INCLUDE" or "EXCLUDE" or nil,
--     permanent = "INCLUDE" or "EXCLUDE" or nil,
--     consumable = "INCLUDE" or "EXCLUDE" or nil,
--     excludePlayer = true or nil,
--     showOnlyGroup = groupKey or nil,
--     excludeGroup = groupKey or nil,
--     weaponEnchants = true or nil
-- }
function AuraTracker.AuraFilter.GetFilteredAuras(filters)
    local filteredAuras = {}
    local inCombat = AuraTracker.AuraFilter.ImInCombat()
    local currentTime = GetTime()

    -- Get filter configuration
    local blizzardFilters = filters.blizzard or { "HELPFUL" }
    local preCombatMode = filters.preCombat
    local permanentMode = filters.permanent
    local consumableMode = filters.consumable
    local excludePlayer = filters.excludePlayer
    local showOnlyGroup = filters.showOnlyGroup
    local excludeGroup = filters.excludeGroup
    local weaponEnchants = filters.weaponEnchants

    -- Concatenate blizzard filters with | separator
    local filterString = table.concat(blizzardFilters, "|")

    -- If excludePlayer is enabled, we need to query twice and compare
    local playerAuraInstanceIDs = {}
    if excludePlayer then
        -- First query: with PLAYER filter to get player-cast auras
        local playerFilterString = filterString .. "|PLAYER"
        for i = 1, 40 do
            local auraInfo = C_UnitAuras.GetAuraDataByIndex("player", i, playerFilterString)
            if not auraInfo then
                break
            end
            -- Store player-cast aura instance IDs
            playerAuraInstanceIDs[auraInfo.auraInstanceID] = true
        end
    end

    -- Query auras from Blizzard API
    for i = 1, 40 do
        local auraInfo = C_UnitAuras.GetAuraDataByIndex("player", i, filterString)

        if not auraInfo then
            break
        end

        -- If excludePlayer is enabled, skip auras that were in the player filter results
        if excludePlayer and (playerAuraInstanceIDs[auraInfo.auraInstanceID]) then
            -- Skip this aura as it's player-cast
        else
            -- Store index and filter string for cancel functionality
            auraInfo.auraIndex = i
            auraInfo.filterString = filterString

            -- Update tracking
            AuraTracker.AuraFilter.UpdateTracking(auraInfo, inCombat, currentTime)

            -- Apply special filters
            if AuraTracker.AuraFilter.ApplySpecialFilters(auraInfo, preCombatMode, permanentMode, consumableMode) then
                -- Apply AuraGroup filters
                if AuraTracker.AuraFilter.ApplyShowOnlyGroupFilter(auraInfo, showOnlyGroup) and
                    AuraTracker.AuraFilter.ApplyExcludeGroupFilter(auraInfo, excludeGroup) then
                    table.insert(filteredAuras, auraInfo)
                end
            end
        end
    end

    -- Add weapon enchants if filtering for helpful buffs and weapon enchants filter is enabled
    if filterString:find("HELPFUL") and not excludePlayer and weaponEnchants then
        AuraTracker.AuraFilter.AddWeaponEnchants(filteredAuras, inCombat, currentTime, preCombatMode, permanentMode,
            consumableMode)
    end

    return filteredAuras
end

function AuraTracker.AuraFilter.ImInCombat()
    local auraData = C_UnitAuras.GetAuraDataByIndex("player", 1, "HELPFUL")

    if not auraData then
        return true
    end

    return issecretvalue(auraData.spellId)
end