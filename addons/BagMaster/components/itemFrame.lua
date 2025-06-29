--[[
	BagMaster Item Frame Component
	Placeholder for future item frame enhancements
--]]

-- This file is currently a placeholder
-- Item frames are created directly in mainFrame.lua for simplicity 

function BagMaster:CreateItemFrame(parent, itemData)
	local frame = CreateFrame("Button", nil, parent, "ContainerFrameItemButtonTemplate")
	
	-- Set item data
	frame.itemData = itemData
	
	-- Set item texture
	frame:SetNormalTexture(itemData.itemTexture)
	
	-- Set item count
	if itemData.itemCount and itemData.itemCount > 1 then
		frame.Count:SetText(itemData.itemCount)
		frame.Count:Show()
	else
		frame.Count:Hide()
	end
	
	-- Set item quality border
	if itemData.itemQuality and itemData.itemQuality > 1 then
		local r, g, b = GetItemQualityColor(itemData.itemQuality)
		frame.IconBorder:SetVertexColor(r, g, b)
		frame.IconBorder:Show()
	else
		frame.IconBorder:Hide()
	end
	
	-- Set up click handlers
	frame:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			-- Use item or pick up item
			if IsShiftKeyDown() then
				-- Split stack
				if itemData.itemCount and itemData.itemCount > 1 then
					SplitContainerItem(itemData.bagID, itemData.slotID)
				end
			else
				-- Use item
				UseContainerItem(itemData.bagID, itemData.slotID)
			end
		elseif button == "RightButton" then
			-- Show item menu
			if itemData.itemLink then
				ShowContainerItemTooltip(itemData.bagID, itemData.slotID)
			end
		end
	end)
	
	-- Set up tooltip
	frame:SetScript("OnEnter", function(self)
		if itemData.itemLink then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(itemData.itemLink)
			
			-- Add slot information to tooltip
			if itemData.slotInfo then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine("|cFF00FF00" .. itemData.slotInfo .. "|r", 1, 1, 1)
				if itemData.bagName then
					GameTooltip:AddLine("|cFF888888" .. itemData.bagName .. "|r", 0.7, 0.7, 0.7)
				end
			end
			
			GameTooltip:Show()
		end
	end)
	
	frame:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	return frame
end 