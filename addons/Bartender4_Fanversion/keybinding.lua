--[[
	Bartender4_Fanversion Keybinding Module
	Enhanced keybinding functionality with hover-to-bind feature
--]]

Bartender4_Fanversion.Keybinding = {}

--[[
	Keybinding Mode Management
--]]

function Bartender4_Fanversion:SetupKeybindingMode()
	-- Create keybinding mode indicator
	local indicator = CreateFrame("Frame", "BT4_KeybindingIndicator", UIParent)
	indicator:SetSize(200, 50)
	indicator:SetPoint("TOP", UIParent, "TOP", 0, -50)
	indicator:SetFrameStrata("FULLSCREEN_DIALOG")
	
	-- Background
	local bg = indicator:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
	bg:SetVertexColor(0, 0, 0, 0.8)
	
	-- Border
	local border = indicator:CreateTexture(nil, "OVERLAY")
	border:SetAllPoints()
	border:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	border:SetTexCoord(0, 1, 0, 1)
	
	-- Text
	local text = indicator:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	text:SetPoint("CENTER")
	text:SetText("|cFFFFD700Keybinding Mode Active|r")
	
	-- Instructions
	local instructions = indicator:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	instructions:SetPoint("TOP", text, "BOTTOM", 0, -5)
	instructions:SetText("|cFF00FF00Hover over buttons and press keys|r")
	
	indicator.text = text
	indicator.instructions = instructions
	indicator:Hide()
	
	self.keybindingIndicator = indicator
end

function Bartender4_Fanversion:ShowKeybindingIndicator()
	if self.keybindingIndicator then
		self.keybindingIndicator:Show()
	end
end

function Bartender4_Fanversion:HideKeybindingIndicator()
	if self.keybindingIndicator then
		self.keybindingIndicator:Hide()
	end
end

--[[
	Enhanced Keybinding Handler
--]]

function Bartender4_Fanversion:SetupEnhancedKeybindingHandler()
	-- Create enhanced key handler with better key detection
	local keyHandler = CreateFrame("Frame", "BT4_EnhancedKeyHandler", UIParent)
	keyHandler:SetAllPoints()
	keyHandler:EnableKeyboard(true)
	keyHandler:SetFrameStrata("FULLSCREEN_DIALOG")
	
	-- Track modifier keys
	keyHandler.modifiers = {}
	
	keyHandler:SetScript("OnKeyDown", function(self, key)
		if not Bartender4_Fanversion.keybindingMode then return end
		
		-- Update modifiers
		self.modifiers[key] = true
		
		-- Handle special keys
		if key == "ESCAPE" then
			Bartender4_Fanversion:ExitKeybindingMode()
			return
		end
		
		-- Only process non-modifier keys
		if not self:IsModifierKey(key) then
			Bartender4_Fanversion:ProcessKeybinding(key, self.modifiers)
		end
	end)
	
	keyHandler:SetScript("OnKeyUp", function(self, key)
		self.modifiers[key] = nil
	end)
	
	keyHandler:SetScript("OnMouseDown", function(self, button)
		if not Bartender4_Fanversion.keybindingMode then return end
		
		-- Handle mouse button bindings
		if button == "LeftButton" then
			Bartender4_Fanversion:ProcessKeybinding("BUTTON1", self.modifiers)
		elseif button == "RightButton" then
			Bartender4_Fanversion:ProcessKeybinding("BUTTON2", self.modifiers)
		elseif button == "MiddleButton" then
			Bartender4_Fanversion:ProcessKeybinding("BUTTON3", self.modifiers)
		elseif button == "Button4" then
			Bartender4_Fanversion:ProcessKeybinding("BUTTON4", self.modifiers)
		elseif button == "Button5" then
			Bartender4_Fanversion:ProcessKeybinding("BUTTON5", self.modifiers)
		end
	end)
	
	keyHandler.IsModifierKey = function(self, key)
		return key == "LSHIFT" or key == "RSHIFT" or 
			   key == "LCTRL" or key == "RCTRL" or 
			   key == "LALT" or key == "RALT"
	end
	
	self.enhancedKeyHandler = keyHandler
end

function Bartender4_Fanversion:ProcessKeybinding(key, modifiers)
	if not self.currentButton then return end
	
	-- Convert to binding format
	local binding = self:ConvertKeyToBinding(key, modifiers)
	if not binding then return end
	
	-- Set the keybinding
	self:SetKeybinding(self.currentButton, binding)
	
	-- Show feedback
	self:ShowKeybindingFeedback(binding)
