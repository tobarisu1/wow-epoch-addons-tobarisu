-- MeterMaid - Simple and elegant damage/threat meter
-- Clean, translucent, movable window with tabbed interface

local addonName, MeterMaid = ...
local L = MeterMaidL or {}

-- Initialize saved variables
MeterMaidDB = MeterMaidDB or {
    enabled = false,
    windowPosition = {x = 0, y = 0},
    windowSize = {width = 250, height = 200},
    opacity = 0.8,
    showDamage = true,
    showThreat = true,
    maxEntries = 10,
    autoStart = false,
    autoStop = true
}

-- Class colors (WoW 3.3.5a colors)
local CLASS_COLORS = {
    ["WARRIOR"] = {r = 0.78, g = 0.61, b = 0.43},
    ["PALADIN"] = {r = 0.96, g = 0.55, b = 0.73},
    ["HUNTER"] = {r = 0.67, g = 0.83, b = 0.45},
    ["ROGUE"] = {r = 1.00, g = 0.96, b = 0.41},
    ["PRIEST"] = {r = 1.00, g = 1.00, b = 1.00},
    ["DEATHKNIGHT"] = {r = 0.77, g = 0.12, b = 0.23},
    ["SHAMAN"] = {r = 0.00, g = 0.44, b = 0.87},
    ["MAGE"] = {r = 0.41, g = 0.80, b = 0.94},
    ["WARLOCK"] = {r = 0.58, g = 0.51, b = 0.79},
    ["DRUID"] = {r = 1.00, g = 0.49, b = 0.04},
    ["MONSTER"] = {r = 0.80, g = 0.80, b = 0.80},
    ["NPC"] = {r = 0.90, g = 0.90, b = 0.90}
}

-- Data storage
local damageData = {}
local threatData = {}
local combatStartTime = 0
local combatEndTime = 0
local inCombat = false
local currentTab = "damage"

-- Player class cache
local playerClasses = {}

-- Main window frame
local mainFrame = nil
local damageTab = nil
local threatTab = nil
local damageContent = nil
local threatContent = nil

-- Utility functions
local function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fm", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fk", num / 1000)
    else
        return tostring(num)
    end
end

local function FormatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", minutes, secs)
end

local function GetCombatTime()
    if not inCombat then return 0 end
    return GetTime() - combatStartTime
end

local function GetClassColor(playerName)
    -- Check if we have cached class info
    if playerClasses[playerName] then
        local class = playerClasses[playerName]
        if CLASS_COLORS[class] then
            return CLASS_COLORS[class]
        end
    end
    
    -- Try to get class from raid/party members
    for i = 1, GetNumRaidMembers() do
        local name, _, _, _, class = GetRaidRosterInfo(i)
        if name == playerName then
            playerClasses[playerName] = class
            if CLASS_COLORS[class] then
                return CLASS_COLORS[class]
            end
        end
    end
    
    for i = 1, GetNumPartyMembers() do
        local unit = "party" .. i
        local name = UnitName(unit)
        if name == playerName then
            local _, class = UnitClass(unit)
            playerClasses[playerName] = class
            if CLASS_COLORS[class] then
                return CLASS_COLORS[class]
            end
        end
    end
    
    -- Check if it's the player
    if playerName == UnitName("player") then
        local _, class = UnitClass("player")
        playerClasses[playerName] = class
        if CLASS_COLORS[class] then
            return CLASS_COLORS[class]
        end
    end
    
    -- Default color for unknown players
    return CLASS_COLORS["MONSTER"]
end

local function ResetData()
    damageData = {}
    threatData = {}
    combatStartTime = 0
    combatEndTime = 0
    inCombat = false
    playerClasses = {} -- Clear class cache
end

local function StartCombat()
    if not inCombat then
        inCombat = true
        combatStartTime = GetTime()
        ResetData()
    end
end

local function StopCombat()
    if inCombat then
        inCombat = false
        combatEndTime = GetTime()
    end
end

