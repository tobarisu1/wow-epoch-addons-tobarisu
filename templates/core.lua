-- Basic Addon Template
-- This is a starting point for WoW addon development

local addonName, addon = ...
local frame = CreateFrame("Frame")

-- Initialize addon
function addon:Initialize()
    print("|cFF00FF00[" .. addonName .. "]|r Addon loaded!")
    
    -- Register slash command
    SLASH_BASICADDON1 = "/basicaddon"
    SlashCmdList["BASICADDON"] = function(msg)
        addon:HandleSlashCommand(msg)
    end
end

-- Handle slash commands
function addon:HandleSlashCommand(msg)
    if msg == "help" then
        print("|cFF00FF00[" .. addonName .. "]|r Commands:")
        print("  /basicaddon help - Show this help")
        print("  /basicaddon test - Test function")
    elseif msg == "test" then
        print("|cFF00FF00[" .. addonName .. "]|r Test function executed!")
    else
        print("|cFF00FF00[" .. addonName .. "]|r Type '/basicaddon help' for commands")
    end
end

-- Event handling
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        addon:Initialize()
    end
end)

-- Example: Register for other events
-- frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
-- frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Example: Handle other events
-- frame:SetScript("OnEvent", function(self, event, ...)
--     if event == "PLAYER_LOGIN" then
--         addon:Initialize()
--     elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
--         -- Handle combat events
--     elseif event == "PLAYER_ENTERING_WORLD" then
--         -- Handle entering world
--     end
-- end) 