end

function Bartender4_Fanversion:ConvertKeyToBinding(key, modifiers)
	-- Handle special keys
	local keyMap = {
		["BUTTON1"] = "BUTTON1",
		["BUTTON2"] = "BUTTON2", 
		["BUTTON3"] = "BUTTON3",
		["BUTTON4"] = "BUTTON4",
		["BUTTON5"] = "BUTTON5",
		["MOUSEWHEELUP"] = "MOUSEWHEELUP",
		["MOUSEWHEELDOWN"] = "MOUSEWHEELDOWN"
	}
	
	local mappedKey = keyMap[key] or key
	
	-- Build modifier string
	local modifierList = {}
	if modifiers["LSHIFT"] or modifiers["RSHIFT"] then
		table.insert(modifierList, "SHIFT")
	end
	if modifiers["LCTRL"] or modifiers["RCTRL"] then
		table.insert(modifierList, "CTRL")
	end
	if modifiers["LALT"] or modifiers["RALT"] then
		table.insert(modifierList, "ALT")
	end
	
	-- Build final binding
	local binding = ""
	if #modifierList > 0 then
		binding = table.concat(modifierList, "-") .. "-"
	end
	binding = binding .. mappedKey
	
	return binding
end

function Bartender4_Fanversion:ShowKeybindingFeedback(binding)
	-- Create temporary feedback text
	local feedback = CreateFrame("Frame", "BT4_KeybindingFeedback", UIParent)
	feedback:SetSize(300, 30)
	feedback:SetPoint("CENTER")
	feedback:SetFrameStrata("FULLSCREEN_DIALOG")
	
	-- Background
	local bg = feedback:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
	bg:SetVertexColor(0, 0.5, 0, 0.9)
	
	-- Border
	local border = feedback:CreateTexture(nil, "OVERLAY")
	border:SetAllPoints()
	border:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	border:SetTexCoord(0, 1, 0, 1)
	
	-- Text
	local text = feedback:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	text:SetPoint("CENTER")
	text:SetText(string.format("|cFF00FF00Keybinding set: %s|r", binding))
	
	-- Auto-hide after 2 seconds
	C_Timer.After(2, function()
		feedback:Hide()
		feedback:SetParent(nil)
	end)
end

--[[
	Button Highlighting and Interaction
--]]

function Bartender4_Fanversion:SetupButtonHighlights()
	for barID, bar in pairs(self.bars) do
		for _, buttonData in pairs(bar.buttons) do
			local button = buttonData.frame
			if button then
				-- Create highlight overlay
				local highlight = button:CreateTexture(nil, "OVERLAY")
				highlight:SetAllPoints()
				highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
				highlight:SetBlendMode("ADD")
				highlight:SetVertexColor(1, 1, 0, 0.3) -- Subtle yellow
				highlight:Hide()
				
				-- Store reference
				button.bt4Highlight = highlight
				
				-- Add enhanced hover handlers
				button:HookScript("OnEnter", function(self)
					if Bartender4_Fanversion.keybindingMode then
						Bartender4_Fanversion.currentButton = buttonData
						highlight:Show()
						highlight:SetVertexColor(0, 1, 0, 0.7) -- Green when hovering
						
						-- Show button info
						Bartender4_Fanversion:ShowButtonInfo(buttonData)
					end
				end)
				
				button:HookScript("OnLeave", function(self)
					if Bartender4_Fanversion.keybindingMode then
						Bartender4_Fanversion.currentButton = nil
						highlight:Hide()
						
						-- Hide button info
						Bartender4_Fanversion:HideButtonInfo()
					end
				end)
			end
		end
	end
end

