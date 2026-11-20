-- Framme Creation
local EventsFrame = CreateFrame("Frame", "AddonLoadEventFrame")

-- Properties
local bIsInCombat = false;
local bIsLoaded = false
local ScanTimerRate = 0.1
MaxNameplatestAmount = 40

-- Resets Aggro properties
local function ResetAggro()
    bIsInCombat = false;
end

-- Scans visible nameplates (up to MaxNameplatestAmount) and checks if the associated Unit is an Enemy and its status agains the Player
local function ScanVisibleEnemies()
    local foundEnemies = {}
    for nameplateIterator = 1, MaxNameplatestAmount do
        local unit = "nameplate" .. nameplateIterator
        if UnitExists(unit) and UnitCanAttack("player", unit) then
            local status = UnitThreatSituation("player", unit)
            if not issecretvalue(unit) and status ~= nil then
                local unitGUID = UnitGUID(unit)
                if not issecretvalue(unitGUID) and unitGUID ~= nil then
                    foundEnemies[unitGUID] = {
                        Unit = unit,
                        Name = UnitName(unit),
                        ThreatStatus = status
                    }
                end
            end
        end
    end
    return foundEnemies
end

-- If combat is still going, scans for enemies
local function OnScanTimer()
    -- Checks if were are still in combat
    if bIsInCombat then
        C_Timer.After(ScanTimerRate, OnScanTimer)
    end
    local AggroedEnemies = ScanVisibleEnemies()
    UpdateScrollData(AggroedEnemies)
end

-- Event listener function
function EventsFrame:OnEvent(event, ...)
    self[event](self, event, ...)
end

-- Listens to when the AddonLoaded event fires
function EventsFrame:ADDON_LOADED(event, addOnName)
    if not bIsLoaded then
        print(event, addOnName)
        bIsLoaded = true
    end
end

-- Listens to the event where the Player's Regen is disabled, meaning, combat has started
function EventsFrame:PLAYER_REGEN_DISABLED(event)
    bIsInCombat = true;
    OnScanTimer()
end

-- Listens to the event where the Player's Regen is enabled, meaning, combat has finished
function EventsFrame:PLAYER_REGEN_ENABLED(event)
    ResetAggro()
end

-- TODO: Listen to Player Death events to also stop scanning?

-- Frame Events register
EventsFrame:RegisterEvent("ADDON_LOADED")
EventsFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
EventsFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
EventsFrame:SetScript("OnEvent", EventsFrame.OnEvent)