local function AddDamage(sourceName, amount)
    if not damageData[sourceName] then
        damageData[sourceName] = {total = 0, hits = 0}
    end
    damageData[sourceName].total = damageData[sourceName].total + amount
    damageData[sourceName].hits = damageData[sourceName].hits + 1
end

local function AddThreat(sourceName, amount)
    if not threatData[sourceName] then
        threatData[sourceName] = {total = 0, events = 0}
    end
    threatData[sourceName].total = threatData[sourceName].total + amount
    threatData[sourceName].events = threatData[sourceName].events + 1
end

local function SortData(data, key)
    local sorted = {}
    for name, info in pairs(data) do
        table.insert(sorted, {name = name, info = info})
    end
    table.sort(sorted, function(a, b) return a.info[key] > b.info[key] end)
    return sorted
end

local function CreateMainWindow()
    if mainFrame then return mainFrame end
    
    -- Main frame
    mainFrame = CreateFrame("Frame", "MeterMaidMainFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(MeterMaidDB.windowSize.width, MeterMaidDB.windowSize.height)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", MeterMaidDB.windowPosition.x, MeterMaidDB.windowPosition.y)
    mainFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 8, right = 8, top = 8, bottom = 8}
    })
    mainFrame:SetBackdropColor(0, 0, 0, MeterMaidDB.opacity)
    mainFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        MeterMaidDB.windowPosition.x = x
        MeterMaidDB.windowPosition.y = y
    end)
    
    -- Title bar
    local titleBar = CreateFrame("Frame", nil, mainFrame)
    titleBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 8, -8)
    titleBar:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -8, -8)
    titleBar:SetHeight(20)
    
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 0, 0)
    titleText:SetText(L["ADDON_NAME"])
    titleText:SetTextColor(1, 1, 1)
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", 0, 0)
    closeButton:SetScript("OnClick", function()
        MeterMaidDB.enabled = false
        mainFrame:Hide()
    end)
    
    -- Tab buttons
    damageTab = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    damageTab:SetSize(80, 20)
    damageTab:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12, -32)
    damageTab:SetText(L["DAMAGE_TAB"])
    damageTab:SetScript("OnClick", function()
        currentTab = "damage"
        UpdateDisplay()
    end)
    
    threatTab = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    threatTab:SetSize(80, 20)
    threatTab:SetPoint("TOPLEFT", damageTab, "TOPRIGHT", 5, 0)
    threatTab:SetText(L["THREAT_TAB"])
    threatTab:SetScript("OnClick", function()
        currentTab = "threat"
        UpdateDisplay()
    end)
    
    -- Content area
    local contentArea = CreateFrame("Frame", nil, mainFrame)
    contentArea:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12, -60)
    contentArea:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -12, 12)
    
    -- Damage content
    damageContent = CreateFrame("Frame", nil, contentArea)
    damageContent:SetAllPoints()
    
    local damageTitle = damageContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    damageTitle:SetPoint("TOPLEFT", damageContent, "TOPLEFT", 0, 0)
    damageTitle:SetText(L["DAMAGE_DONE"])
    damageTitle:SetTextColor(1, 1, 0)
    
    local damageList = CreateFrame("Frame", nil, damageContent)
    damageList:SetPoint("TOPLEFT", damageContent, "TOPLEFT", 0, -20)
    damageList:SetPoint("BOTTOMRIGHT", damageContent, "BOTTOMRIGHT", 0, 0)
    
    -- Threat content
    threatContent = CreateFrame("Frame", nil, contentArea)
    threatContent:SetAllPoints()
    threatContent:Hide()
    
    local threatTitle = threatContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    threatTitle:SetPoint("TOPLEFT", threatContent, "TOPLEFT", 0, 0)
    threatTitle:SetText(L["THREAT_GENERATED"])
    threatTitle:SetTextColor(1, 1, 0)
    
    local threatList = CreateFrame("Frame", nil, threatContent)
    threatList:SetPoint("TOPLEFT", threatContent, "TOPLEFT", 0, -20)
    threatList:SetPoint("BOTTOMRIGHT", threatContent, "BOTTOMRIGHT", 0, 0)
    
    -- Control buttons
    local resetButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    resetButton:SetSize(60, 20)
    resetButton:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 12, 12)
    resetButton:SetText(L["RESET_DATA"])
    resetButton:SetScript("OnClick", function()
        ResetData()
        UpdateDisplay()
    end)
    
    -- Store references
    mainFrame.damageList = damageList
    mainFrame.threatList = threatList
    mainFrame.damageTitle = damageTitle
    mainFrame.threatTitle = threatTitle
    
    return mainFrame