function Bartender4_Fanversion:ShowButtonInfo(buttonData)
	-- Create button info display
	local infoFrame = CreateFrame("Frame", "BT4_ButtonInfo", UIParent)
	infoFrame:SetSize(250, 80)
	infoFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
	infoFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	
	-- Background
	local bg = infoFrame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
	bg:SetVertexColor(0, 0, 0, 0.8)
	
	-- Border
	local border = infoFrame:CreateTexture(nil, "OVERLAY")
	border:SetAllPoints()
	border:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	border:SetTexCoord(0, 1, 0, 1)
	
	-- Button name
	local nameText = infoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	nameText:SetPoint("TOP", infoFrame, "TOP", 0, -10)
	nameText:SetText("|cFFFFD700" .. buttonData.name .. "|r")
	
	-- Action info
	local actionText = infoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	actionText:SetPoint("TOP", nameText, "BOTTOM", 0, -5)
	actionText:SetText("|cFF00FF00Action: " .. buttonData.action .. "|r")
	
	-- Instructions
	local instructionText = infoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	instructionText:SetPoint("TOP", actionText, "BOTTOM", 0, -5)
	instructionText:SetText("|cFFFFFF00Press any key to bind|r")
	
	self.buttonInfoFrame = infoFrame
end

function Bartender4_Fanversion:HideButtonInfo()
	if self.buttonInfoFrame then
		self.buttonInfoFrame:Hide()
		self.buttonInfoFrame:SetParent(nil)
		self.buttonInfoFrame = nil
	end
end

--[[
	Keybinding Storage and Management
--]]

function Bartender4_Fanversion:SaveKeybinding(buttonData, binding)
	-- Initialize keybindings storage
	if not self.settings.keybindings then
		self.settings.keybindings = {}
	end
	
	-- Save the keybinding
	self.settings.keybindings[buttonData.action] = {
		button = buttonData.name,
		binding = binding,
		timestamp = time()
	}
	
	-- Save to persistent storage
	self:SaveSettings()
end

function Bartender4_Fanversion:LoadKeybindings()
	-- Load saved keybindings
	if self.settings.keybindings then
		for action, bindingData in pairs(self.settings.keybindings) do
			-- Apply the keybinding
			SetBinding(bindingData.binding, "ACTIONBUTTON" .. action)
		end
	end
end

function Bartender4_Fanversion:ClearKeybinding(buttonData)
	if not self.settings.keybindings then return end
	
	-- Remove the keybinding
	self.settings.keybindings[buttonData.action] = nil
	
	-- Clear the binding in-game
	SetBinding("ACTIONBUTTON" .. buttonData.action, nil)
	
	-- Save settings
	self:SaveSettings()
	
	print("|cFF00FF00Bartender4_Fanversion|r: Keybinding cleared for " .. buttonData.name)
end

function Bartender4_Fanversion:ClearAllKeybindings()
	-- Clear all saved keybindings
	self.settings.keybindings = {}
	
	-- Clear all action button bindings
	for i = 1, 120 do
		SetBinding("ACTIONBUTTON" .. i, nil)
	end
	
	-- Save settings
	self:SaveSettings()
	
	print("|cFF00FF00Bartender4_Fanversion|r: All keybindings cleared.")
end

function Bartender4_Fanversion:SaveSettings()
	-- Save to persistent storage
	if not Bartender4_FanversionDB then
		Bartender4_FanversionDB = {}
	end
	Bartender4_FanversionDB = self.settings
end

--[[
	Enhanced Keybinding Mode Entry/Exit
--]]

function Bartender4_Fanversion:EnterEnhancedKeybindingMode()
	print("|cFF00FF00Bartender4_Fanversion|r: Enhanced keybinding mode enabled.")
	print("|cFFFFD700Hover over action buttons and press keys to bind them|r")
	print("|cFFFFD700Press ESC to exit keybinding mode|r")
	
	-- Set up enhanced key handler
	self:SetupEnhancedKeybindingHandler()
	
	-- Set up button highlights
	self:SetupButtonHighlights()
	
	-- Show indicator
	self:ShowKeybindingIndicator()
	
	-- Load saved keybindings
	self:LoadKeybindings()
end

function Bartender4_Fanversion:ExitEnhancedKeybindingMode()
	print("|cFF00FF00Bartender4_Fanversion|r: Enhanced keybinding mode disabled.")
	
	-- Remove enhanced key handler
	if self.enhancedKeyHandler then
		self.enhancedKeyHandler:Hide()
		self.enhancedKeyHandler:SetParent(nil)
		self.enhancedKeyHandler = nil
	end
	
	-- Remove button highlights
	self:RemoveActionButtonHighlights()
	
	-- Hide indicator
	self:HideKeybindingIndicator()
	
	-- Hide button info
	self:HideButtonInfo()
	
	self.keybindingMode = false
	self.currentButton = nil
end 