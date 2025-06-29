--[[
	Gatherox - Crafting Node Tracker
	Records and displays locations of herbs, ore, fish, and leather sources
--]]

-- Safe Ace3 initialization
local Gatherox
if LibStub then
	local success, addon = pcall(function() return LibStub('AceAddon-3.0'):NewAddon('Gatherox', 'AceEvent-3.0', 'AceConsole-3.0') end)
	if success then
		Gatherox = addon
	else
		-- Fallback: create basic addon structure
		Gatherox = {}
		Gatherox.nodes = {}
		Gatherox.settings = {}
	end
else
	-- Fallback: create basic addon structure
	Gatherox = {}
	Gatherox.nodes = {}
	Gatherox.settings = {}
end

-- Safe localization access
local L = {}
if LibStub then
	local success, locale = pcall(function() return LibStub('AceLocale-3.0'):GetLocale('Gatherox') end)
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

-- Node categories
Gatherox.Categories = {
	['Herbs'] = {
		icon = 'Interface\\Icons\\INV_Misc_Flower_01',
		color = {0.2, 0.8, 0.2, 1}, -- Green
		events = {'LOOT_OPENED'},
		skills = {'Herbalism'}
	},
	['Ore'] = {
		icon = 'Interface\\Icons\\INV_Ore_Copper_01',
		color = {0.8, 0.6, 0.2, 1}, -- Orange
		events = {'LOOT_OPENED'},
		skills = {'Mining'}
	},
	['Fish'] = {
		icon = 'Interface\\Icons\\INV_Misc_Fish_01',
		color = {0.2, 0.5, 0.8, 1}, -- Blue
		events = {'LOOT_OPENED'},
		skills = {'Fishing'}
	},
	['Leather'] = {
		icon = 'Interface\\Icons\\INV_Misc_Pelt_Wolf_01',
		color = {0.8, 0.4, 0.2, 1}, -- Brown
		events = {'LOOT_OPENED'},
		skills = {'Skinning'}
	}
}

-- Known node names (based on Gatherer data)
Gatherox.KnownNodes = {
	-- Herbs
	['Silverleaf'] = 'Herbs',
	['Peacebloom'] = 'Herbs',
	['Earthroot'] = 'Herbs',
	['Mageroyal'] = 'Herbs',
	['Briarthorn'] = 'Herbs',
	['Bruiseweed'] = 'Herbs',
	['Wild Steelbloom'] = 'Herbs',
	['Kingsblood'] = 'Herbs',
	['Grave Moss'] = 'Herbs',
	['Liferoot'] = 'Herbs',
	['Fadeleaf'] = 'Herbs',
	['Khadgar\'s Whisker'] = 'Herbs',
	['Wintersbite'] = 'Herbs',
	['Stranglekelp'] = 'Herbs',
	['Goldthorn'] = 'Herbs',
	['Firebloom'] = 'Herbs',
	['Purple Lotus'] = 'Herbs',
	['Arthas\' Tears'] = 'Herbs',
	['Sungrass'] = 'Herbs',
	['Blindweed'] = 'Herbs',
	['Ghost Mushroom'] = 'Herbs',
	['Gromsblood'] = 'Herbs',
	['Golden Sansam'] = 'Herbs',
	['Dreamfoil'] = 'Herbs',
	['Mountain Silversage'] = 'Herbs',
	['Plaguebloom'] = 'Herbs',
	['Icecap'] = 'Herbs',
	['Black Lotus'] = 'Herbs',
	
	-- Ore
	['Copper Vein'] = 'Ore',
	['Tin Vein'] = 'Ore',
	['Silver Vein'] = 'Ore',
	['Gold Vein'] = 'Ore',
	['Iron Deposit'] = 'Ore',
	['Mithril Deposit'] = 'Ore',
	['Truesilver Deposit'] = 'Ore',
	['Small Thorium Vein'] = 'Ore',
	['Rich Thorium Vein'] = 'Ore',
	['Dark Iron Deposit'] = 'Ore',
	['Fel Iron Deposit'] = 'Ore',
	['Adamantite Deposit'] = 'Ore',
	['Rich Adamantite Deposit'] = 'Ore',
	['Khorium Vein'] = 'Ore',
	['Cobalt Deposit'] = 'Ore',
	['Rich Cobalt Deposit'] = 'Ore',
	['Saronite Deposit'] = 'Ore',
	['Rich Saronite Deposit'] = 'Ore',
	['Titanium Vein'] = 'Ore',
	
	-- Fish (fishing pools)
	['Floating Wreckage'] = 'Fish',
	['Patch of Elemental Water'] = 'Fish',
	['Firefin Snapper School'] = 'Fish',
	['Oily Blackmouth School'] = 'Fish',
	['Sagefish School'] = 'Fish',
	['Greater Sagefish School'] = 'Fish',
	['Mithril Head Trout School'] = 'Fish',
	['Highland Mixed School'] = 'Fish',
	['Stonescale Eel Swarm'] = 'Fish',
	['Brackish Mixed School'] = 'Fish',
	['Spotted Feltail School'] = 'Fish',
	['Bluefish School'] = 'Fish',
	['Fel Iron Chest'] = 'Fish',
	['Adamantite Bound Chest'] = 'Fish',
	
	-- Leather (skinning targets)
	['Wolf'] = 'Leather',
	['Bear'] = 'Leather',
	['Deer'] = 'Leather',
	['Boar'] = 'Leather',
	['Raptor'] = 'Leather',
	['Dragon'] = 'Leather',
	['Elemental'] = 'Leather',
	['Demon'] = 'Leather',
	['Beast'] = 'Leather'
}

