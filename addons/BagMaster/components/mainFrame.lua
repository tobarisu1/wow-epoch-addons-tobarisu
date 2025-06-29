--[[
	BagMaster Main Frame - Fantasy Style
	Displays the organized inventory with fantasy-themed styling
--]]

-- Safe localization access - handle case where LibStub isn't loaded yet
local L = {}
if LibStub then
	local success, locale = pcall(function() return LibStub('AceLocale-3.0'):GetLocale('BagMaster') end)
	if success then
		L = locale
	end
end

-- Fallback localization if AceLocale isn't available
local function GetLocalizedText(key, default)
	return L[key] or default or key
end

BagMaster.MainFrame = {}
local MainFrame = BagMaster.MainFrame

--[[
	Frame Creation - Fantasy Style
--]]

function MainFrame:Create()
	local frame = CreateFrame('Frame', 'BagMasterMainFrame', UIParent, 'BackdropTemplate')
	frame:SetSize(650, 450)
	frame:SetPoint('CENTER')
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag('LeftButton')
	frame:SetScript('OnDragStart', frame.StartMoving)
	frame:SetScript('OnDragStop', frame.StopMovingOrSizing)
	
	-- Fantasy backdrop with ornate border
	frame:SetBackdrop({
		bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
		edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
		tile = true,
		tileSize = 32,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	frame:SetBackdropColor(0.1, 0.05, 0.02, 0.95) -- Dark brown with gold tint
	frame:SetBackdropBorderColor(0.8, 0.6, 0.2, 1) -- Golden border
	
	-- Fantasy title with ornate styling
	local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge')
	title:SetPoint('TOP', frame, 'TOP', 0, -15)
	title:SetText('|cFFFFD700BagMaster|r - |cFFC0C0C0Organized Inventory|r')
	title:SetTextColor(1, 0.8, 0.2, 1) -- Gold text
	frame.title = title
	
	-- Classic UI buttons (top of window)
	BagMaster:CreateClassicUIButtons(frame)
	
	-- View indicator
	local viewIndicator = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	viewIndicator:SetPoint('TOP', title, 'BOTTOM', 0, -5)
	viewIndicator:SetText('|cFF00FF00Bags|r')
	viewIndicator:SetTextColor(0, 1, 0, 1) -- Green text
	frame.viewIndicator = viewIndicator
	
	-- View switching buttons
	self:CreateViewButtons(frame)
	
	-- Decorative corner elements
	self:CreateCornerDecorations(frame)
	
	-- Close button with fantasy styling
	local closeButton = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
	closeButton:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -8, -8)
	closeButton:SetSize(24, 24)
	closeButton:SetScript('OnClick', function() MainFrame:Hide() end)
	frame.closeButton = closeButton
	
	-- Scroll frame for content with fantasy styling
	local scrollFrame = CreateFrame('ScrollFrame', nil, frame, 'UIPanelScrollFrameTemplate')
	scrollFrame:SetPoint('TOPLEFT', frame, 'TOPLEFT', 20, -80) -- Adjusted for classic UI buttons
	scrollFrame:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -40, 20)
	frame.scrollFrame = scrollFrame
	
	-- Content frame
	local contentFrame = CreateFrame('Frame', nil, scrollFrame)
	contentFrame:SetSize(580, 1000) -- Will be adjusted dynamically
	scrollFrame:SetScrollChild(contentFrame)
	frame.contentFrame = contentFrame
	
	-- Category frames storage
	frame.categoryFrames = {}
	
	-- Store reference
	BagMaster.mainFrame = frame
	
	return frame
end

--[[
	Fantasy Decorative Elements
--]]

