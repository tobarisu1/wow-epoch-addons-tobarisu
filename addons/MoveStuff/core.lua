--[[
	MoveStuff - Simple UI Frame Mover
	Move and resize any UI element while retaining classic UI feel
--]]

-- Safe Ace3 initialization
local MoveStuff
if LibStub then
	local success, addon = pcall(function() return LibStub('AceAddon-3.0'):NewAddon('MoveStuff', 'AceEvent-3.0', 'AceConsole-3.0') end)
	if success then
		MoveStuff = addon
	else
		-- Fallback: create basic addon structure
		MoveStuff = {}
		MoveStuff.frames = {}
		MoveStuff.settings = {}
	end
else
	-- Fallback: create basic addon structure
	MoveStuff = {}
	MoveStuff.frames = {}
	MoveStuff.settings = {}
end

-- Safe localization access
local L = {}
if LibStub then
	local success, locale = pcall(function() return LibStub('AceLocale-3.0'):GetLocale('MoveStuff') end)
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

-- Frame types that can be moved
MoveStuff.MovableTypes = {
	["Frame"] = true,
	["Button"] = true,
	["CheckButton"] = true,
	["StatusBar"] = true,
	["FontString"] = true,
	["Texture"] = true,
	["GameTooltip"] = true,
	["MessageFrame"] = true,
	["EditBox"] = true,
	["Slider"] = true,
	["Minimap"] = true
}

-- Frames that should not be moved (system critical)
MoveStuff.ProtectedFrames = {
	["UIParent"] = true,
	["WorldFrame"] = true,
	["CinematicFrame"] = true,
	["GameTooltip"] = true,
	["ItemRefTooltip"] = true,
	["ShoppingTooltip1"] = true,
	["ShoppingTooltip2"] = true,
	["ShoppingTooltip3"] = true,
	["WorldStateAlwaysUpFrame"] = true,
	["AlwaysUpFrame1"] = true,
	["AlwaysUpFrame2"] = true,
	["AlwaysUpFrame3"] = true
}

--[[
	Startup
--]]

function MoveStuff:OnInitialize()
	self.frames = {}
	self.settings = {}
	self.isMoving = false
	self.currentFrame = nil
	
	-- Initialize settings
	self:InitializeSettings()
	
	-- Register events
	self:RegisterEvents()
	
	-- Register slash commands
	self:RegisterSlashCommands()
	
	-- Load saved frame positions
	self:LoadFrameData()
	
	print("|cFF00FF00MoveStuff|r loaded. Type /movestuff for help.")
end

function MoveStuff:OnEnable()
	-- Register events
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('PLAYER_LOGIN')
end

-- Fallback initialization for when Ace3 isn't available
if not MoveStuff.OnInitialize then
	-- Create event frame for fallback event handling
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_LOGIN")
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	eventFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			-- Initialize addon
			MoveStuff.frames = {}
			MoveStuff.settings = {}
			MoveStuff.isMoving = false
			MoveStuff.currentFrame = nil
			
			-- Initialize settings
			MoveStuff:InitializeSettings()
			
			-- Register events
			MoveStuff:RegisterEvents()
			
			-- Register slash commands
			MoveStuff:RegisterSlashCommands()
			
			-- Load saved frame positions
			MoveStuff:LoadFrameData()
			
			print("|cFF00FF00MoveStuff|r loaded. Type /movestuff for help.")
		elseif event == "PLAYER_ENTERING_WORLD" then
			MoveStuff:ApplyFramePositions()
		end
	end)
end

--[[
	Settings Management
--]]

function MoveStuff:InitializeSettings()
	-- Default settings
	self.defaults = {
		showFrameNames = true,
		lockFrames = false,
		enableResize = true,
		enableScale = true,
		enableAlpha = true,
		gridSnap = false,
		gridSize = 10
	}
	
	-- Initialize saved variables (global only)
	MoveStuffDB = MoveStuffDB or {}
	
	-- Apply defaults
	self:ApplyDefaults(MoveStuffDB, self.defaults)
	self.settings = MoveStuffDB
end

function MoveStuff:ApplyDefaults(target, defaults)
	for key, value in pairs(defaults) do
		if target[key] == nil then
			target[key] = value
		end
	end
end

