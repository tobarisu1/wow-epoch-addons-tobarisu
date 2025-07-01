--[[
	BagMaster - Advanced Inventory Manager
	Core functionality for inventory aggregation, categorization, and auto-organization
--]]

-- Debug output to help diagnose issues
print("|cFF00FF00BagMaster|r: Starting initialization...")

-- SimpleLogger integration for better debugging
local function LogDebug(message, ...)
	if SimpleLogger_LogInfo then
		SimpleLogger_LogInfo(message, "BagMaster", ...)
	else
		-- Fallback to regular print if SimpleLogger not available
		print("|cFF00FF00BagMaster|r: " .. message)
	end
end

local function LogError(message, ...)
	if SimpleLogger_LogError then
		SimpleLogger_LogError(message, "BagMaster", ...)
	else
		print("|cFFFF0000BagMaster|r: " .. message)
	end
end

local function LogInfo(message, ...)
	if SimpleLogger_LogInfo then
		SimpleLogger_LogInfo(message, "BagMaster", ...)
	else
		print("|cFF00FF00BagMaster|r: " .. message)
	end
end

-- Safe Ace3 initialization - handle case where LibStub isn't loaded yet
local BagMaster
if LibStub then
	LogInfo("LibStub found, attempting Ace3 initialization...")
	local success, addon = pcall(function() return LibStub('AceAddon-3.0'):NewAddon('BagMaster', 'AceEvent-3.0', 'AceConsole-3.0') end)
	if success then
		LogInfo("Ace3 initialization successful")
		BagMaster = addon
	else
		LogError("Ace3 initialization failed, using fallback")
		-- Fallback: create basic addon structure
		BagMaster = {}
		BagMaster.frames = {}
		BagMaster.items = {}
		BagMaster.categorizedItems = {}
	end
else
	LogError("LibStub not found, using fallback")
	-- Fallback: create basic addon structure
	BagMaster = {}
	BagMaster.frames = {}
	BagMaster.items = {}
	BagMaster.categorizedItems = {}
end

-- Safe localization access
local L = {}
if LibStub then
	local success, locale = pcall(function() return LibStub('AceLocale-3.0'):GetLocale('BagMaster') end)
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

-- Item categories for organization
BagMaster.Categories = {
	'Consumables',    -- Food, potions, elixirs, etc.
	'Equipment',      -- Weapons, armor, trinkets
	'TradeGoods',     -- Materials, reagents, crafting items
	'Quest',          -- Quest items
	'Currency',       -- Money, tokens, badges
	'Junk',           -- Items to sell
	'Other'           -- Everything else
}

-- Category order (priority for sorting)
BagMaster.CategoryOrder = {
	['Consumables'] = 1,
	['Equipment'] = 2,
	['TradeGoods'] = 3,
	['Quest'] = 4,
	['Currency'] = 5,
	['Junk'] = 6,
	['Other'] = 7
}

--[[
	Binding Setup
--]]

BINDING_HEADER_BAGMASTER = 'BagMaster'
BINDING_NAME_BAGMASTER_TOGGLE = GetLocalizedText('ToggleBags', 'Toggle BagMaster')
BINDING_NAME_BAGMASTER_SORT = GetLocalizedText('CmdSort', 'Sort Inventory')
BINDING_NAME_BAGMASTER_ORGANIZE = GetLocalizedText('CmdOrganize', 'Organize Inventory')

--[[
	Startup
--]]

function BagMaster:OnInitialize()
	LogInfo("OnInitialize called")
	
	self.frames = {}
	self.items = {}
	self.categorizedItems = {}
	self.currentView = 'bags' -- bags, bank, keyring
	
	LogInfo("Initializing settings...")
	-- Initialize settings
	self:InitializeSettings()
	
	LogInfo("Initializing classic UI elements...")
	-- Initialize classic UI elements
	self:InitializeClassicUIElements()
	
	LogInfo("Hooking bag events...")
	-- Hook into bag events
	self:HookBagEvents()
	
	LogInfo("Registering slash commands...")
	-- Register slash commands
	self:RegisterSlashCommands()
	
	LogInfo("Creating main frame...")
	-- Create main frame
	self:CreateMainFrame()
	
	LogInfo("Hooking bag opening functions...")
	-- Hook into bag opening functions
	self:HookBagOpening()
	
	print("|cFF00FF00BagMaster|r loaded. Type /bagmaster for help.")
