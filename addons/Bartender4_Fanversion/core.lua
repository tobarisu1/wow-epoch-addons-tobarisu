--[[
	Bartender4_Fanversion - Enhanced Action Bar Management
	Fan version inspired by Bartender4 with enhanced keybinding features
--]]

-- Safe Ace3 initialization
local Bartender4_Fanversion
if LibStub then
	local success, addon = pcall(function() return LibStub('AceAddon-3.0'):NewAddon('Bartender4_Fanversion', 'AceEvent-3.0', 'AceConsole-3.0') end)
	if success then
		Bartender4_Fanversion = addon
	else
		-- Fallback: create basic addon structure
		Bartender4_Fanversion = {}
		Bartender4_Fanversion.bars = {}
		Bartender4_Fanversion.settings = {}
	end
else
	-- Fallback: create basic addon structure
	Bartender4_Fanversion = {}
	Bartender4_Fanversion.bars = {}
	Bartender4_Fanversion.settings = {}
end

-- Safe localization access
local L = {}
if LibStub then
	local success, locale = pcall(function() return LibStub('AceLocale-3.0'):GetLocale('Bartender4_Fanversion') end)
	if success then
		L = locale
	end
end

-- Fallback localization
local function GetLocalizedText(key, default)
	return L[key] or default or key
end

--[[
	Constants and Configuration
--]]

-- Action bar configurations
Bartender4_Fanversion.BarConfigs = {
	["ActionBar1"] = {
		name = "Action Bar 1",
		frame = "MainMenuBar",
		buttons = {"ActionButton1", "ActionButton2", "ActionButton3", "ActionButton4", "ActionButton5", "ActionButton6", "ActionButton7", "ActionButton8", "ActionButton9", "ActionButton10", "ActionButton11", "ActionButton12"},
		actions = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
		enabled = true,
		visible = true,
		locked = false
	},
	["ActionBar2"] = {
		name = "Action Bar 2", 
		frame = "MultiBarBottomLeft",
		buttons = {"MultiBarBottomLeftButton1", "MultiBarBottomLeftButton2", "MultiBarBottomLeftButton3", "MultiBarBottomLeftButton4", "MultiBarBottomLeftButton5", "MultiBarBottomLeftButton6", "MultiBarBottomLeftButton7", "MultiBarBottomLeftButton8", "MultiBarBottomLeftButton9", "MultiBarBottomLeftButton10", "MultiBarBottomLeftButton11", "MultiBarBottomLeftButton12"},
		actions = {13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24},
		enabled = true,
		visible = true,
		locked = false
	},
	["ActionBar3"] = {
		name = "Action Bar 3",
		frame = "MultiBarBottomRight", 
		buttons = {"MultiBarBottomRightButton1", "MultiBarBottomRightButton2", "MultiBarBottomRightButton3", "MultiBarBottomRightButton4", "MultiBarBottomRightButton5", "MultiBarBottomRightButton6", "MultiBarBottomRightButton7", "MultiBarBottomRightButton8", "MultiBarBottomRightButton9", "MultiBarBottomRightButton10", "MultiBarBottomRightButton11", "MultiBarBottomRightButton12"},
		actions = {25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36},
		enabled = true,
		visible = true,
		locked = false
	},
	["ActionBar4"] = {
		name = "Action Bar 4",
		frame = "MultiBarRight",
		buttons = {"MultiBarRightButton1", "MultiBarRightButton2", "MultiBarRightButton3", "MultiBarRightButton4", "MultiBarRightButton5", "MultiBarRightButton6", "MultiBarRightButton7", "MultiBarRightButton8", "MultiBarRightButton9", "MultiBarRightButton10", "MultiBarRightButton11", "MultiBarRightButton12"},
		actions = {37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48},
		enabled = true,
		visible = true,
		locked = false
	},
	["ActionBar5"] = {
		name = "Action Bar 5",
		frame = "MultiBarLeft",
		buttons = {"MultiBarLeftButton1", "MultiBarLeftButton2", "MultiBarLeftButton3", "MultiBarLeftButton4", "MultiBarLeftButton5", "MultiBarLeftButton6", "MultiBarLeftButton7", "MultiBarLeftButton8", "MultiBarLeftButton9", "MultiBarLeftButton10", "MultiBarLeftButton11", "MultiBarLeftButton12"},
		actions = {49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60},
		enabled = true,
		visible = true,
		locked = false
	},
	["PetBar"] = {
		name = "Pet Bar",
		frame = "PetActionBarFrame",
		buttons = {"PetActionButton1", "PetActionButton2", "PetActionButton3", "PetActionButton4", "PetActionButton5", "PetActionButton6", "PetActionButton7", "PetActionButton8", "PetActionButton9", "PetActionButton10"},
		actions = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
		enabled = true,
		visible = true,
		locked = false
	},
	["StanceBar"] = {
		name = "Stance Bar",
		frame = "StanceBarFrame",
		buttons = {"StanceButton1", "StanceButton2", "StanceButton3", "StanceButton4", "StanceButton5", "StanceButton6", "StanceButton7", "StanceButton8", "StanceButton9", "StanceButton10"},
		actions = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
		enabled = true,
		visible = true,
		locked = false
	}
}

