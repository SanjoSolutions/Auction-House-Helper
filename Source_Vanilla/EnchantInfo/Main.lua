-- Add a button to the craft (enchant) frame to search the AH for the reagents.
-- The button will be hidden when the AH is closed.
-- The total price is shown in a FontString next to the button
local addedFunctionality = false
function AuctionHouseHelper.EnchantInfo.Initialize()
  if addedFunctionality then
    return
  end

  if CraftFrame then
    addedFunctionality = true

    CreateFrame("Frame", "AuctionHouseHelperEnchantInfoFrame", CraftFrame, "AuctionHouseHelperEnchantInfoFrameTemplate");
  end
end

function AuctionHouseHelper.EnchantInfo.DoCraftReagentsSearch()
  local craftIndex = GetCraftSelectionIndex()
  local craftInfo =  { GetCraftInfo(craftIndex) }

  local items = {craftInfo[1]}

  for reagentIndex = 1, GetCraftNumReagents(craftIndex) do
    local reagentName = GetCraftReagentInfo(craftIndex, reagentIndex)
    table.insert(items, reagentName)
  end

  AuctionHouseHelper.API.v1.MultiSearch(AUCTION_HOUSE_HELPER_L_REAGENT_SEARCH, items)
end

function AuctionHouseHelper.EnchantInfo.GetCraftReagentsTotal()
  local craftIndex = GetCraftSelectionIndex()

  local total = 0

  for reagentIndex = 1, GetCraftNumReagents(craftIndex) do
    local multiplier = select(3, GetCraftReagentInfo(craftIndex, reagentIndex))
    local link = GetCraftReagentItemLink(craftIndex, reagentIndex)
    if link ~= nil then
      local vendorPrice = AuctionHouseHelper.API.v1.GetVendorPriceByItemLink(AUCTION_HOUSE_HELPER_L_REAGENT_SEARCH, link)
      local auctionPrice = AuctionHouseHelper.API.v1.GetAuctionPriceByItemLink(AUCTION_HOUSE_HELPER_L_REAGENT_SEARCH, link)

      local unitPrice = vendorPrice or auctionPrice

      if unitPrice ~= nil then
        total = total + multiplier * unitPrice
      end
    end
  end

  return total
end

function AuctionHouseHelper.EnchantInfo.GetInfoText()
  if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW_COST) then
    local price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(AuctionHouseHelper.EnchantInfo.GetCraftReagentsTotal(), true))
    return AUCTION_HOUSE_HELPER_L_TO_CRAFT_COLON .. " " .. price
  else
    return ""
  end
end
