-- FormatNumber: Number formatting utilities
-- Author: Demonperson a.k.a. 92Garfield

-- Namespace
if not AuraTracker then
    AuraTracker = {}
end

AuraTracker.FormatNumber = {}

--[[----------------------------------------------------------------------------
Countdown Time Formatting
------------------------------------------------------------------------------]]

-- Create abbreviation configuration for countdown timers
local function CreateCountdownConfig()
    return CreateAbbreviateConfig({
        {
            -- breakpoint = 24 * 60 * 60, -- 24 hours
            breakpoint = 100000, -- ~~~24 hours
            abbreviation = "d",
            significandDivisor = 24 * 60 * 60,
            fractionDivisor = 1,
            abbreviationIsGlobal = false
        }, {
            -- breakpoint = 99 * 60, -- 99 minutes
            breakpoint = 10000, -- ~~~160 minutes
            abbreviation = "h",
            significandDivisor = 60 * 60,
            fractionDivisor = 1,
            abbreviationIsGlobal = false
        }, {
            -- breakpoint = 5 * 60, -- 5 minutes
            breakpoint = 1000, -- ~~~16 minutes
            abbreviation = "m",
            significandDivisor = 60,
            fractionDivisor = 1,
            abbreviationIsGlobal = false
        }, {
            breakpoint = 100, --
            abbreviation = "",
            significandDivisor = 1,
            fractionDivisor = 1,
            abbreviationIsGlobal = false
        }, {
            breakpoint = 10,
            abbreviation = "",
            significandDivisor = 1,
            fractionDivisor = 1,
            abbreviationIsGlobal = false
        }, {
            breakpoint = 1,
            abbreviation = "",
            significandDivisor = 1/10,
            fractionDivisor = 10,
            abbreviationIsGlobal = false
        }
    })

    --return CreateAbbreviateConfig({
    --    {
    --        breakpoint = 100,     -- 24 hours
    --        abbreviation = "d",
    --        significandDivisor = 60,
    --        fractionDivisor = 1,
    --        abbreviationIsGlobal = false
    --    }
    --})
end

local function CreateBooleanConfig(breakpoint)
    print("Creating boolean config with breakpoint " .. tostring(breakpoint))

    return CreateAbbreviateConfig({
        {
            breakpoint = breakpoint,
            abbreviation = "",
            significandDivisor = 1e308,
            fractionDivisor = 1,
            abbreviationIsGlobal = false
        },
        {
            breakpoint = 10,
            abbreviation = "",
            significandDivisor = 1,
            fractionDivisor = 1,
            abbreviationIsGlobal = false
        }
    })
end

-- Cache the countdown config
local countdownConfig = nil
local booleanConfigs = {}

-- Format seconds as countdown string (e.g., "2.5h", "45m", "30s")
-- Uses WoW's AbbreviateNumbers function with custom config for time formatting
--
-- Examples:
--   252000 (70 hours)  -> "2d"
--   82800 (23 hours)   -> "23h"
--   18000 (5 hours)    -> "5h"
--   9000 (2.5 hours)   -> "2h"
--   5400 (1.5 hours)   -> "1h"
--   5400 (45 minutes)  -> "45m"
--   1200 (20 minutes)  -> "20m"
--   360 (6 minutes)    -> "6m"
--   90 (90 seconds)    -> "90"
--   30 (30 seconds)    -> "30"
--   5 (5 seconds)      -> "5"
function AuraTracker.FormatNumber.Countdown(seconds)
    -- Initialize config on first use
    if not countdownConfig then
        countdownConfig = CreateCountdownConfig()
    end

    -- Use WoW's AbbreviateNumbers with our custom config
    return AbbreviateNumbers(seconds, { config = countdownConfig })
end

function AuraTracker.FormatNumber.Boolean(value, breakpoint)
    -- Get or create the boolean config for this breakpoint
    local config = booleanConfigs[breakpoint]
    if not config then
        config = CreateBooleanConfig(breakpoint)
        booleanConfigs[breakpoint] = config
    end

    -- Use WoW's AbbreviateNumbers with our custom config
    return AbbreviateNumbers(value, { config = config })
end