end

function BagMaster:OnEnable()
	-- Register events
	self:RegisterEvent('BAG_UPDATE')
	self:RegisterEvent('ITEM_LOCK_CHANGED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('BANKFRAME_OPENED')
	self:RegisterEvent('BANKFRAME_CLOSED')
	self:RegisterEvent('PLAYERBANKSLOTS_CHANGED')
	
	-- Hook into bag opening functions
	self:HookBagOpening()
end

-- Fallback initialization for when Ace3 isn't available
if not BagMaster.OnInitialize then
	LogError("Using fallback initialization (Ace3 not available)")
	-- Create event frame for fallback event handling
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_LOGIN")
	eventFrame:RegisterEvent("BAG_UPDATE")
	eventFrame:RegisterEvent("ITEM_LOCK_CHANGED")
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("BANKFRAME_OPENED")
	eventFrame:RegisterEvent("BANKFRAME_CLOSED")
	eventFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	
	eventFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			LogInfo("PLAYER_LOGIN event received, initializing...")
			-- Initialize addon
			BagMaster.frames = {}
			BagMaster.items = {}
			BagMaster.categorizedItems = {}
			BagMaster.currentView = 'bags' -- bags, bank, keyring
			
			LogInfo("Initializing settings...")
			-- Initialize settings
			BagMaster:InitializeSettings()
			
			LogInfo("Initializing classic UI elements...")
			-- Initialize classic UI elements
			BagMaster:InitializeClassicUIElements()
			
			LogInfo("Hooking bag events...")
			-- Hook into bag events
			BagMaster:HookBagEvents()
			
			LogInfo("Registering slash commands...")
			-- Register slash commands
			BagMaster:RegisterSlashCommands()
			
			LogInfo("Creating main frame...")
			-- Create main frame
			BagMaster:CreateMainFrame()
			
			LogInfo("Hooking bag opening functions...")
			-- Hook into bag opening functions
			BagMaster:HookBagOpening()
			
			print("|cFF00FF00BagMaster|r loaded. Type /bagmaster for help.")
		elseif event == "BAG_UPDATE" then
			BagMaster:AutoOrganize()
		elseif event == "ITEM_LOCK_CHANGED" then
			-- Handle item lock changes
		elseif event == "PLAYER_ENTERING_WORLD" then
			BagMaster:AutoOrganize()
		elseif event == "BANKFRAME_OPENED" then
			BagMaster:SwitchToBank()
		elseif event == "BANKFRAME_CLOSED" then
			BagMaster:SwitchToBags()
		elseif event == "PLAYERBANKSLOTS_CHANGED" then
			BagMaster:AutoOrganize()
		end
	end)
	else
		LogInfo("Ace3 initialization successful, OnInitialize will be called")
	end

--[[
	Settings Management
--]]

function BagMaster:InitializeSettings()
	-- Default settings
	self.defaults = {
		autoSort = true,
		autoOrganize = true,
		showCategories = true,
		categoryOrder = self.CategoryOrder,
		showBank = true,
		showKeyring = true,
		defaultView = 'bags', -- bags, bank, keyring
		framePosition = { x = 0, y = 0 },
		frameSize = { width = 600, height = 400 },
	}
	
	-- Initialize saved variables (global only)
	BagMasterGlobalSettings = BagMasterGlobalSettings or {}
	
	-- Apply defaults
	self:ApplyDefaults(BagMasterGlobalSettings, self.defaults)
end

function BagMaster:ApplyDefaults(target, defaults)
	for key, value in pairs(defaults) do
		if target[key] == nil then
			target[key] = value
		end
	end
end

--[[
	Item Categorization
--]]

