-- Add a button to the tradeskill frame to search the AH for the reagents.
-- The button will be hidden when the AH is closed.
-- The total price is shown in a FontString next to the button
local addedFunctionality = false
function Auctionator.CraftingInfo.Initialize()
  if addedFunctionality then
    return
  end

  if TradeSkillFrame then
    addedFunctionality = true
    CreateFrame("Frame", "AuctionatorCraftingInfo", TradeSkillFrame, "AuctionatorCraftingInfoFrameTemplate");
  end
end

local function EnchantLinkToItemID(enchantLink)
  return Auctionator.CraftingInfo.EnchantSpellsToItems[tonumber(enchantLink:match("enchant:(%d+)"))]
end

local function GetOutputName(callback)
  local recipeIndex = GetTradeSkillSelectionIndex()
  local outputLink = GetTradeSkillItemLink(recipeIndex)
  local itemID

  if outputLink then
    itemID = GetItemInfoInstant(outputLink)
  else -- Probably an enchant
    itemID = EnchantLinkToItemID(GetTradeSkillRecipeLink(recipeIndex))
    if itemID == nil then
      callback(nil)
      return
    end
  end

  local item = Item:CreateFromItemID(itemID)
  if item:IsItemEmpty() then
    callback(nil)
  else
    item:ContinueOnItemLoad(function()
      callback(item:GetItemName())
    end)
  end
end

function Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  GetOutputName(function(outputName)
    local items = {}
    if outputName then
      table.insert(items, outputName)
    end
    local recipeIndex = GetTradeSkillSelectionIndex()

    for reagentIndex = 1, GetTradeSkillNumReagents(recipeIndex) do
      local reagentName = GetTradeSkillReagentInfo(recipeIndex, reagentIndex)
      table.insert(items, reagentName)
    end

    Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_REAGENT_SEARCH, items)
  end)
end

local function GetSkillReagentsTotal()
  local recipeIndex = GetTradeSkillSelectionIndex()

  local total = 0

  for reagentIndex = 1, GetTradeSkillNumReagents(recipeIndex) do
    local multiplier = select(3, GetTradeSkillReagentInfo(recipeIndex, reagentIndex))
    local link = GetTradeSkillReagentItemLink(recipeIndex, reagentIndex)
    if link ~= nil then
      local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, link)
      local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, link)

      local unitPrice = vendorPrice or auctionPrice

      if unitPrice ~= nil then
        total = total + multiplier * unitPrice
      end
    end
  end

  return total
end

local function GetAHProfit()
  local recipeIndex = GetTradeSkillSelectionIndex()
  local recipeLink =  GetTradeSkillItemLink(recipeIndex)
  local minCount, maxCount = GetTradeSkillNumMade(recipeIndex)
  print('counts', minCount, maxCount)

  if recipeLink == nil or recipeLink:match("enchant:") then
    return nil
  end

  local currentAH = Auctionator.API.v1.GetAuctionPriceByItemLink(AUCTIONATOR_L_REAGENT_SEARCH, recipeLink)
  if currentAH == nil then
    currentAH = 0
  end
  local toCraft = GetSkillReagentsTotal()

  return math.floor(currentAH * minCount * Auctionator.Constants.AfterAHCut - toCraft),
    math.floor(currentAH * maxCount * Auctionator.Constants.AfterAHCut - toCraft)
end

local function CraftCostString()
  local price = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(GetSkillReagentsTotal(), true))

  return AUCTIONATOR_L_TO_CRAFT_COLON .. " " .. price
end

local function PriceString(price)
  local priceString
  if price >= 0 then
    priceString = WHITE_FONT_COLOR:WrapTextInColorCode(GetMoneyString(price, true))
  else
    priceString = RED_FONT_COLOR:WrapTextInColorCode("-" .. GetMoneyString(-price, true))
  end
  return priceString
end

local function ProfitString(minProfit, maxProfit)
  if minProfit == maxProfit then
    return AUCTIONATOR_L_PROFIT_COLON .. " " .. PriceString(minProfit)
  else
    return AUCTIONATOR_L_PROFIT_COLON .. " " .. PriceString(minProfit) .. " " .. AUCTIONATOR_L_PROFIT_TO .. " " .. PriceString(maxProfit)
  end
end

function Auctionator.CraftingInfo.GetInfoText()
  local result = ""
  local lines = 0
  if Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_COST) then
    if lines > 0 then
      result = result .. "\n"
    end
    result = result .. CraftCostString()
    lines = lines + 1
  end

  if Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_PROFIT) then
    local minProfit, maxProfit = GetAHProfit()

    if minProfit ~= nil then
      if lines > 0 then
        result = result .. "\n"
      end
      result = result .. ProfitString(minProfit, maxProfit)
      lines = lines + 1
    end
  end
  return result, lines
end