end

local function UpdateDisplay()
    if not mainFrame or not MeterMaidDB.enabled then return end
    
    local combatTime = GetCombatTime()
    local timeText = combatTime > 0 and FormatTime(combatTime) or "00:00"
    
    -- Update titles with combat time
    mainFrame.damageTitle:SetText(L["DAMAGE_DONE"] .. " (" .. timeText .. ")")
    mainFrame.threatTitle:SetText(L["THREAT_GENERATED"] .. " (" .. timeText .. ")")
    
    -- Clear existing entries
    for i = 1, MeterMaidDB.maxEntries do
        local damageEntry = _G["MeterMaidDamageEntry" .. i]
        local threatEntry = _G["MeterMaidThreatEntry" .. i]
        if damageEntry then damageEntry:Hide() end
        if threatEntry then threatEntry:Hide() end
    end
    
    -- Show appropriate content
    if currentTab == "damage" then
        damageContent:Show()
        threatContent:Hide()
        
        -- Update damage entries
        local sortedDamage = SortData(damageData, "total")
        for i = 1, math.min(#sortedDamage, MeterMaidDB.maxEntries) do
            local entry = sortedDamage[i]
            local entryFrame = _G["MeterMaidDamageEntry" .. i]
            
            if not entryFrame then
                entryFrame = CreateFrame("Frame", "MeterMaidDamageEntry" .. i, mainFrame.damageList)
                entryFrame:SetHeight(16)
                entryFrame:SetPoint("TOPLEFT", mainFrame.damageList, "TOPLEFT", 0, -(i-1) * 16)
                entryFrame:SetPoint("TOPRIGHT", mainFrame.damageList, "TOPRIGHT", 0, -(i-1) * 16)
                
                local nameText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                nameText:SetPoint("LEFT", entryFrame, "LEFT", 0, 0)
                nameText:SetJustifyH("LEFT")
                nameText:SetTextColor(1, 1, 1)
                
                local totalText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                totalText:SetPoint("RIGHT", entryFrame, "RIGHT", -40, 0)
                totalText:SetJustifyH("RIGHT")
                totalText:SetTextColor(1, 1, 1)
                
                local dpsText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                dpsText:SetPoint("RIGHT", entryFrame, "RIGHT", 0, 0)
                dpsText:SetJustifyH("RIGHT")
                dpsText:SetTextColor(0.8, 0.8, 0.8)
                
                entryFrame.nameText = nameText
                entryFrame.totalText = totalText
                entryFrame.dpsText = dpsText
            end
            
            local dps = combatTime > 0 and (entry.info.total / combatTime) or 0
            local classColor = GetClassColor(entry.name)
            
            entryFrame.nameText:SetText(i .. ". " .. entry.name)
            entryFrame.nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
            entryFrame.totalText:SetText(FormatNumber(entry.info.total))
            entryFrame.dpsText:SetText(FormatNumber(dps) .. " " .. L["DPS"])
            entryFrame:Show()
        end
        
    else
        damageContent:Hide()
        threatContent:Show()
        
        -- Update threat entries
        local sortedThreat = SortData(threatData, "total")
        for i = 1, math.min(#sortedThreat, MeterMaidDB.maxEntries) do
            local entry = sortedThreat[i]
            local entryFrame = _G["MeterMaidThreatEntry" .. i]
            
            if not entryFrame then
                entryFrame = CreateFrame("Frame", "MeterMaidThreatEntry" .. i, mainFrame.threatList)
                entryFrame:SetHeight(16)
                entryFrame:SetPoint("TOPLEFT", mainFrame.threatList, "TOPLEFT", 0, -(i-1) * 16)
                entryFrame:SetPoint("TOPRIGHT", mainFrame.threatList, "TOPRIGHT", 0, -(i-1) * 16)
                
                local nameText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                nameText:SetPoint("LEFT", entryFrame, "LEFT", 0, 0)
                nameText:SetJustifyH("LEFT")
                nameText:SetTextColor(1, 1, 1)
                
                local totalText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                totalText:SetPoint("RIGHT", entryFrame, "RIGHT", -40, 0)
                totalText:SetJustifyH("RIGHT")
                totalText:SetTextColor(1, 1, 1)
                
                local tpsText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                tpsText:SetPoint("RIGHT", entryFrame, "RIGHT", 0, 0)
                tpsText:SetJustifyH("RIGHT")
                tpsText:SetTextColor(0.8, 0.8, 0.8)
                
                entryFrame.nameText = nameText
                entryFrame.totalText = totalText
                entryFrame.tpsText = tpsText
            end
            
            local tps = combatTime > 0 and (entry.info.total / combatTime) or 0
            local classColor = GetClassColor(entry.name)
            
            entryFrame.nameText:SetText(i .. ". " .. entry.name)
            entryFrame.nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
            entryFrame.totalText:SetText(FormatNumber(entry.info.total))
            entryFrame.tpsText:SetText(FormatNumber(tps) .. " " .. L["TPS"])
            entryFrame:Show()
        end
    end
end

-- Event handling
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        print(L["ADDON_NAME"] .. " " .. L["ADDON_DESCRIPTION"] .. " loaded. Use /metermaid for commands.")
        CreateMainWindow()
        
        if MeterMaidDB.enabled then
            mainFrame:Show()
        end
        
    elseif event == "PLAYER_REGEN_DISABLED" then
        if MeterMaidDB.autoStart then
            StartCombat()
        end
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        if MeterMaidDB.autoStop then
            StopCombat()
        end
        
    elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
        -- Clear class cache when raid/party changes
        playerClasses = {}
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not MeterMaidDB.enabled or not inCombat then return end
        
        local timestamp, eventType, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, spellName, _, amount = ...
        
        if eventType == "SWING_DAMAGE" or eventType == "RANGE_DAMAGE" or eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
            if sourceName and amount and amount > 0 then
                AddDamage(sourceName, amount)
                UpdateDisplay()
            end
        elseif eventType == "SWING_MISSED" or eventType == "RANGE_MISSED" or eventType == "SPELL_MISSED" then
            -- Could track misses if needed
        end
    end
end)

-- Slash commands
SLASH_METERMAID1 = "/metermaid"
SLASH_METERMAID2 = "/mm"
SlashCmdList["METERMAID"] = function(msg)
    msg = msg:lower()
    
    if msg == "start" then
        MeterMaidDB.enabled = true
        if not mainFrame then CreateMainWindow() end
        mainFrame:Show()
        print(L["STARTED"])
        
    elseif msg == "stop" then
        MeterMaidDB.enabled = false
        if mainFrame then mainFrame:Hide() end
        print(L["STOPPED"])
        
    elseif msg == "toggle" then
        MeterMaidDB.enabled = not MeterMaidDB.enabled
        if not mainFrame then CreateMainWindow() end
        if MeterMaidDB.enabled then
            mainFrame:Show()
            print(L["STARTED"])
        else
            mainFrame:Hide()
            print(L["STOPPED"])
        end
        
    elseif msg == "reset" then
        ResetData()
        UpdateDisplay()
        print(L["RESET"])
        
    elseif msg == "position" then
        MeterMaidDB.windowPosition = {x = 0, y = 0}
        if mainFrame then
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
        print(L["POSITION_RESET"])
        
    else
        print(L["SLASH_HELP"])
        print(L["SLASH_START"])
        print(L["SLASH_STOP"])
        print(L["SLASH_TOGGLE"])
        print(L["SLASH_RESET"])
        print(L["SLASH_POSITION"])
    end
end

-- Update function for periodic updates
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if MeterMaidDB.enabled and inCombat then
        UpdateDisplay()
    end
end) 