--[[
	Startup
--]]

function Gatherox:OnInitialize()
	self.nodes = {}
	self.settings = {}
	
	-- Initialize settings
	self:InitializeSettings()
	
	-- Register events
	self:RegisterEvents()
	
	-- Register slash commands
	self:RegisterSlashCommands()
	
	-- Initialize map integration
	self:InitializeMapIntegration()
	
	print("|cFF00FF00Gatherox|r loaded. Type /gatherox for help.")
end

function Gatherox:OnEnable()
	-- Register events
	self:RegisterEvent('LOOT_OPENED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
	
	-- Initialize map integration if not already done
	if not self.minimapButton then
		self:InitializeMapIntegration()
	end
end

-- Fallback initialization for when Ace3 isn't available
if not Gatherox.OnInitialize then
	-- Create event frame for fallback event handling
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_LOGIN")
	eventFrame:RegisterEvent("LOOT_OPENED")
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	
	eventFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			-- Initialize addon
			Gatherox.nodes = {}
			Gatherox.settings = {}
			
			-- Initialize settings
			Gatherox:InitializeSettings()
			
			-- Register events
			Gatherox:RegisterEvents()
			
			-- Register slash commands
			Gatherox:RegisterSlashCommands()
			
			-- Initialize map integration
			Gatherox:InitializeMapIntegration()
			
			print("|cFF00FF00Gatherox|r loaded. Type /gatherox for help.")
		elseif event == "LOOT_OPENED" then
			Gatherox:OnLootOpened(...)
		elseif event == "PLAYER_ENTERING_WORLD" then
			Gatherox:OnPlayerEnteringWorld()
		elseif event == "ZONE_CHANGED_NEW_AREA" then
			Gatherox:OnZoneChanged()
		end
	end)
end

--[[
	Settings Management
--]]

function Gatherox:InitializeSettings()
	-- Default settings
	self.defaults = {
		autoRecord = true,
		showMinimap = true,
		showWorldMap = true,
		minimapSize = 16,
		showMessages = true
	}
	
	-- Initialize saved variables (global only)
	GatheroxData = GatheroxData or {}
	GatheroxSettings = GatheroxSettings or {}
	
	-- Apply defaults
	self:ApplyDefaults(GatheroxSettings, self.defaults)
	self.settings = GatheroxSettings
