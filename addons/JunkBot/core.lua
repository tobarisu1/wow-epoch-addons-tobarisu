--[[
  JunkBot - Auto-sell Junk Items
  Automatically sells gray-quality (junk) items to vendors
--]]

local function Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cFFAAAA00JunkBot:|r " .. msg)
end

local function GetJunkItems()
  local junk = {}
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      local link = GetContainerItemLink(bag, slot)
      if link then
        local _, _, itemQuality, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(link)
        local _, itemCount = GetContainerItemInfo(bag, slot)
        if itemQuality == 0 and itemSellPrice and itemSellPrice > 0 then
          table.insert(junk, {bag = bag, slot = slot, count = itemCount or 1, price = itemSellPrice, link = link})
        end
      end
    end
  end
  return junk
end

local function SellJunk()
  local total = 0
  local count = 0
  for _, item in ipairs(GetJunkItems()) do
    for i = 1, item.count do
      UseContainerItem(item.bag, item.slot)
    end
    total = total + (item.price * item.count)
    count = count + item.count
  end
  if count > 0 then
    Print("Sold " .. count .. " junk items for " .. GetCoinTextureString(total))
  else
    Print("No junk items to sell.")
  end
end

local f = CreateFrame("Frame")
f:RegisterEvent("MERCHANT_SHOW")
f:SetScript("OnEvent", function()
  SellJunk()
end)

SLASH_JUNKBOT1 = "/junkbot"
SlashCmdList["JUNKBOT"] = function()
  SellJunk()
end 