--[[
	Startup
--]]

function Bartender4_Fanversion:OnInitialize()
	self.bars = {}
	self.settings = {}
	self.keybindingMode = false
	self.currentButton = nil
	
	-- Initialize settings
	self:InitializeSettings()
	
	-- Register events
	self:RegisterEvents()
	
	-- Register slash commands
	self:RegisterSlashCommands()
	
	-- Initialize action bars
	self:InitializeActionBars()
	
	print("|cFF00FF00Bartender4_Fanversion|r loaded. Type /bt4 for help.")
end

function Bartender4_Fanversion:OnEnable()
	-- Register events
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('ACTIONBAR_UPDATE_STATE')
	self:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
	self:RegisterEvent('ACTIONBAR_UPDATE_USABLE')
	self:RegisterEvent('ACTIONBAR_UPDATE_RANGE')
end

-- Fallback initialization for when Ace3 isn't available
if not Bartender4_Fanversion.OnInitialize then
	-- Create event frame for fallback event handling
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_LOGIN")
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	eventFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	eventFrame:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
	eventFrame:RegisterEvent("ACTIONBAR_UPDATE_RANGE")
	
	eventFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			-- Initialize addon
			Bartender4_Fanversion.bars = {}
			Bartender4_Fanversion.settings = {}
			Bartender4_Fanversion.keybindingMode = false
			Bartender4_Fanversion.currentButton = nil
			
			-- Initialize settings
			Bartender4_Fanversion:InitializeSettings()
			
			-- Register events
			Bartender4_Fanversion:RegisterEvents()
			
			-- Register slash commands
			Bartender4_Fanversion:RegisterSlashCommands()
			
			-- Initialize action bars
			Bartender4_Fanversion:InitializeActionBars()
			
			print("|cFF00FF00Bartender4_Fanversion|r loaded. Type /bt4 for help.")
		elseif event == "PLAYER_ENTERING_WORLD" then
			Bartender4_Fanversion:ApplyBarSettings()
		elseif event == "ACTIONBAR_UPDATE_STATE" then
			Bartender4_Fanversion:UpdateActionBars()
		elseif event == "ACTIONBAR_UPDATE_COOLDOWN" then
			Bartender4_Fanversion:UpdateCooldowns()
		elseif event == "ACTIONBAR_UPDATE_USABLE" then
			Bartender4_Fanversion:UpdateUsable()
		elseif event == "ACTIONBAR_UPDATE_RANGE" then
			Bartender4_Fanversion:UpdateRange()
		end
	end)
end

--[[
	Settings Management
--]]