function MainFrame:CreateCornerDecorations(frame)
	-- Top-left corner decoration
	local cornerTL = frame:CreateTexture(nil, 'OVERLAY')
	cornerTL:SetSize(32, 32)
	cornerTL:SetPoint('TOPLEFT', frame, 'TOPLEFT', 5, -5)
	cornerTL:SetTexture('Interface\\Buttons\\UI-Silver-Button-Up')
	cornerTL:SetTexCoord(0, 0.25, 0, 0.25)
	cornerTL:SetVertexColor(0.8, 0.6, 0.2, 0.8) -- Golden tint
	
	-- Top-right corner decoration
	local cornerTR = frame:CreateTexture(nil, 'OVERLAY')
	cornerTR:SetSize(32, 32)
	cornerTR:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -5, -5)
	cornerTR:SetTexture('Interface\\Buttons\\UI-Silver-Button-Up')
	cornerTR:SetTexCoord(0.75, 1, 0, 0.25)
	cornerTR:SetVertexColor(0.8, 0.6, 0.2, 0.8)
	
	-- Bottom-left corner decoration
	local cornerBL = frame:CreateTexture(nil, 'OVERLAY')
	cornerBL:SetSize(32, 32)
	cornerBL:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 5, 5)
	cornerBL:SetTexture('Interface\\Buttons\\UI-Silver-Button-Up')
	cornerBL:SetTexCoord(0, 0.25, 0.75, 1)
	cornerBL:SetVertexColor(0.8, 0.6, 0.2, 0.8)
	
	-- Bottom-right corner decoration
	local cornerBR = frame:CreateTexture(nil, 'OVERLAY')
	cornerBR:SetSize(32, 32)
	cornerBR:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -5, 5)
	cornerBR:SetTexture('Interface\\Buttons\\UI-Silver-Button-Up')
	cornerBR:SetTexCoord(0.75, 1, 0.75, 1)
	cornerBR:SetVertexColor(0.8, 0.6, 0.2, 0.8)
end

--[[
	View Switching Buttons
--]]

function MainFrame:CreateViewButtons(frame)
	local buttonWidth = 80
	local buttonHeight = 25
	local spacing = 5
	local startX = 20
	
	-- Bags button
	local bagsButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
	bagsButton:SetSize(buttonWidth, buttonHeight)
	bagsButton:SetPoint('TOPLEFT', frame, 'TOPLEFT', startX, -80)
	bagsButton:SetText('Bags')
	bagsButton:SetScript('OnClick', function() BagMaster:SwitchToBags() end)
	frame.bagsButton = bagsButton
	
	-- Bank button
	local bankButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
	bankButton:SetSize(buttonWidth, buttonHeight)
	bankButton:SetPoint('TOPLEFT', bagsButton, 'TOPRIGHT', spacing, 0)
	bankButton:SetText('Bank')
	bankButton:SetScript('OnClick', function() BagMaster:SwitchToBank() end)
	frame.bankButton = bankButton
	
	-- Keyring button
	local keyringButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
	keyringButton:SetSize(buttonWidth, buttonHeight)
	keyringButton:SetPoint('TOPLEFT', bankButton, 'TOPRIGHT', spacing, 0)
	keyringButton:SetText('Keyring')
	keyringButton:SetScript('OnClick', function() BagMaster:SwitchToKeyring() end)
	frame.keyringButton = keyringButton
	
	-- Update button styling to match fantasy theme
	local buttons = {bagsButton, bankButton, keyringButton}
	for _, button in ipairs(buttons) do
		button:SetNormalFontObject('GameFontNormalSmall')
		button:SetHighlightFontObject('GameFontHighlightSmall')
		button:SetDisabledFontObject('GameFontDisableSmall')
	end
end

--[[
	Display Management
--]]

function MainFrame:Show()
	if not self.frame then
		self.frame = self:Create()
	end
	self.frame:Show()
	self:UpdateDisplay()
end

function MainFrame:Hide()
	if self.frame then
		self.frame:Hide()
	end
end

function MainFrame:Toggle()
	if self.frame and self.frame:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end

function MainFrame:UpdateDisplay()
	if not self.frame or not self.frame:IsShown() then return end
	
	local categorizedItems = BagMaster.categorizedItems
	if not categorizedItems then return end
	
	-- Update view indicator
	self:UpdateViewIndicator()
	
	-- Clear existing category frames
	self:ClearCategoryFrames()
	
	local yOffset = 0
	local categoryOrder = BagMaster.CategoryOrder
	
	-- Create category frames in order
	for categoryName, _ in pairs(categoryOrder) do
		if categorizedItems[categoryName] and #categorizedItems[categoryName] > 0 then
			local categoryFrame = self:CreateCategoryFrame(categoryName, categorizedItems[categoryName], yOffset)
			yOffset = yOffset - categoryFrame:GetHeight() - 15 -- 15px spacing between categories
		end
	end
	
	-- Update content frame height
	self.frame.contentFrame:SetHeight(math.abs(yOffset) + 20)
end

