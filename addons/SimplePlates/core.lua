-- SimplePlates - Clean and minimalistic nameplates
-- Inspired by TidyPlates but simplified for WoW 3.3.5a

local addonName, SimplePlates = ...
local L = SimplePlatesL or {}

-- Initialize saved variables
SimplePlatesDB = SimplePlatesDB or {
    enabled = true,
    showClassColors = true,
    showMonsterIcons = true,
    showCastbars = true,
    showSwingTimer = true,
    nameplateScale = 1.0,
    nameplateWidth = 120,
    nameplateHeight = 8
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

-- Monster type icons
local MONSTER_ICONS = {
    ["Humanoid"] = "Interface\\Icons\\INV_Misc_QuestionMark",
    ["Beast"] = "Interface\\Icons\\Ability_Mount_JungleTiger",
    ["Demon"] = "Interface\\Icons\\Spell_Shadow_SummonVoidWalker",
    ["Dragonkin"] = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
    ["Elemental"] = "Interface\\Icons\\Spell_Nature_ElementalShapes",
    ["Giant"] = "Interface\\Icons\\INV_Misc_Head_Giant_01",
    ["Mechanical"] = "Interface\\Icons\\INV_Misc_Gear_01",
    ["Undead"] = "Interface\\Icons\\Spell_Shadow_RaiseDead",
    ["Critter"] = "Interface\\Icons\\Ability_Hunter_BeastTaming",
    ["default"] = "Interface\\Icons\\INV_Misc_QuestionMark"
}

-- Variables
local nameplates = {}
local currentTarget = nil
local swingTimer = 0
local swingTimerActive = false
local lastSwingTime = 0

-- Main frame for events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

-- Slash commands
SLASH_SIMPLEPLATES1 = "/splates"
SLASH_SIMPLEPLATES2 = "/simpleplates"
SlashCmdList["SIMPLEPLATES"] = function(msg)
    msg = msg:lower()
    if msg == "toggle" or msg == "" then
        SimplePlatesDB.enabled = not SimplePlatesDB.enabled
        print(SimplePlatesDB.enabled and L["ENABLED"] or L["DISABLED"])
        SimplePlates:UpdateAllNameplates()
    elseif msg == "reload" then
        ReloadUI()
    elseif msg == "reset" then
        SimplePlatesDB = {
            enabled = true,
            showClassColors = true,
            showMonsterIcons = true,
            showCastbars = true,
            showSwingTimer = true,
            nameplateScale = 1.0,
            nameplateWidth = 120,
            nameplateHeight = 8
        }
        print(L["RESET"])
        SimplePlates:UpdateAllNameplates()
    else
        print(L["SLASH_HELP"])
        print(L["SLASH_TOGGLE"])
        print(L["SLASH_RELOAD"])
        print(L["SLASH_RESET"])
    end
end

-- Utility functions
local function GetClassColor(unit)
    if not unit then return CLASS_COLORS["MONSTER"] end
    
    local _, class = UnitClass(unit)
    if class and CLASS_COLORS[class] then
        return CLASS_COLORS[class]
    end
    
    -- Check if it's a player
    if UnitIsPlayer(unit) then
        return CLASS_COLORS["MONSTER"] -- Default for unknown class
    end
    
    -- Check creature type
    local creatureType = UnitCreatureType(unit)
    if creatureType and MONSTER_ICONS[creatureType] then
        return CLASS_COLORS["MONSTER"]
    end
    
    return CLASS_COLORS["NPC"]
end

local function GetMonsterIcon(unit)
    if not unit or UnitIsPlayer(unit) then
        return nil
    end
    
    local creatureType = UnitCreatureType(unit)
    return MONSTER_ICONS[creatureType] or MONSTER_ICONS["default"]
end

local function CreateSimpleNameplate(nameplate)
    if not nameplate or nameplate.simplePlatesCreated then
        return
    end
    
    -- Create our custom frame
    local simpleFrame = CreateFrame("Frame", nil, nameplate)
    simpleFrame:SetFrameLevel(nameplate:GetFrameLevel() + 1)
    simpleFrame:SetPoint("CENTER", nameplate, "CENTER", 0, 0)
    simpleFrame:SetSize(SimplePlatesDB.nameplateWidth, SimplePlatesDB.nameplateHeight)
    
    -- Health bar
    local healthBar = CreateFrame("StatusBar", nil, simpleFrame)
    healthBar:SetPoint("CENTER", simpleFrame, "CENTER", 0, 0)
    healthBar:SetSize(SimplePlatesDB.nameplateWidth, SimplePlatesDB.nameplateHeight)
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    healthBar:SetStatusBarColor(0.2, 0.8, 0.2)
    
    -- Health bar background
    local healthBarBG = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBarBG:SetAllPoints()
    healthBarBG:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    healthBarBG:SetVertexColor(0.3, 0.3, 0.3, 0.8)
    
    -- Name text
    local nameText = simpleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("CENTER", simpleFrame, "CENTER", 0, 0)
    nameText:SetJustifyH("CENTER")
    nameText:SetTextColor(1, 1, 1)
    
    -- Level text
    local levelText = simpleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelText:SetPoint("RIGHT", simpleFrame, "RIGHT", -2, 0)
    levelText:SetJustifyH("RIGHT")
    levelText:SetTextColor(1, 1, 1)
    
    -- Monster icon
    local monsterIcon = simpleFrame:CreateTexture(nil, "OVERLAY")
    monsterIcon:SetPoint("LEFT", simpleFrame, "LEFT", 2, 0)
    monsterIcon:SetSize(16, 16)
    
    -- Cast bar
    local castBar = CreateFrame("StatusBar", nil, simpleFrame)
    castBar:SetPoint("TOP", simpleFrame, "BOTTOM", 0, -2)
    castBar:SetSize(SimplePlatesDB.nameplateWidth, 4)
    castBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    castBar:SetStatusBarColor(1, 1, 0)
    castBar:Hide()
    
    -- Cast bar background
    local castBarBG = castBar:CreateTexture(nil, "BACKGROUND")
    castBarBG:SetAllPoints()
    castBarBG:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    castBarBG:SetVertexColor(0.3, 0.3, 0.3, 0.8)
    
    -- Cast spell icon
    local castIcon = castBar:CreateTexture(nil, "OVERLAY")
    castIcon:SetPoint("LEFT", castBar, "LEFT", 0, 0)
    castIcon:SetSize(12, 12)
    
    -- Cast spell text
    local castText = castBar:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny")
    castText:SetPoint("CENTER", castBar, "CENTER", 0, 0)
    castText:SetJustifyH("CENTER")
    castText:SetTextColor(1, 1, 1)
    
    -- Swing timer bar
    local swingBar = CreateFrame("StatusBar", nil, simpleFrame)
    swingBar:SetPoint("TOP", castBar, "BOTTOM", 0, -1)
    swingBar:SetSize(SimplePlatesDB.nameplateWidth, 2)
    swingBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    swingBar:SetStatusBarColor(1, 0.5, 0)
    swingBar:Hide()
    
    -- Store references
    simpleFrame.healthBar = healthBar
    simpleFrame.nameText = nameText
    simpleFrame.levelText = levelText
    simpleFrame.monsterIcon = monsterIcon
    simpleFrame.castBar = castBar
    simpleFrame.castIcon = castIcon
    simpleFrame.castText = castText
    simpleFrame.swingBar = swingBar
    
    -- Mark as created
    nameplate.simplePlatesCreated = true
    nameplate.simpleFrame = simpleFrame
    
    return simpleFrame
end

local function UpdateNameplate(nameplate)
    if not SimplePlatesDB.enabled or not nameplate or not nameplate.simpleFrame then
        return
    end
    
    local unit = nameplate.unit
    if not unit then return end
    
    local simpleFrame = nameplate.simpleFrame
    
    -- Hide default nameplate elements
    if nameplate.name then nameplate.name:Hide() end
    if nameplate.level then nameplate.level:Hide() end
    if nameplate.healthBar then nameplate.healthBar:Hide() end
    if nameplate.castBar then nameplate.castBar:Hide() end
    
    -- Get unit info
    local name = UnitName(unit) or "Unknown"
    local level = UnitLevel(unit) or "??"
    local health = UnitHealth(unit) or 0
    local maxHealth = UnitHealthMax(unit) or 1
    local healthPercent = health / maxHealth
    
    -- Update health bar
    simpleFrame.healthBar:SetValue(healthPercent)
    
    -- Update name with class color
    if SimplePlatesDB.showClassColors then
        local color = GetClassColor(unit)
        simpleFrame.nameText:SetTextColor(color.r, color.g, color.b)
    else
        simpleFrame.nameText:SetTextColor(1, 1, 1)
    end
    simpleFrame.nameText:SetText(name)
    
    -- Update level
    simpleFrame.levelText:SetText(level)
    
    -- Update monster icon
    if SimplePlatesDB.showMonsterIcons then
        local icon = GetMonsterIcon(unit)
        if icon then
            simpleFrame.monsterIcon:SetTexture(icon)
            simpleFrame.monsterIcon:Show()
        else
            simpleFrame.monsterIcon:Hide()
        end
    else
        simpleFrame.monsterIcon:Hide()
    end
    
    -- Update cast bar
    if SimplePlatesDB.showCastbars then
        local spellName, _, _, spellIcon = UnitCastingInfo(unit)
        if spellName then
            simpleFrame.castBar:Show()
            simpleFrame.castIcon:SetTexture(spellIcon)
            simpleFrame.castText:SetText(spellName)
        else
            local channelName, _, _, channelIcon = UnitChannelInfo(unit)
            if channelName then
                simpleFrame.castBar:Show()
                simpleFrame.castIcon:SetTexture(channelIcon)
                simpleFrame.castText:SetText(channelName)
            else
                simpleFrame.castBar:Hide()
            end
        end
    else
        simpleFrame.castBar:Hide()
    end
    
    -- Update swing timer (only for target)
    if SimplePlatesDB.showSwingTimer and unit == "target" and swingTimerActive then
        local swingProgress = (GetTime() - lastSwingTime) / swingTimer
        if swingProgress < 1 then
            simpleFrame.swingBar:Show()
            simpleFrame.swingBar:SetValue(swingProgress)
        else
            simpleFrame.swingBar:Hide()
            swingTimerActive = false
        end
    else
        simpleFrame.swingBar:Hide()
    end
    
    -- Show our frame
    simpleFrame:Show()
end

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        print(L["ADDON_NAME"] .. " " .. L["ADDON_DESCRIPTION"] .. " loaded. Use /splates for options.")
        
        -- Hook into nameplate creation
        hooksecurefunc("CreateNameplate", function(nameplate)
            CreateSimpleNameplate(nameplate)
        end)
        
        -- Hook into nameplate updates
        hooksecurefunc("NamePlateDriverFrame:OnNamePlateAdded", function(nameplate)
            CreateSimpleNameplate(nameplate)
            UpdateNameplate(nameplate)
        end)
        
        hooksecurefunc("NamePlateDriverFrame:OnNamePlateRemoved", function(nameplate)
            if nameplate.simpleFrame then
                nameplate.simpleFrame:Hide()
            end
        end)
        
    elseif event == "PLAYER_TARGET_CHANGED" then
        currentTarget = UnitGUID("target")
        SimplePlates:UpdateAllNameplates()
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, eventType, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, spellName = ...
        
        if eventType == "SWING_DAMAGE" and sourceGUID == UnitGUID("player") then
            -- Start swing timer
            swingTimer = 2.0 -- Default swing timer, could be made more accurate
            lastSwingTime = GetTime()
            swingTimerActive = true
            SimplePlates:UpdateAllNameplates()
        end
        
    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or 
           event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local unit = ...
        SimplePlates:UpdateAllNameplates()
    end
end)

-- Update all visible nameplates
function SimplePlates:UpdateAllNameplates()
    for nameplate in pairs(nameplates) do
        if nameplate:IsShown() then
            UpdateNameplate(nameplate)
        end
    end
end

-- Hook into nameplate creation to track them
hooksecurefunc("CreateNameplate", function(nameplate)
    nameplates[nameplate] = true
end)

hooksecurefunc("NamePlateDriverFrame:OnNamePlateRemoved", function(nameplate)
    nameplates[nameplate] = nil
end)

-- Update function for periodic updates
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if SimplePlatesDB.enabled then
        SimplePlates:UpdateAllNameplates()
    end
end) 