end

function Gatherox:ApplyDefaults(target, defaults)
	for key, value in pairs(defaults) do
		if target[key] == nil then
			target[key] = value
		end
	end
end

--[[
	Event Registration
--]]

function Gatherox:RegisterEvents()
	-- Hook into loot events to detect node gathering
	self:RegisterEvent('LOOT_OPENED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
end

--[[
	Node Detection and Recording
--]]

function Gatherox:OnLootOpened()
	if not self.settings.autoRecord then return end
	
	-- Get current position
	local x, y = self:GetPlayerPosition()
	if not x or not y then return end
	
	-- Check if we're near a known node
	local nodeName, nodeCategory = self:DetectNearbyNode()
	if nodeName and nodeCategory then
		self:RecordNode(nodeName, nodeCategory, x, y)
	end
end

function Gatherox:DetectNearbyNode()
	-- Check if we have a tooltip open that might indicate a node
	local tooltip = GameTooltip
	if tooltip:IsShown() then
		local tooltipText = tooltip:GetText()
		if tooltipText then
			-- Check if tooltip text matches known node names
			for nodeName, category in pairs(self.KnownNodes) do
				if string.find(tooltipText, nodeName, 1, true) then
					return nodeName, category
				end
			end
		end
	end
	
	-- Check if we're targeting something that might be a node
	local target = UnitName("target")
	if target then
		for nodeName, category in pairs(self.KnownNodes) do
			if string.find(target, nodeName, 1, true) then
				return nodeName, category
			end
		end
	end
	
	return nil, nil
end

function Gatherox:GetPlayerPosition()
	-- For WoW 3.3.5a, we need to use the older API
	local mapID = GetCurrentMapZone()
	if mapID == 0 then return nil, nil end
	
	-- Get player position on current map
	local x, y = GetPlayerMapPosition("player")
	if not x or not y then return nil, nil end
	
	return x, y
end

function Gatherox:RecordNode(nodeName, category, x, y)
	local zoneName = GetZoneText()
	local continent = GetCurrentMapContinent()
	local zone = GetCurrentMapZone()
	
	-- Create node data
	local nodeData = {
		name = nodeName,
		category = category,
		x = x,
		y = y,
		zone = zoneName,
		continent = continent,
		zoneID = zone,
		timestamp = time(),
		count = 1
	}
	
	-- Check if we already have this node recorded
	local existingNode = self:FindExistingNode(nodeName, x, y, zoneName)
	if existingNode then
		-- Update existing node
		existingNode.count = existingNode.count + 1
		existingNode.timestamp = time()
		if self.settings.showMessages then
			print("|cFF00FF00Gatherox|r: Updated node: " .. nodeName .. " (Count: " .. existingNode.count .. ")")
		end
	else
		-- Add new node
		table.insert(self.nodes, nodeData)
		if self.settings.showMessages then
			print("|cFF00FF00Gatherox|r: Recorded new node: " .. nodeName)
		end
	end
	
	-- Save data
	self:SaveData()
end

function Gatherox:FindExistingNode(nodeName, x, y, zoneName)
	for _, node in ipairs(self.nodes) do
		if node.name == nodeName and node.zone == zoneName then
			-- Check if coordinates are close (within 0.01 units)
			local distance = math.sqrt((node.x - x)^2 + (node.y - y)^2)
			if distance < 0.01 then
				return node
			end
		end
	end
	return nil
end

--[[
	Data Management
--]]

function Gatherox:SaveData()
	GatheroxData = self.nodes
end

function Gatherox:LoadData()
	self.nodes = GatheroxData or {}
end

function Gatherox:ClearData()
	self.nodes = {}
	self:SaveData()
	print("|cFF00FF00Gatherox|r: All node data cleared.")
end

function Gatherox:ExportData()
	if #self.nodes == 0 then
		print("|cFF00FF00Gatherox|r: No node data to export.")
		return
	end
	
	print("|cFF00FF00Gatherox Node Data:|r")
	for _, node in ipairs(self.nodes) do
		print(string.format("  %s (%s) - %s (%.2f, %.2f) - Count: %d", 
			node.name, node.category, node.zone, node.x, node.y, node.count))
	end
end

--[[
	Event Handlers
--]]

function Gatherox:OnPlayerEnteringWorld()
	self:LoadData()
	
	-- Update map nodes
	if self.settings.showMinimap then
		self:UpdateMinimapNodes()
	end
end

function Gatherox:OnZoneChanged()
	-- Update map nodes when zone changes
	if self.settings.showMinimap then
		self:UpdateMinimapNodes()
	end
	
	-- Update world map nodes if world map is open
	if self.settings.showWorldMap and self.worldMapFrame and self.worldMapFrame:IsShown() then
		self:UpdateWorldMapNodes()
	end
end

--[[
	Slash Commands
--]]

function Gatherox:RegisterSlashCommands()
	self:RegisterChatCommand('gatherox', 'HandleSlashCommand')
	self:RegisterChatCommand('gox', 'HandleSlashCommand')
end

function Gatherox:HandleSlashCommand(input)
	local command = string.lower(input)
	
	if command == 'toggle' or command == 't' then
		self:ToggleWindow()
	elseif command == 'clear' or command == 'c' then
		self:ClearData()
	elseif command == 'export' or command == 'e' then
		self:ExportData()
	elseif command == 'help' or command == 'h' or command == '' then
		self:ShowHelp()
	else
		print("|cFF00FF00Gatherox|r: Unknown command. Type /gatherox help for options.")
	end
end

function Gatherox:ShowHelp()
	print("|cFF00FF00Gatherox Commands:|r")
	print("  /gatherox toggle - Toggle window")
	print("  /gatherox clear - Clear all data")
	print("  /gatherox export - Export data to chat")
	print("  /gatherox help - Show this help")
end

--[[
	UI Functions (Placeholder)
--]]

function Gatherox:ToggleWindow()
	-- TODO: Implement UI window
	print("|cFF00FF00Gatherox|r: UI not yet implemented.")
end

--[[
	Map Integration
--]]

function Gatherox:InitializeMapIntegration()
	-- Create minimap button
	self:CreateMinimapButton()
	
	-- Hook into world map
	self:HookWorldMap()
	
	-- Hook into minimap
	self:HookMinimap()
end

function Gatherox:CreateMinimapButton()
	-- Create minimap button frame
	local button = CreateFrame("Button", "GatheroxMinimapButton", Minimap)
	button:SetSize(32, 32)
	button:SetFrameStrata("MEDIUM")
	button:SetMovable(true)
	button:RegisterForDrag("LeftButton")
	button:SetScript("OnDragStart", button.StartMoving)
	button:SetScript("OnDragStop", button.StopMovingOrSizing)
	
	-- Set button texture
	button:SetNormalTexture("Interface\\Icons\\INV_Misc_Map_01")
	button:SetPushedTexture("Interface\\Icons\\INV_Misc_Map_01")
	button:SetHighlightTexture("Interface\\Icons\\INV_Misc_Map_01")
	
	-- Position button on minimap
	button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
	
	-- Add tooltip
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("Gatherox")
		GameTooltip:AddLine("Click to toggle node display", 1, 1, 1)
		GameTooltip:AddLine("Right-click for options", 1, 1, 1)
		GameTooltip:Show()
	end)
	
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	-- Add click handlers
	button:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			Gatherox:ToggleNodeDisplay()
		elseif button == "RightButton" then
			Gatherox:ShowOptionsMenu()
		end
	end)
	
	self.minimapButton = button