function BagMaster:CategorizeItem(itemLink, itemID)
	if not itemLink then return 'Other' end
	
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink)
	
	-- Check item type and categorize
	if itemType == "Consumable" then
		return 'Consumables'
	elseif itemType == "Armor" or itemType == "Weapon" then
		return 'Equipment'
	elseif itemType == "Trade Goods" then
		return 'TradeGoods'
	elseif itemType == "Quest" then
		return 'Quest'
	elseif itemType == "Miscellaneous" and itemSubType == "Junk" then
		return 'Junk'
	elseif itemType == "Currency" then
		return 'Currency'
	else
		return 'Other'
	end
end

function BagMaster:GetAllItems()
	local items = {}
	
	-- Determine which inventory to scan based on current view
	local view = self.currentView or 'bags'
	
	if view == 'bags' then
		-- Scan regular bags (0-4)
		for bagID = 0, 4 do
			local numSlots = GetContainerNumSlots(bagID)
			for slotID = 1, numSlots do
				local itemLink = GetContainerItemLink(bagID, slotID)
				if itemLink then
					local itemTexture, itemCount, itemLocked, itemQuality, itemReadable, itemLootable, itemLink = GetContainerItemInfo(bagID, slotID)
					table.insert(items, {
						bagID = bagID,
						slotID = slotID,
						itemLink = itemLink,
						itemTexture = itemTexture,
						itemCount = itemCount,
						itemQuality = itemQuality,
						category = self:CategorizeItem(itemLink),
						inventoryType = 'bags',
						bagName = self:GetBagName(bagID),
						slotInfo = string.format("Bag %d, Slot %d", bagID, slotID)
					})
				end
			end
		end
	elseif view == 'bank' then
		-- Scan bank bags (-1 for bank, 5-11 for bank bags)
		-- Bank main slots
		for slotID = 1, GetContainerNumSlots(-1) do
			local itemLink = GetContainerItemLink(-1, slotID)
			if itemLink then
				local itemTexture, itemCount, itemLocked, itemQuality, itemReadable, itemLootable, itemLink = GetContainerItemInfo(-1, slotID)
				table.insert(items, {
					bagID = -1,
					slotID = slotID,
					itemLink = itemLink,
					itemTexture = itemTexture,
					itemCount = itemCount,
					itemQuality = itemQuality,
					category = self:CategorizeItem(itemLink),
					inventoryType = 'bank',
					bagName = 'Bank',
					slotInfo = string.format("Bank Slot %d", slotID)
				})
			end
		end
		
		-- Bank bag slots (5-11)
		for bagID = 5, 11 do
			local numSlots = GetContainerNumSlots(bagID)
			for slotID = 1, numSlots do
				local itemLink = GetContainerItemLink(bagID, slotID)
				if itemLink then
					local itemTexture, itemCount, itemLocked, itemQuality, itemReadable, itemLootable, itemLink = GetContainerItemInfo(bagID, slotID)
					table.insert(items, {
						bagID = bagID,
						slotID = slotID,
						itemLink = itemLink,
						itemTexture = itemTexture,
						itemCount = itemCount,
						itemQuality = itemQuality,
						category = self:CategorizeItem(itemLink),
						inventoryType = 'bank',
						bagName = self:GetBagName(bagID),
						slotInfo = string.format("Bank Bag %d, Slot %d", bagID, slotID)
					})
				end
			end
		end
	elseif view == 'keyring' then
		-- Scan keyring (keyring bag ID is -2)
		local keyringBagID = -2
		local numSlots = GetContainerNumSlots(keyringBagID)
		for slotID = 1, numSlots do
			local itemLink = GetContainerItemLink(keyringBagID, slotID)
			if itemLink then
				local itemTexture, itemCount, itemLocked, itemQuality, itemReadable, itemLootable, itemLink = GetContainerItemInfo(keyringBagID, slotID)
				table.insert(items, {
					bagID = keyringBagID,
					slotID = slotID,
					itemLink = itemLink,
					itemTexture = itemTexture,
					itemCount = itemCount,
					itemQuality = itemQuality,
					category = self:CategorizeItem(itemLink),
					inventoryType = 'keyring',
					bagName = 'Keyring',
					slotInfo = string.format("Keyring Slot %d", slotID)
				})
			end
		end
	end
	
	return items