function MainFrame:UpdateViewIndicator()
	if not self.frame or not self.frame.viewIndicator then return end
	
	local currentView = BagMaster.currentView or 'bags'
	local viewColors = {
		['bags'] = '|cFF00FF00', -- Green
		['bank'] = '|cFF0080FF', -- Blue
		['keyring'] = '|cFFFF8000' -- Orange
	}
	local viewNames = {
		['bags'] = 'Bags',
		['bank'] = 'Bank',
		['keyring'] = 'Keyring'
	}
	
	local color = viewColors[currentView] or '|cFF00FF00'
	local name = viewNames[currentView] or 'Bags'
	
	self.frame.viewIndicator:SetText(color .. name .. '|r')
end

function MainFrame:ClearCategoryFrames()
	for _, categoryFrame in pairs(self.frame.categoryFrames) do
		categoryFrame:Hide()
		categoryFrame:SetParent(nil)
	end
	self.frame.categoryFrames = {}
end

--[[
	Category Frame Creation - Fantasy Style
--]]

function MainFrame:CreateCategoryFrame(categoryName, items, yOffset)
	local frame = CreateFrame('Frame', nil, self.frame.contentFrame)
	frame:SetSize(580, 0) -- Height will be calculated
	frame:SetPoint('TOPLEFT', self.frame.contentFrame, 'TOPLEFT', 0, yOffset)
	
	-- Fantasy category header background
	local headerBg = frame:CreateTexture(nil, 'BACKGROUND')
	headerBg:SetPoint('TOPLEFT', frame, 'TOPLEFT', -10, 5)
	headerBg:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', 10, -25)
	headerBg:SetTexture('Interface\\Buttons\\UI-Silver-Button-Up')
	headerBg:SetTexCoord(0, 0.5, 0, 0.5)
	headerBg:SetVertexColor(0.3, 0.2, 0.1, 0.8) -- Dark brown
	frame.headerBg = headerBg
	
	-- Category header with fantasy font
	local header = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
	header:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
	header:SetText('|cFFFFD700' .. GetLocalizedText('Category_' .. categoryName, categoryName) .. '|r')
	header:SetTextColor(1, 0.8, 0.2, 1) -- Gold text
	frame.header = header
	
	-- Decorative header border
	local headerBorder = frame:CreateTexture(nil, 'OVERLAY')
	headerBorder:SetPoint('TOPLEFT', headerBg, 'TOPLEFT', 0, 0)
	headerBorder:SetPoint('BOTTOMRIGHT', headerBg, 'BOTTOMRIGHT', 0, 0)
	headerBorder:SetTexture('Interface\\Buttons\\UI-Silver-Button-Border')
	headerBorder:SetTexCoord(0, 0.5, 0, 0.5)
	headerBorder:SetVertexColor(0.8, 0.6, 0.2, 0.6) -- Golden border
	frame.headerBorder = headerBorder
	
	-- Category icon (if available)
	local categoryIcons = {
		['Consumables'] = 'Interface\\Icons\\INV_Misc_Food_02',
		['Equipment'] = 'Interface\\Icons\\INV_Sword_04',
		['TradeGoods'] = 'Interface\\Icons\\INV_Misc_Gem_01',
		['Quest'] = 'Interface\\Icons\\INV_Misc_Note_01',
		['Currency'] = 'Interface\\Icons\\INV_Misc_Coin_01',
		['Junk'] = 'Interface\\Icons\\INV_Misc_QuestionMark',
		['Other'] = 'Interface\\Icons\\INV_Misc_Bag_08'
	}
	
	if categoryIcons[categoryName] then
		local icon = frame:CreateTexture(nil, 'OVERLAY')
		icon:SetSize(20, 20)
		icon:SetPoint('LEFT', header, 'RIGHT', 10, 0)
		icon:SetTexture(categoryIcons[categoryName])
		icon:SetVertexColor(1, 0.8, 0.2, 1) -- Gold tint
		frame.icon = icon
	end
	
	-- Item frames
	local itemFrames = {}
	local itemsPerRow = 8
	local itemSize = 37
	local spacing = 3
	local currentRow = 0
	local currentCol = 0
	
	for i, item in ipairs(items) do
		local itemFrame = self:CreateItemFrame(frame, item, currentCol * (itemSize + spacing), -(currentRow * (itemSize + spacing) + 35))
		table.insert(itemFrames, itemFrame)
		
		currentCol = currentCol + 1
		if currentCol >= itemsPerRow then
			currentCol = 0
			currentRow = currentRow + 1
		end
	end
	
	frame.itemFrames = itemFrames
	
	-- Calculate frame height
	local totalRows = math.ceil(#items / itemsPerRow)
	local height = totalRows * (itemSize + spacing) + 50 -- 50px for header and padding
	frame:SetHeight(height)
	
	-- Store reference
	table.insert(self.frame.categoryFrames, frame)
	
	return frame
end

--[[
	Item Frame Creation - Fantasy Style
--]]

function MainFrame:CreateItemFrame(parent, item, x, y)
	-- Use the new item frame creation function if available
	if BagMaster.CreateItemFrame then
		local frame = BagMaster:CreateItemFrame(parent, item)
		frame:ClearAllPoints()
		frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
		return frame
	end
	
	-- Fallback to original implementation
	local frame = CreateFrame('Button', nil, parent)
	frame:SetSize(37, 37)
	frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
	
	-- Fantasy item background
	local bg = frame:CreateTexture(nil, 'BACKGROUND')
	bg:SetAllPoints()
	bg:SetTexture('Interface\\Buttons\\UI-Silver-Button-Up')
	bg:SetTexCoord(0, 0.25, 0, 0.25)
	bg:SetVertexColor(0.2, 0.15, 0.1, 0.8) -- Dark brown background
	frame.bg = bg
	
	-- Item texture
	local texture = frame:CreateTexture(nil, 'ARTWORK')
	texture:SetAllPoints()
	texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	texture:SetTexture(item.itemTexture)
	frame.texture = texture
	
	-- Item count with fantasy styling
	if item.itemCount and item.itemCount > 1 then
		local count = frame:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
		count:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, 0)
		count:SetText(item.itemCount)
		count:SetTextColor(1, 1, 0.8, 1) -- Light gold
		frame.count = count
	end
	
	-- Quality border with fantasy colors
	local quality = item.itemQuality or 1
	if quality > 1 then
		local border = frame:CreateTexture(nil, 'OVERLAY')
		border:SetAllPoints()
		border:SetTexture('Interface\\Buttons\\UI-Silver-Button-Border')
		border:SetTexCoord(0, 0.25, 0, 0.25)
		border:SetBlendMode('ADD')
		
		local colors = {
			[2] = {0.2, 0.8, 0.2, 1},    -- Uncommon (green)
			[3] = {0.2, 0.5, 0.8, 1},    -- Rare (blue)
			[4] = {0.5, 0.2, 0.8, 1},    -- Epic (purple)
			[5] = {0.8, 0.5, 0.2, 1},    -- Legendary (orange)
		}
		
		if colors[quality] then
			border:SetVertexColor(unpack(colors[quality]))
		end
		frame.border = border
	end
	
	-- Enhanced tooltip with slot information
	frame:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		GameTooltip:SetHyperlink(item.itemLink)
		
		-- Add slot information to tooltip
		if item.slotInfo then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("|cFF00FF00" .. item.slotInfo .. "|r", 1, 1, 1)
			if item.bagName then
				GameTooltip:AddLine("|cFF888888" .. item.bagName .. "|r", 0.7, 0.7, 0.7)
			end
		end
		
		GameTooltip:Show()
	end)
	
	frame:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
	end)
	
	-- Click handling
	frame:SetScript('OnClick', function(self, button)
		if button == 'LeftButton' then
			-- Handle different inventory types
			local inventoryType = item.inventoryType or 'bags'
			
			if inventoryType == 'bags' then
				-- Regular bags - use UseContainerItem
				UseContainerItem(item.bagID, item.slotID)
			elseif inventoryType == 'bank' then
				-- Bank items - use PickupContainerItem for bank
				PickupContainerItem(item.bagID, item.slotID)
			elseif inventoryType == 'keyring' then
				-- Keyring items - use PickupContainerItem for keyring
				PickupContainerItem(item.bagID, item.slotID)
			end
		elseif button == 'RightButton' then
			-- Show context menu
			BagMaster:ShowItemContextMenu(item, self)
		end
	end)
	
	-- Store item data
	frame.item = item
	
	return frame
end

--[[
	Context Menu
--]]

function BagMaster:ShowItemContextMenu(item, frame)
	-- TODO: Implement context menu for items
	-- This could include options like "Move to top of category", "Mark as favorite", etc.
end

--[[
	Global Functions
--]]

function BagMaster:CreateMainFrame()
	MainFrame:Create()
end

function BagMaster:UpdateDisplay()
	MainFrame:UpdateDisplay()
end

function BagMaster:ToggleMainFrame()
	MainFrame:Toggle()
end 