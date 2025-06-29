--[[
  CursorTooltip - Anchor the tooltip to the cursor
  WoW 3.3.5a compatible
--]]

-- luacheck: globals CreateFrame hooksecurefunc
local frame = CreateFrame("Frame")

local function AnchorToCursor(tooltip, parent)
  if tooltip and parent then
    tooltip:SetOwner(parent, "ANCHOR_CURSOR")
  end
end

-- Hook the default anchor for GameTooltip
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
  AnchorToCursor(tooltip, parent)
end)

-- Hook the default anchor for ItemRefTooltip
hooksecurefunc("ItemRefTooltip_SetDefaultAnchor", function(tooltip, parent)
  AnchorToCursor(tooltip, parent)
end)

-- Override GameTooltip's SetOwner to ensure cursor anchoring
local originalGameTooltipSetOwner = GameTooltip.SetOwner
GameTooltip.SetOwner = function(self, owner, anchor, xOffset, yOffset)
  -- Force cursor anchoring regardless of what anchor is passed
  originalGameTooltipSetOwner(self, owner, "ANCHOR_CURSOR", xOffset, yOffset)
end

-- Override ItemRefTooltip's SetOwner to ensure cursor anchoring
local originalItemRefTooltipSetOwner = ItemRefTooltip.SetOwner
ItemRefTooltip.SetOwner = function(self, owner, anchor, xOffset, yOffset)
  -- Force cursor anchoring regardless of what anchor is passed
  originalItemRefTooltipSetOwner(self, owner, "ANCHOR_CURSOR", xOffset, yOffset)
end

-- Hook GameTooltip events to ensure cursor anchoring for all tooltip types
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
  -- Ensure unit tooltips (players, NPCs, etc.) are cursor-anchored
  if self:GetOwner() then
    self:SetOwner(self:GetOwner(), "ANCHOR_CURSOR")
  end
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
  -- Ensure spell tooltips are cursor-anchored
  if self:GetOwner() then
    self:SetOwner(self:GetOwner(), "ANCHOR_CURSOR")
  end
end)

GameTooltip:HookScript("OnTooltipSetItem", function(self)
  -- Ensure item tooltips are cursor-anchored
  if self:GetOwner() then
    self:SetOwner(self:GetOwner(), "ANCHOR_CURSOR")
  end
end)

GameTooltip:HookScript("OnTooltipSetQuest", function(self)
  -- Ensure quest tooltips are cursor-anchored
  if self:GetOwner() then
    self:SetOwner(self:GetOwner(), "ANCHOR_CURSOR")
  end
end)

GameTooltip:HookScript("OnTooltipSetTalent", function(self)
  -- Ensure talent tooltips are cursor-anchored
  if self:GetOwner() then
    self:SetOwner(self:GetOwner(), "ANCHOR_CURSOR")
  end
end)

GameTooltip:HookScript("OnTooltipSetAchievement", function(self)
  -- Ensure achievement tooltips are cursor-anchored
  if self:GetOwner() then
    self:SetOwner(self:GetOwner(), "ANCHOR_CURSOR")
  end
end)

-- Also hook ItemRefTooltip events
ItemRefTooltip:HookScript("OnTooltipSetItem", function(self)
  -- Ensure item reference tooltips are cursor-anchored
  if self:GetOwner() then
    self:SetOwner(self:GetOwner(), "ANCHOR_CURSOR")
  end
end)

ItemRefTooltip:HookScript("OnTooltipSetSpell", function(self)
  -- Ensure spell reference tooltips are cursor-anchored
  if self:GetOwner() then
    self:SetOwner(self:GetOwner(), "ANCHOR_CURSOR")
  end
end) 