end

--[[
	Organization and Sorting
--]]

function BagMaster:OrganizeInventory()
	local items = self:GetAllItems()
	
	-- Group items by category
	local categorized = {}
	for _, item in pairs(items) do
		if not categorized[item.category] then
			categorized[item.category] = {}
		end
		table.insert(categorized[item.category], item)
	end
	
	-- Sort items within each category
	for category, categoryItems in pairs(categorized) do
		table.sort(categoryItems, function(a, b)
			-- Sort by quality first (higher quality first)
			if a.itemQuality ~= b.itemQuality then
				return a.itemQuality > b.itemQuality
			end
			-- Then by name
			local nameA = GetItemInfo(a.itemLink) or ""
			local nameB = GetItemInfo(b.itemLink) or ""
			return nameA < nameB
		end)
	end
	
	self.categorizedItems = categorized
	return categorized
end

function BagMaster:AutoOrganize()
	if BagMasterGlobalSettings.autoOrganize then
		self:OrganizeInventory()
		self:UpdateDisplay()
	end
end

--[[
	Inventory View Management
--]]

function BagMaster:SwitchToBags()
	self.currentView = 'bags'
	self:AutoOrganize()
	self:UpdateMainFrame()
	self:UpdateClassicUIButtons()
end

function BagMaster:SwitchToBank()
	self.currentView = 'bank'
	self:AutoOrganize()
	self:UpdateMainFrame()
	self:UpdateClassicUIButtons()
end

function BagMaster:SwitchToKeyring()
	self.currentView = 'keyring'
	self:AutoOrganize()
	self:UpdateMainFrame()
	self:UpdateClassicUIButtons()
end

function BagMaster:ToggleView()
	local views = {'bags', 'bank', 'keyring'}
	local currentIndex = 1
	
	-- Find current view index
	for i, view in ipairs(views) do
		if view == self.currentView then
			currentIndex = i
			break
		end
	end
	
	-- Switch to next view
	currentIndex = currentIndex + 1
	if currentIndex > #views then
		currentIndex = 1
	end
	
	self.currentView = views[currentIndex]
	self:OrganizeInventory()
	self:UpdateDisplay()
end

--[[
	Event Handlers
--]]

function BagMaster:BAG_UPDATE(event, bagID)
	-- Update when bags change
	self:AutoOrganize()
end

function BagMaster:ITEM_LOCK_CHANGED(event, bagID, slotID)
	-- Handle item lock changes
end

function BagMaster:PLAYER_ENTERING_WORLD()
	-- Initial organization when entering world
	self:AutoOrganize()
end

function BagMaster:BANKFRAME_OPENED()
	-- Switch to bank view when bank is opened
	if BagMasterGlobalSettings.showBank then
		self:SwitchToBank()
	end
end

function BagMaster:BANKFRAME_CLOSED()
	-- Switch back to bags when bank is closed
	self:SwitchToBags()
end

function BagMaster:PLAYERBANKSLOTS_CHANGED()
	-- Update when bank slots change
	if self.currentView == 'bank' then
		self:AutoOrganize()
	end
end

--[[
	Slash Commands
--]]

function BagMaster:RegisterSlashCommands()
	if self.RegisterChatCommand then
		-- Ace3 method
		self:RegisterChatCommand('bagmaster', 'HandleSlashCommand')
		self:RegisterChatCommand('bm', 'HandleSlashCommand')
	else
		-- Fallback method
		SLASH_BAGMASTER1 = "/bagmaster"
		SLASH_BAGMASTER2 = "/bm"
		SlashCmdList["BAGMASTER"] = function(msg)
			BagMaster:HandleSlashCommand(msg)
		end
		LogInfo("Using fallback slash command registration")
	end
end

