-- AuraWindowType: Filter system for aura windows
-- Author: Demonperson a.k.a. 92Garfield

-- Namespace
if not AuraTracker then
    AuraTracker = {}
end

-- Blizzard filter types (query types from API)
AuraTracker.BlizzardFilterType = {
    HARMFUL = "HARMFUL",
    HELPFUL = "HELPFUL",
    PLAYER = "PLAYER",
    RAID = "RAID",
    CANCELABLE = "CANCELABLE",
    NOT_CANCELABLE = "NOT_CANCELABLE",
    MAW = "MAW"
}

-- Filter mode for special filters
AuraTracker.FilterMode = {
    INCLUDE = "INCLUDE",  -- Only show auras matching this filter
    EXCLUDE = "EXCLUDE"   -- Hide auras matching this filter
}