function Bartender4_Fanversion:InitializeSettings()
	-- Default settings
	self.defaults = {
		enableKeybindingMode = true,
		showKeybindings = true,
		lockBars = false,
		enableBarMoving = true,
		enableBarResizing = true,
		enableBarScaling = true,
		enableBarAlpha = true,
		gridSnap = false,
		gridSize = 10
	}
	
	-- Initialize saved variables (global only)
	Bartender4_FanversionDB = Bartender4_FanversionDB or {}
	
	-- Apply defaults
	self:ApplyDefaults(Bartender4_FanversionDB, self.defaults)
	self.settings = Bartender4_FanversionDB
	
	-- Initialize bar settings
	if not self.settings.bars then
		self.settings.bars = {}
	end
end

function Bartender4_Fanversion:ApplyDefaults(target, defaults)
	for key, value in pairs(defaults) do
		if target[key] == nil then
			target[key] = value
		end
	end
end

--[[
	Action Bar Management
--]]

function Bartender4_Fanversion:InitializeActionBars()
	for barID, config in pairs(self.BarConfigs) do
		self.bars[barID] = {
			config = config,
			frame = _G[config.frame],
			buttons = {},
			settings = self.settings.bars[barID] or {}
		}
		
		-- Initialize button references
		for i, buttonName in ipairs(config.buttons) do
			local button = _G[buttonName]
			if button then
				self.bars[barID].buttons[i] = {
					name = buttonName,
					frame = button,
					action = config.actions[i]
				}
			end
		end
		
		-- Apply saved settings
		self:ApplyBarSettings(barID)
	end
end

function Bartender4_Fanversion:ApplyBarSettings(barID)
	if barID then
		-- Apply settings for specific bar
		local bar = self.bars[barID]
		if bar and bar.settings then
			self:ApplyBarVisibility(barID)
			self:ApplyBarPosition(barID)
			self:ApplyBarScale(barID)
			self:ApplyBarAlpha(barID)
		end
	else
		-- Apply settings for all bars
		for id, _ in pairs(self.bars) do
			self:ApplyBarSettings(id)
		end
	end
end

function Bartender4_Fanversion:ApplyBarVisibility(barID)
	local bar = self.bars[barID]
	if not bar or not bar.frame then return end
	
	local visible = bar.settings.visible ~= false
	if visible then
		bar.frame:Show()
	else
		bar.frame:Hide()
	end
end

function Bartender4_Fanversion:ApplyBarPosition(barID)
	local bar = self.bars[barID]
	if not bar or not bar.frame or not bar.settings.point then return end
	
	bar.frame:ClearAllPoints()
	bar.frame:SetPoint(bar.settings.point, bar.settings.relativeTo, bar.settings.relativePoint, bar.settings.x, bar.settings.y)
end

function Bartender4_Fanversion:ApplyBarScale(barID)
	local bar = self.bars[barID]
	if not bar or not bar.frame then return end
	
	local scale = bar.settings.scale or 1.0
	bar.frame:SetScale(scale)
end

function Bartender4_Fanversion:ApplyBarAlpha(barID)
	local bar = self.bars[barID]
	if not bar or not bar.frame then return end
	
	local alpha = bar.settings.alpha or 1.0
	bar.frame:SetAlpha(alpha)
end

--[[
	Keybinding Mode
--]]

function Bartender4_Fanversion:ToggleKeybindingMode()
	if InCombatLockdown() then
		print("|cFFFF0000Bartender4_Fanversion|r: Cannot enter keybinding mode in combat.")
		return
	end
	
	self.keybindingMode = not self.keybindingMode
	
	if self.keybindingMode then
		self:EnterKeybindingMode()
	else
		self:ExitKeybindingMode()
	end
end