function BagMaster:HandleSlashCommand(input)
	local command = string.lower(input)
	
	if command == 'test' then
		LogInfo("Test command received!")
		self:CreateMainFrame()
		return
	elseif command == 'sort' or command == 's' then
		self:OrganizeInventory()
		print("|cFF00FF00BagMaster|r: Inventory sorted.")
	elseif command == 'organize' or command == 'o' then
		self:AutoOrganize()
		print("|cFF00FF00BagMaster|r: Inventory organized.")
	elseif command == 'toggle' or command == 't' then
		self:ToggleMainFrame()
	elseif command == 'bags' or command == 'b' then
		self:SwitchToBags()
		print("|cFF00FF00BagMaster|r: Switched to bags view.")
	elseif command == 'bank' then
		self:SwitchToBank()
		print("|cFF00FF00BagMaster|r: Switched to bank view.")
	elseif command == 'keyring' or command == 'k' then
		self:SwitchToKeyring()
		print("|cFF00FF00BagMaster|r: Switched to keyring view.")
	elseif command == 'view' or command == 'v' then
		self:ToggleView()
		print("|cFF00FF00BagMaster|r: Switched to " .. self.currentView .. " view.")
	elseif command == 'help' or command == 'h' or command == '' then
		self:ShowHelp()
	else
		print("|cFF00FF00BagMaster|r: Unknown command. Type /bagmaster help for options.")
	end
end

function BagMaster:ShowHelp()
	print("|cFF00FF00BagMaster Commands:|r")
	print("  /bagmaster test - Test the addon (creates test frame)")
	print("  /bagmaster sort - Sort inventory")
	print("  /bagmaster organize - Organize inventory")
	print("  /bagmaster toggle - Toggle window")
	print("  /bagmaster bags - Switch to bags view")
	print("  /bagmaster bank - Switch to bank view")
	print("  /bagmaster keyring - Switch to keyring view")
	print("  /bagmaster view - Cycle through views")
	print("  /bagmaster help - Show this help")
end

--[[
	Frame Management (Placeholder)
--]]

function BagMaster:CreateMainFrame()
	LogInfo("CreateMainFrame called")
	
	-- Create a simple test frame to verify the addon is working
	local testFrame = CreateFrame("Frame", "BagMasterTestFrame", UIParent)
	testFrame:SetSize(200, 100)
	testFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	testFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = {left = 8, right = 8, top = 8, bottom = 8}
	})
	testFrame:SetBackdropColor(0, 0, 0, 0.8)
	testFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
	
	local title = testFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", testFrame, "TOP", 0, -10)
	title:SetText("BagMaster Test")
	title:SetTextColor(1, 1, 0)
	
	local status = testFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	status:SetPoint("CENTER", testFrame, "CENTER", 0, 0)
	status:SetText("Addon is working!")
	status:SetTextColor(0, 1, 0)
	
	local closeButton = CreateFrame("Button", nil, testFrame, "UIPanelCloseButton")
	closeButton:SetPoint("TOPRIGHT", testFrame, "TOPRIGHT", 0, 0)
	closeButton:SetScript("OnClick", function() testFrame:Hide() end)
	
	-- Hide the test frame after 5 seconds
	C_Timer.After(5, function() testFrame:Hide() end)
	
	LogInfo("Test frame created successfully")
	
	-- Store reference to main frame
	self.mainFrame = testFrame
end

function BagMaster:UpdateDisplay()
	-- TODO: Update the display with organized items
	-- This will be implemented in the components
end

function BagMaster:ToggleMainFrame()
	if self.mainFrame then
		if self.mainFrame:IsShown() then
			self.mainFrame:Hide()
		else
			self.mainFrame:Show()
		end
	else
		LogError("Main frame not found, creating new one...")
		self:CreateMainFrame()
	end
end

function BagMaster:HookBagEvents()
	-- Hook into default bag opening
	local originalOpenBackpack = OpenBackpack
	OpenBackpack = function()
		self:AutoOrganize()
		originalOpenBackpack()
	end
end

--[[
	Bag Opening Hooks
--]]

