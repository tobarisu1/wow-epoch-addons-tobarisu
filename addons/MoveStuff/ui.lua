--[[
	MoveStuff UI - Simple Frame Selection Interface
--]]

MoveStuff.UI = {}

--[[
	Frame Selection UI
--]]

function MoveStuff:CreateFrameSelector()
	if self.frameSelector then
		self.frameSelector:Show()
		return
	end
	
	local frame = CreateFrame("Frame", "MoveStuffFrameSelector", UIParent, "BackdropTemplate")
	frame:SetSize(300, 400)
	frame:SetPoint("CENTER")
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	
	-- Classic backdrop
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
	frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	
	-- Title
	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", frame, "TOP", 0, -10)
	title:SetText("|cFFFFD700MoveStuff|r - Frame Selector")
	
	-- Close button
	local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
	closeButton:SetScript("OnClick", function() frame:Hide() end)
	
	-- Search box
	local searchBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	searchBox:SetSize(200, 20)
	searchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -35)
	searchBox:SetScript("OnTextChanged", function(self)
		MoveStuff:FilterFrameList(self:GetText())
	end)
	searchBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)
	searchBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)
	
	local searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	searchLabel:SetPoint("BOTTOMLEFT", searchBox, "TOPLEFT", 0, 2)
	searchLabel:SetText("Search:")
	
	-- Frame list
	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -60)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
	
	local contentFrame = CreateFrame("Frame", nil, scrollFrame)
	contentFrame:SetSize(250, 1000)
	scrollFrame:SetScrollChild(contentFrame)
	
	-- Store references
	frame.contentFrame = contentFrame
	frame.searchBox = searchBox
	self.frameSelector = frame
	
	-- Populate frame list
	self:PopulateFrameList()
	
	return frame
end

function MoveStuff:PopulateFrameList()
	if not self.frameSelector then return end
	
	local contentFrame = self.frameSelector.contentFrame
	local categorized = self:GetFrameList()
	
	-- Clear existing content
	for _, child in pairs({contentFrame:GetChildren()}) do
		child:Hide()
		child:SetParent(nil)
	end
	
	local yOffset = 0
	
	for category, frames in pairs(categorized) do
		if #frames > 0 then
			-- Category header
			local header = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
			header:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset)
			header:SetText("|cFFFFD700" .. category .. "|r")
			yOffset = yOffset - 20
			
			-- Frame buttons
			for _, frameData in ipairs(frames) do
				local button = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
				button:SetSize(200, 20)
				button:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, yOffset)
				button:SetText(frameData.name)
				button:SetScript("OnClick", function()
					MoveStuff:StartMoving(frameData.name)
					self.frameSelector:Hide()
				end)
				yOffset = yOffset - 25
			end
			
			yOffset = yOffset - 10 -- Spacing between categories
		end
	end
	
	-- Update content frame height
	contentFrame:SetHeight(math.abs(yOffset) + 20)
end

function MoveStuff:FilterFrameList(searchText)
	if not self.frameSelector then return end
	
	local contentFrame = self.frameSelector.contentFrame
	local categorized = self:GetFrameList()
	
	-- Clear existing content
	for _, child in pairs({contentFrame:GetChildren()}) do
		child:Hide()
		child:SetParent(nil)
	end
	
	local yOffset = 0
	searchText = string.lower(searchText or "")
	
	for category, frames in pairs(categorized) do
		local visibleFrames = {}
		
		-- Filter frames by search text
		for _, frameData in ipairs(frames) do
			if searchText == "" or string.find(string.lower(frameData.name), searchText) then
				table.insert(visibleFrames, frameData)
			end
		end
		
		if #visibleFrames > 0 then
			-- Category header
			local header = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
			header:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset)
			header:SetText("|cFFFFD700" .. category .. "|r")
			yOffset = yOffset - 20
			
			-- Frame buttons
			for _, frameData in ipairs(visibleFrames) do
				local button = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
				button:SetSize(200, 20)
				button:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, yOffset)
				button:SetText(frameData.name)
				button:SetScript("OnClick", function()
					MoveStuff:StartMoving(frameData.name)
					self.frameSelector:Hide()
				end)
				yOffset = yOffset - 25
			end
			
			yOffset = yOffset - 10 -- Spacing between categories
		end
	end
	
	-- Update content frame height
	contentFrame:SetHeight(math.abs(yOffset) + 20)
end

--[[
	Frame Highlighting
--]]

function MoveStuff:HighlightFrame(frameName)
	local frame = _G[frameName]
	if not frame then return end
	
	-- Create highlight overlay
	local highlight = frame:CreateTexture(nil, "OVERLAY")
	highlight:SetAllPoints()
	highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	highlight:SetBlendMode("ADD")
	highlight:SetVertexColor(1, 1, 0, 0.5)
	
	-- Store reference
	frame.moveStuffHighlight = highlight
	
	-- Remove highlight after 3 seconds
	C_Timer.After(3, function()
		if frame.moveStuffHighlight then
			frame.moveStuffHighlight:Hide()
			frame.moveStuffHighlight:SetParent(nil)
			frame.moveStuffHighlight = nil
		end
	end)
end

--[[
	UI Integration
--]]

function MoveStuff:ShowFrameSelector()
	self:CreateFrameSelector()
end

function MoveStuff:HideFrameSelector()
	if self.frameSelector then
		self.frameSelector:Hide()
	end
end

function MoveStuff:ToggleFrameSelector()
	if self.frameSelector and self.frameSelector:IsShown() then
		self:HideFrameSelector()
	else
		self:ShowFrameSelector()
	end
end 