function Bartender4_Fanversion:EnterKeybindingMode()
	print("|cFF00FF00Bartender4_Fanversion|r: Keybinding mode enabled.")
	print("|cFFFFD700" .. GetLocalizedText("Hover over an action button and press a key to bind it", "Hover over an action button and press a key to bind it") .. "|r")
	print("|cFFFFD700" .. GetLocalizedText("Press ESC to exit keybinding mode", "Press ESC to exit keybinding mode") .. "|r")
	
	-- Set up enhanced keybinding mode
	self:EnterEnhancedKeybindingMode()
end

function Bartender4_Fanversion:ExitKeybindingMode()
	print("|cFF00FF00Bartender4_Fanversion|r: Keybinding mode disabled.")
	
	-- Exit enhanced keybinding mode
	self:ExitEnhancedKeybindingMode()
end

function Bartender4_Fanversion:SetKeybinding(buttonData, binding)
	local action = buttonData.action
	if not action then return end
	
	-- Set the keybinding
	SetBinding(binding, "ACTIONBUTTON" .. action)
	
	-- Save the keybinding
	self:SaveKeybinding(buttonData, binding)
	
	print(string.format("|cFF00FF00Bartender4_Fanversion|r: " .. GetLocalizedText("Keybinding set: %s", "Keybinding set: %s"), binding))
end

--[[
	Event Registration
--]]

function Bartender4_Fanversion:RegisterEvents()
	-- Hook into action bar events
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('ACTIONBAR_UPDATE_STATE')
	self:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
	self:RegisterEvent('ACTIONBAR_UPDATE_USABLE')
	self:RegisterEvent('ACTIONBAR_UPDATE_RANGE')
end

--[[
	Event Handlers
--]]

function Bartender4_Fanversion:OnPlayerEnteringWorld()
	self:ApplyBarSettings()
end

function Bartender4_Fanversion:OnPlayerLogin()
	-- Load saved settings
end

function Bartender4_Fanversion:UpdateActionBars()
	-- Update action bar states
end

function Bartender4_Fanversion:UpdateCooldowns()
	-- Update cooldown displays
end

function Bartender4_Fanversion:UpdateUsable()
	-- Update usable states
end

function Bartender4_Fanversion:UpdateRange()
	-- Update range indicators
end

--[[
	Slash Commands
--]]

function Bartender4_Fanversion:RegisterSlashCommands()
	self:RegisterChatCommand('bt4', 'HandleSlashCommand')
	self:RegisterChatCommand('bartender4', 'HandleSlashCommand')
end

function Bartender4_Fanversion:HandleSlashCommand(input)
	local command = string.lower(input)
	
	if command == 'keybind' or command == 'kb' then
		self:ToggleKeybindingMode()
	elseif command == 'config' or command == 'c' then
		self:ShowConfig()
	elseif command == 'reset' or command == 'r' then
		self:ResetAllSettings()
	elseif command == 'help' or command == 'h' or command == '' then
		self:ShowHelp()
	else
		print("|cFF00FF00Bartender4_Fanversion|r: Unknown command. Type /bt4 help for options.")
	end
end

function Bartender4_Fanversion:ShowHelp()
	print("|cFF00FF00Bartender4_Fanversion Commands:|r")
	print("  /bt4 keybind - Toggle keybinding mode")
	print("  /bt4 config - Show configuration")
	print("  /bt4 reset - Reset all settings")
	print("  /bt4 help - Show this help")
	print("")
	print("|cFFFFD700Keybinding Mode:|r")
	print("  1. Use /bt4 keybind to enter keybinding mode")
	print("  2. Hover over any action button")
	print("  3. Press the key combination you want to bind")
	print("  4. Press ESC to exit keybinding mode")
end

function Bartender4_Fanversion:ShowConfig()
	-- TODO: Implement configuration UI
	print("|cFF00FF00Bartender4_Fanversion|r: Configuration UI not yet implemented.")
end

function Bartender4_Fanversion:ResetAllSettings()
	self.settings = {}
	self:InitializeSettings()
	self:ApplyBarSettings()
	print("|cFF00FF00Bartender4_Fanversion|r: All settings reset.")
end 