function BagMaster:HookBagOpening()
	-- Hook OpenBackpack function
	local originalOpenBackpack = OpenBackpack
	OpenBackpack = function()
		-- Show our combined inventory instead
		BagMaster:ShowCombinedInventory()
		-- Don't call original function to prevent default bag window
	end
	
	-- Hook OpenBag function
	local originalOpenBag = OpenBag
	OpenBag = function(bagID)
		-- Show our combined inventory instead
		BagMaster:ShowCombinedInventory()
		-- Don't call original function to prevent default bag window
	end
	
	-- Hook ToggleBackpack function
	local originalToggleBackpack = ToggleBackpack
	ToggleBackpack = function()
		-- Toggle our combined inventory instead
		BagMaster:ToggleCombinedInventory()
		-- Don't call original function to prevent default bag window
	end
	
	-- Hook ToggleBag function
	local originalToggleBag = ToggleBag
	ToggleBag = function(bagID)
		-- Toggle our combined inventory instead
		BagMaster:ToggleCombinedInventory()
		-- Don't call original function to prevent default bag window
	end
end

function BagMaster:ShowCombinedInventory()
	-- Switch to bags view and show the window
	self:SwitchToBags()
	self:ToggleMainFrame()
end

function BagMaster:ToggleCombinedInventory()
	-- Toggle the main frame
	self:ToggleMainFrame()
end

function BagMaster:GetBagName(bagID)
	if bagID == 0 then
		return 'Backpack'
	elseif bagID == -1 then
		return 'Bank'
	elseif bagID == -2 then
		return 'Keyring'
	else
		-- Try to get bag name from item link
		local bagLink = GetInventoryItemLink("player", bagID + 19) -- Bag slots are 19-23
		if bagLink then
			local bagName = GetItemInfo(bagLink)
			return bagName or string.format("Bag %d", bagID)
		else
			return string.format("Bag %d", bagID)
		end
	end
end

--[[
	Classic UI Elements Integration
--]]

function BagMaster:InitializeClassicUIElements()
	-- Classic UI elements to include in BagMaster
	self.classicUIElements = {
		["Social"] = {
			name = "Social",
			frame = "FriendsFrame",
			icon = "Interface\\Buttons\\UI-SocialButton",
			tooltip = "Friends List",
			command = "FRIENDS"
		},
		["Guild"] = {
			name = "Guild",
			frame = "GuildFrame",
			icon = "Interface\\Buttons\\UI-GuildButton",
			tooltip = "Guild",
			command = "GUILD"
		},
		["Character"] = {
			name = "Character",
			frame = "CharacterFrame",
			icon = "Interface\\Buttons\\UI-CharacterButton",
			tooltip = "Character Info",
			command = "CHARACTER"
		},
		["Spellbook"] = {
			name = "Spellbook",
			frame = "SpellBookFrame",
			icon = "Interface\\Buttons\\UI-SpellbookButton",
			tooltip = "Spellbook",
			command = "SPELLBOOK"
		},
		["Talent"] = {
			name = "Talent",
			frame = "PlayerTalentFrame",
			icon = "Interface\\Buttons\\UI-TalentButton",
			tooltip = "Talents",
			command = "TALENTS"
		},
		["Achievement"] = {
			name = "Achievement",
			frame = "AchievementFrame",
			icon = "Interface\\Buttons\\UI-AchievementButton",
			tooltip = "Achievements",
			command = "ACHIEVEMENT"
		},
		["Quest"] = {
			name = "Quest",
			frame = "QuestLogFrame",
			icon = "Interface\\Buttons\\UI-QuestButton",
			tooltip = "Quest Log",
			command = "QUEST"
		},
		["Help"] = {
			name = "Help",
			frame = "HelpFrame",
			icon = "Interface\\Buttons\\UI-HelpButton",
			tooltip = "Help",
			command = "HELP"
		},
		["Options"] = {
			name = "Options",
			frame = "InterfaceOptionsFrame",
			icon = "Interface\\Buttons\\UI-OptionsButton",
			tooltip = "Interface Options",
			command = "OPTIONS"
		},
		["Store"] = {
			name = "Store",
			frame = "StoreFrame",
			icon = "Interface\\Buttons\\UI-StoreButton",
			tooltip = "Store",
			command = "STORE"
		}
	}
	
	-- Initialize settings for classic UI elements
	if not self.settings.classicUI then
		self.settings.classicUI = {
			enabled = true,
			showInBags = true,
			showInBank = true,
			showInKeyring = true,
			buttonSize = 24,
			position = "top" -- top, bottom, left, right
		}
	end