--[[
	Frame Discovery and Management
--]]

function MoveStuff:DiscoverFrames()
	-- Dynamically discover all frames in the UI
	local discoveredFrames = {}
	
	-- Scan through all global variables to find frames
	for name, frame in pairs(_G) do
		if self:IsMovableFrame(frame, name) then
			table.insert(discoveredFrames, {
				name = name,
				frame = frame,
				type = frame:GetObjectType(),
				visible = frame:IsVisible(),
				parent = frame:GetParent() and frame:GetParent():GetName() or "UIParent"
			})
		end
	end
	
	return discoveredFrames
end

function MoveStuff:IsMovableFrame(frame, name)
	-- Check if it's a valid frame type
	if not frame or type(frame) ~= "table" then
		return false
	end
	
	-- Check if it has the required methods
	if not frame.SetPoint or not frame.GetPoint then
		return false
	end
	
	-- Check if it's a protected frame
	if self.ProtectedFrames[name] then
		return false
	end
	
	-- Check if it's a valid frame type
	local frameType = frame:GetObjectType()
	if not self.MovableTypes[frameType] then
		return false
	end
	
	-- Check if it's visible and has a name
	if not name or name == "" then
		return false
	end
	
	-- Skip frames that are likely to cause issues
	if string.find(name, "Tooltip") or string.find(name, "ToolTip") then
		return false
	end
	
	return true
end

function MoveStuff:GetFrameList()
	local frames = self:DiscoverFrames()
	local categorized = {
		["Player"] = {},
		["Target"] = {},
		["Buffs"] = {},
		["Bags"] = {},
		["Chat"] = {},
		["Minimap"] = {},
		["Action Bars"] = {},
		["Other"] = {}
	}
	
	for _, frameData in ipairs(frames) do
		local category = self:CategorizeFrame(frameData.name)
		table.insert(categorized[category], frameData)
	end
	
	return categorized
end

function MoveStuff:CategorizeFrame(frameName)
	-- Simple categorization based on frame name
	local name = string.lower(frameName)
	
	if string.find(name, "player") or string.find(name, "playerframe") then
		return "Player"
	elseif string.find(name, "target") or string.find(name, "targetframe") then
		return "Target"
	elseif string.find(name, "buff") or string.find(name, "debuff") then
		return "Buffs"
	elseif string.find(name, "bag") or string.find(name, "container") then
		return "Bags"
	elseif string.find(name, "chat") or string.find(name, "message") then
		return "Chat"
	elseif string.find(name, "minimap") then
		return "Minimap"
	elseif string.find(name, "action") or string.find(name, "bar") then
		return "Action Bars"
	else
		return "Other"
	end
end

--[[
	Frame Movement and Positioning
--]]

function MoveStuff:StartMoving(frameName)
	if InCombatLockdown() then
		print("|cFFFF0000MoveStuff|r: Cannot move frames in combat.")
		return
	end
	
	local frame = _G[frameName]
	if not frame then
		print("|cFFFF0000MoveStuff|r: Frame not found: " .. frameName)
		return
	end
	
	self.currentFrame = frame
	self.isMoving = true
	
	-- Highlight the frame
	self:HighlightFrame(frameName)
	
	-- Start moving the frame
	frame:StartMoving()
	
	-- Set up click handler to stop moving
	local clickFrame = CreateFrame("Frame", nil, UIParent)
	clickFrame:SetAllPoints()
	clickFrame:EnableMouse(true)
	clickFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	
	clickFrame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			MoveStuff:StopMoving()
			self:Hide()
			self:SetParent(nil)
		end
	end)
	
	-- Store reference
	self.clickFrame = clickFrame
	
	print("|cFF00FF00MoveStuff|r: Moving " .. frameName .. ". Click to place.")
end

function MoveStuff:StopMoving()
	if not self.isMoving or not self.currentFrame then
		return
	end
	
	self.currentFrame:StopMovingOrSizing()
	
	-- Save the new position
	local frameName = self.currentFrame:GetName()
	if frameName then
		self:SaveFramePosition(frameName)
	end
	
	-- Remove click frame
	if self.clickFrame then
		self.clickFrame:Hide()
		self.clickFrame:SetParent(nil)
		self.clickFrame = nil
	end
	
	self.isMoving = false
	self.currentFrame = nil
	
	print("|cFF00FF00MoveStuff|r: Frame position saved.")