end

function Gatherox:HookWorldMap()
	-- Hook into world map to show nodes
	local worldMap = WorldMapFrame
	if worldMap then
		-- Create node display frame
		local nodeFrame = CreateFrame("Frame", "GatheroxWorldMapFrame", worldMap)
		nodeFrame:SetAllPoints()
		nodeFrame:SetFrameStrata("OVERLAY")
		nodeFrame:Hide()
		
		-- Store node icons
		nodeFrame.nodeIcons = {}
		
		-- Show/hide based on settings
		worldMap:HookScript("OnShow", function()
			if Gatherox.settings.showWorldMap then
				nodeFrame:Show()
				Gatherox:UpdateWorldMapNodes()
			end
		end)
		
		worldMap:HookScript("OnHide", function()
			nodeFrame:Hide()
		end)
		
		self.worldMapFrame = nodeFrame
	end
end

function Gatherox:HookMinimap()
	-- Hook into minimap to show nodes
	local minimap = Minimap
	if minimap then
		-- Create node display frame
		local nodeFrame = CreateFrame("Frame", "GatheroxMinimapFrame", minimap)
		nodeFrame:SetAllPoints()
		nodeFrame:SetFrameStrata("OVERLAY")
		nodeFrame:Hide()
		
		-- Store node icons
		nodeFrame.nodeIcons = {}
		
		-- Show/hide based on settings
		if self.settings.showMinimap then
			nodeFrame:Show()
			self:UpdateMinimapNodes()
		end
		
		self.minimapFrame = nodeFrame
	end