end

function BagMaster:CreateClassicUIButtons(parent)
	if not self.settings.classicUI or not self.settings.classicUI.enabled then
		return {}
	end
	
	local buttons = {}
	local buttonSize = self.settings.classicUI.buttonSize or 24
	local spacing = 2
	local startX = 10
	local startY = -10
	
	-- Create button container
	local buttonContainer = CreateFrame("Frame", nil, parent)
	buttonContainer:SetSize(300, buttonSize + 10)
	buttonContainer:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	
	-- Create classic UI buttons
	local xOffset = startX
	for elementID, elementData in pairs(self.classicUIElements) do
		local button = CreateFrame("Button", nil, buttonContainer)
		button:SetSize(buttonSize, buttonSize)
		button:SetPoint("TOPLEFT", buttonContainer, "TOPLEFT", xOffset, startY)
		
		-- Button background
		local bg = button:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetTexture("Interface\\Buttons\\UI-Silver-Button-Up")
		bg:SetTexCoord(0, 0.25, 0, 0.25)
		bg:SetVertexColor(0.3, 0.3, 0.3, 0.8)
		
		-- Button icon
		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetSize(buttonSize - 4, buttonSize - 4)
		icon:SetPoint("CENTER")
		icon:SetTexture(elementData.icon)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		
		-- Button border
		local border = button:CreateTexture(nil, "OVERLAY")
		border:SetAllPoints()
		border:SetTexture("Interface\\Buttons\\UI-Silver-Button-Border")
		border:SetTexCoord(0, 0.25, 0, 0.25)
		border:SetVertexColor(0.6, 0.6, 0.6, 0.8)
		
		-- Tooltip
		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(elementData.tooltip)
			GameTooltip:Show()
		end)
		
		button:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
		
		-- Click handler
		button:SetScript("OnClick", function(self, mouseButton)
			if mouseButton == "LeftButton" then
				self:ToggleClassicUIElement(elementData)
			elseif mouseButton == "RightButton" then
				self:ShowClassicUIElementOptions(elementData)
			end
		end)
		
		-- Store element data
		button.elementData = elementData
		button.elementID = elementID
		
		-- Add to buttons table
		buttons[elementID] = button
		
		xOffset = xOffset + buttonSize + spacing
	end
	
	-- Store container reference
	parent.classicUIButtons = buttons
	parent.classicUIContainer = buttonContainer
	
	return buttons
end

function BagMaster:ToggleClassicUIElement(elementData)
	local frameName = elementData.frame
	local frame = _G[frameName]
	
	if not frame then
		-- Try to open via command
		if elementData.command then
			RunBinding(elementData.command)
		end
		return
	end
	
	-- Toggle the frame
	if frame:IsShown() then
		frame:Hide()
	else
		frame:Show()
	end
end

function BagMaster:ShowClassicUIElementOptions(elementData)
	-- TODO: Implement options menu for classic UI elements
	print("|cFF00FF00BagMaster|r: Options for " .. elementData.name .. " not yet implemented.")
end

function BagMaster:UpdateClassicUIButtons()
	-- Update classic UI buttons based on current view
	if not self.mainFrame or not self.mainFrame.classicUIButtons then
		return
	end
	
	local currentView = self.currentView or 'bags'
	local showButtons = false
	
	if currentView == 'bags' and self.settings.classicUI.showInBags then
		showButtons = true
	elseif currentView == 'bank' and self.settings.classicUI.showInBank then
		showButtons = true
	elseif currentView == 'keyring' and self.settings.classicUI.showInKeyring then
		showButtons = true
	end
	
	if self.mainFrame.classicUIContainer then
		if showButtons then
			self.mainFrame.classicUIContainer:Show()
		else
			self.mainFrame.classicUIContainer:Hide()
		end
	end
end 