end

function MoveStuff:SaveFramePosition(frameName)
	local frame = _G[frameName]
	if not frame then return end
	
	local point, relativeTo, relativePoint, x, y = frame:GetPoint()
	
	-- Initialize frame data if it doesn't exist
	if not self.frames[frameName] then
		self.frames[frameName] = {}
	end
	
	-- Save position data
	self.frames[frameName].point = point
	self.frames[frameName].relativeTo = relativeTo and relativeTo:GetName() or "UIParent"
	self.frames[frameName].relativePoint = relativePoint
	self.frames[frameName].x = x
	self.frames[frameName].y = y
	
	-- Save to persistent storage
	self:SaveFrameData()
end

function MoveStuff:LoadFrameData()
	-- Load frame data from saved variables
	if MoveStuffDB and MoveStuffDB.frames then
		self.frames = MoveStuffDB.frames
	end
end

function MoveStuff:SaveFrameData()
	-- Save frame data to persistent storage
	if not MoveStuffDB then
		MoveStuffDB = {}
	end
	MoveStuffDB.frames = self.frames
end

function MoveStuff:ApplyFramePositions()
	-- Apply saved positions to frames
	for frameName, frameData in pairs(self.frames) do
		local frame = _G[frameName]
		if frame and frameData.point then
			frame:ClearAllPoints()
			frame:SetPoint(frameData.point, frameData.relativeTo, frameData.relativePoint, frameData.x, frameData.y)
		end
	end
end

function MoveStuff:ResetFrame(frameName)
	local frame = _G[frameName]
	if not frame then
		print("|cFFFF0000MoveStuff|r: Frame not found: " .. frameName)
		return
	end
	
	-- Remove saved data
	self.frames[frameName] = nil
	self:SaveFrameData()
	
	-- Reset frame to default position (this would need frame-specific logic)
	print("|cFF00FF00MoveStuff|r: Reset " .. frameName)
end

function MoveStuff:ResetAllFrames()
	self.frames = {}
	self:SaveFrameData()
	print("|cFF00FF00MoveStuff|r: All frame positions reset.")
end

--[[
	Event Registration
--]]

function MoveStuff:RegisterEvents()
	-- Hook into frame movement events
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('PLAYER_LOGIN')
end

--[[
	Event Handlers
--]]

function MoveStuff:OnPlayerEnteringWorld()
	self:ApplyFramePositions()
end

function MoveStuff:OnPlayerLogin()
	self:LoadFrameData()
end

--[[
	Slash Commands
--]]

function MoveStuff:RegisterSlashCommands()
	self:RegisterChatCommand('movestuff', 'HandleSlashCommand')
	self:RegisterChatCommand('ms', 'HandleSlashCommand')
end

function MoveStuff:HandleSlashCommand(input)
	local command = string.lower(input)
	
	if command == 'reset' or command == 'r' then
		self:ResetAllFrames()
	elseif command == 'list' or command == 'l' then
		self:ShowFrameSelector()
	elseif command == 'help' or command == 'h' or command == '' then
		self:ShowHelp()
	else
		-- Try to interpret as frame name
		self:StartMoving(input)
	end
end

function MoveStuff:ShowHelp()
	print("|cFF00FF00MoveStuff Commands:|r")
	print("  /movestuff - Show frame selector")
	print("  /movestuff [frame] - Move a specific frame")
	print("  /movestuff list - Show frame selector")
	print("  /movestuff reset - Reset all frame positions")
	print("  /movestuff help - Show this help")
	print("")
	print("|cFFFFD700Usage:|r")
	print("  1. Use /movestuff to open the frame selector")
	print("  2. Click on a frame name to start moving it")
	print("  3. Click anywhere to place the frame")
	print("  4. Positions are saved automatically")
end

function MoveStuff:ShowFrameSelector()
	local categorized = self:GetFrameList()
	
	print("|cFF00FF00MoveStuff Available Frames:|r")
	for category, frames in pairs(categorized) do
		if #frames > 0 then
			print("  |cFFFFD700" .. category .. "|r:")
			for _, frameData in ipairs(frames) do
				print("    " .. frameData.name)
			end
		end
	end
end 