end

function Gatherox:UpdateWorldMapNodes()
	if not self.worldMapFrame then return end
	
	-- Clear existing nodes
	for _, icon in pairs(self.worldMapFrame.nodeIcons) do
		icon:Hide()
		icon:SetParent(nil)
	end
	self.worldMapFrame.nodeIcons = {}
	
	-- Get current map info
	local continent = GetCurrentMapContinent()
	local zone = GetCurrentMapZone()
	
	-- Display nodes for current zone
	for _, node in ipairs(self.nodes) do
		if node.continent == continent and node.zoneID == zone then
			self:CreateWorldMapNodeIcon(node)
		end
	end
end

function Gatherox:UpdateMinimapNodes()
	if not self.minimapFrame then return end
	
	-- Clear existing nodes
	for _, icon in pairs(self.minimapFrame.nodeIcons) do
		icon:Hide()
		icon:SetParent(nil)
	end
	self.minimapFrame.nodeIcons = {}
	
	-- Get current zone
	local zoneName = GetZoneText()
	
	-- Display nodes for current zone
	for _, node in ipairs(self.nodes) do
		if node.zone == zoneName then
			self:CreateMinimapNodeIcon(node)
		end
	end
end

function Gatherox:CreateWorldMapNodeIcon(node)
	if not self.worldMapFrame then return end
	
	local icon = CreateFrame("Button", nil, self.worldMapFrame)
	icon:SetSize(16, 16)
	
	-- Set icon texture based on category
	local categoryInfo = self.Categories[node.category]
	if categoryInfo then
		icon:SetNormalTexture(categoryInfo.icon)
		icon:SetHighlightTexture(categoryInfo.icon)
	end
	
	-- Position icon on world map
	local x, y = self:GetWorldMapPosition(node.x, node.y)
	icon:SetPoint("CENTER", self.worldMapFrame, "TOPLEFT", x, y)
	
	-- Add tooltip
	icon:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(node.name)
		GameTooltip:AddLine("Type: " .. node.category, 1, 1, 1)
		GameTooltip:AddLine("Last found: " .. self:FormatTimestamp(node.timestamp), 1, 1, 1)
		GameTooltip:AddLine("Found " .. node.count .. " times", 1, 1, 1)
		GameTooltip:Show()
	end)
	
	icon:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	-- Store reference
	table.insert(self.worldMapFrame.nodeIcons, icon)
end

function Gatherox:CreateMinimapNodeIcon(node)
	if not self.minimapFrame then return end
	
	local icon = CreateFrame("Button", nil, self.minimapFrame)
	icon:SetSize(self.settings.minimapSize or 16, self.settings.minimapSize or 16)
	
	-- Set icon texture based on category
	local categoryInfo = self.Categories[node.category]
	if categoryInfo then
		icon:SetNormalTexture(categoryInfo.icon)
		icon:SetHighlightTexture(categoryInfo.icon)
	end
	
	-- Position icon on minimap
	local x, y = self:GetMinimapPosition(node.x, node.y)
	icon:SetPoint("CENTER", self.minimapFrame, "CENTER", x, y)
	
	-- Add tooltip
	icon:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(node.name)
		GameTooltip:AddLine("Type: " .. node.category, 1, 1, 1)
		GameTooltip:AddLine("Last found: " .. self:FormatTimestamp(node.timestamp), 1, 1, 1)
		GameTooltip:AddLine("Found " .. node.count .. " times", 1, 1, 1)
		GameTooltip:Show()
	end)
	
	icon:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	-- Store reference
	table.insert(self.minimapFrame.nodeIcons, icon)
end

function Gatherox:GetWorldMapPosition(x, y)
	-- Convert world coordinates to world map pixel coordinates
	local mapWidth = self.worldMapFrame:GetWidth()
	local mapHeight = self.worldMapFrame:GetHeight()
	
	local pixelX = x * mapWidth
	local pixelY = (1 - y) * mapHeight
	
	return pixelX, pixelY
end

function Gatherox:GetMinimapPosition(x, y)
	-- Convert world coordinates to minimap pixel coordinates
	local minimapSize = self.minimapFrame:GetWidth()
	
	-- Calculate distance and angle from player
	local playerX, playerY = self:GetPlayerPosition()
	if not playerX or not playerY then
		return 0, 0
	end
	
	local deltaX = x - playerX
	local deltaY = y - playerY
	local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
	
	-- Limit distance to minimap range
	local maxDistance = 0.5 -- Adjust based on minimap range
	if distance > maxDistance then
		distance = maxDistance
	end
	
	-- Calculate angle
	local angle = math.atan2(deltaY, deltaX)
	
	-- Convert to minimap coordinates
	local minimapX = math.cos(angle) * distance * minimapSize
	local minimapY = math.sin(angle) * distance * minimapSize
	
	return minimapX, minimapY
end

function Gatherox:FormatTimestamp(timestamp)
	local currentTime = time()
	local timeDiff = currentTime - timestamp
	
	if timeDiff < 60 then
		return "Just now"
	elseif timeDiff < 3600 then
		local minutes = math.floor(timeDiff / 60)
		return minutes .. " minute" .. (minutes > 1 and "s" or "") .. " ago"
	elseif timeDiff < 86400 then
		local hours = math.floor(timeDiff / 3600)
		return hours .. " hour" .. (hours > 1 and "s" or "") .. " ago"
	else
		local days = math.floor(timeDiff / 86400)
		return days .. " day" .. (days > 1 and "s" or "") .. " ago"
	end
end

function Gatherox:ToggleNodeDisplay()
	self.settings.showMinimap = not self.settings.showMinimap
	self.settings.showWorldMap = not self.settings.showWorldMap
	
	if self.minimapFrame then
		if self.settings.showMinimap then
			self.minimapFrame:Show()
			self:UpdateMinimapNodes()
		else
			self.minimapFrame:Hide()
		end
	end
	
	print("|cFF00FF00Gatherox|r: Node display " .. (self.settings.showMinimap and "enabled" or "disabled"))
end

function Gatherox:ShowOptionsMenu()
	-- TODO: Implement options menu
	print("|cFF00FF00Gatherox|r: Options menu not yet implemented.")
end 