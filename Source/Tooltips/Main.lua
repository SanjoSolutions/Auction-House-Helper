local L = AuctionHouseHelper.Locales.Apply

local waitingForPricing = false
-- AuctionHouseHelper.Config.Options.VENDOR_TOOLTIPS: true if should show vendor tips
-- AuctionHouseHelper.Config.Options.SHIFT_STACK_TOOLTIPS: true to show stack price when [shift] is down
-- AuctionHouseHelper.Config.Options.AUCTION_TOOLTIPS: true if should show auction tips
function AuctionHouseHelper.Tooltip.ShowTipWithPricing(tooltipFrame, itemLink, itemCount)
  if waitingForPricing or AuctionHouseHelper.Database == nil then
    return
  end
  -- Keep this commented out unless testing please.
  -- AuctionHouseHelper.Debug.Message("AuctionHouseHelper.Tooltip.ShowTipWithPricing", itemLink, itemCount)

  waitingForPricing = true
  AuctionHouseHelper.Utilities.DBKeyFromLink(itemLink, function(dbKeys)
    waitingForPricing = false
    AuctionHouseHelper.Tooltip.ShowTipWithPricingDBKey(tooltipFrame, dbKeys, itemLink, itemCount)
  end)
end

function AuctionHouseHelper.Tooltip.ShowTipWithPricingDBKey(tooltipFrame, dbKeys, itemLink, itemCount)
  if #dbKeys == 0 or AuctionHouseHelper.Utilities.IsPetDBKey(dbKeys[1]) then
    return
  end

  local showStackPrices = IsShiftKeyDown();

  if not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SHIFT_STACK_TOOLTIPS) then
    showStackPrices = not IsShiftKeyDown();
  end

  local countString = ""
  if itemCount and showStackPrices then
    countString = AuctionHouseHelper.Utilities.CreateCountString(itemCount)
  end

  local auctionPrice = AuctionHouseHelper.Database:GetFirstPrice(dbKeys)
  if auctionPrice ~= nil then
    auctionPrice = auctionPrice * (showStackPrices and itemCount or 1)
  end

  local vendorPrice, disenchantStatus, disenchantPrice
  local cannotAuction = 0;

  local itemInfo = { GetItemInfo(itemLink) };
  if (#itemInfo) ~= 0 then
    cannotAuction = AuctionHouseHelper.Utilities.IsBound(itemInfo)
    local sellPrice = itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.SELL_PRICE]

    if AuctionHouseHelper.Utilities.IsVendorable(itemInfo) then
      vendorPrice = sellPrice * (showStackPrices and itemCount or 1);
    end

    disenchantStatus = AuctionHouseHelper.Enchant.DisenchantStatus(itemInfo)
    local disenchantPriceForOne = AuctionHouseHelper.Enchant.GetDisenchantAuctionPrice(itemLink, itemInfo)
    if disenchantPriceForOne ~= nil then
      disenchantPrice = disenchantPriceForOne * (showStackPrices and itemCount or 1)
    end
  end

  local prospectStatus = false
  local prospectValue
  if AuctionHouseHelper.Prospect then
    local itemID = GetItemInfoInstant(itemLink)
    prospectStatus = AuctionHouseHelper.Prospect.IsProspectable(itemID)
    local prospectForOne = AuctionHouseHelper.Prospect.GetProspectAuctionPrice(itemID)
    if prospectForOne ~= nil then
      prospectValue = math.floor(prospectForOne * (showStackPrices and itemCount or 1))
    end
  end

  local millStatus = false
  local millValue
  if AuctionHouseHelper.Mill then
    local itemID = GetItemInfoInstant(itemLink)
    millStatus = AuctionHouseHelper.Mill.IsMillable(itemID)
    local millForOne = AuctionHouseHelper.Mill.GetMillAuctionPrice(itemID)
    if millForOne ~= nil then
      millValue = math.floor(millForOne * (showStackPrices and itemCount or 1))
    end
  end

  if AuctionHouseHelper.Debug.IsOn() then
    tooltipFrame:AddDoubleLine("DBKey", dbKeys[1])
  end

  if vendorPrice ~= nil then
    AuctionHouseHelper.Tooltip.AddVendorTip(tooltipFrame, vendorPrice, countString)
  end
  AuctionHouseHelper.Tooltip.AddAuctionTip(tooltipFrame, auctionPrice, countString, cannotAuction)
  if disenchantStatus ~= nil then
    AuctionHouseHelper.Tooltip.AddDisenchantTip(tooltipFrame, disenchantPrice, countString, disenchantStatus)

    if AuctionHouseHelper.Constants.IsClassic and IsShiftKeyDown() and AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.ENCHANT_TOOLTIPS) then
      for _, line in ipairs(AuctionHouseHelper.Enchant.GetDisenchantBreakdown(itemLink, itemInfo)) do
        tooltipFrame:AddLine(line)
      end
    end
  end

  if prospectStatus then
    AuctionHouseHelper.Tooltip.AddProspectTip(tooltipFrame, prospectValue, countString)
  end

  if millStatus then
    AuctionHouseHelper.Tooltip.AddMillTip(tooltipFrame, millValue, countString)
  end

  tooltipFrame:Show()
end

-- Each itemEntry in itemEntries should contain
-- link
-- count
local isMultiplePricesPending = false
function AuctionHouseHelper.Tooltip.ShowTipWithMultiplePricing(tooltipFrame, itemEntries)
  if isMultiplePricesPending or AuctionHouseHelper.Database == nil then
    return
  end
  isMultiplePricesPending = true

  local total = 0
  local itemCount = 0
  local itemLinks = {}
  for _, itemEntry in ipairs(itemEntries) do
    table.insert(itemLinks, itemEntry.link)
  end

  AuctionHouseHelper.Utilities.DBKeysFromMultipleLinks(itemLinks, function(allKeys)
    isMultiplePricesPending = false
    for index, dbKeys in ipairs(allKeys) do
      local itemEntry = itemEntries[index]

      tooltipFrame:AddLine(itemEntry.link)
      AuctionHouseHelper.Tooltip.ShowTipWithPricingDBKey(tooltipFrame, dbKeys, itemEntry.link, itemEntry.count)
      local auctionPrice = AuctionHouseHelper.Database:GetFirstPrice(dbKeys)
      if auctionPrice ~= nil then
        total = total + (auctionPrice * itemEntry.count)
      end
      itemCount = itemCount + itemEntry.count
    end

    tooltipFrame:AddLine("  ")

    tooltipFrame:AddDoubleLine(
      AuctionHouseHelper.Locales.Apply("TOTAL_ITEMS_COLORED", itemCount),
      WHITE_FONT_COLOR:WrapTextInColorCode(
        AuctionHouseHelper.Utilities.CreatePaddedMoneyString(total)
      )
    )

    tooltipFrame:Show()
  end)
end

function AuctionHouseHelper.Tooltip.AddVendorTip(tooltipFrame, vendorPrice, countString)
  if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.VENDOR_TOOLTIPS) and vendorPrice > 0 then
    if AuctionHouseHelper.Constants.IsClassic then
      GameTooltip_ClearMoney(tooltipFrame) -- Remove default price
    end

    tooltipFrame:AddDoubleLine(
      L("VENDOR") .. countString,
      WHITE_FONT_COLOR:WrapTextInColorCode(
        AuctionHouseHelper.Utilities.CreatePaddedMoneyString(vendorPrice)
      )
    )
  end
end

function AuctionHouseHelper.Tooltip.AddAuctionTip (tooltipFrame, auctionPrice, countString, cannotAuction)
  if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUCTION_TOOLTIPS) then

    if cannotAuction then
      tooltipFrame:AddDoubleLine(
        L("AUCTION") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          L("CANNOT_AUCTION") .. "  "
        )
      )
    elseif (auctionPrice ~= nil) then
      tooltipFrame:AddDoubleLine(
        L("AUCTION") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          AuctionHouseHelper.Utilities.CreatePaddedMoneyString(auctionPrice)
        )
      )
    else
      tooltipFrame:AddDoubleLine(
        L("AUCTION") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          L("UNKNOWN") .. "  "
        )
      )
    end
  end
end

function AuctionHouseHelper.Tooltip.AddDisenchantTip (
  tooltipFrame, disenchantPrice, countString, disenchantStatus
)
  if not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.ENCHANT_TOOLTIPS) then
    return
  end

  if disenchantPrice ~= nil then
    tooltipFrame:AddDoubleLine(
      L("DISENCHANT") .. countString,
      WHITE_FONT_COLOR:WrapTextInColorCode(
        AuctionHouseHelper.Utilities.CreatePaddedMoneyString(disenchantPrice)
      )
    )
  elseif disenchantStatus.isDisenchantable and
         disenchantStatus.supportedXpac then
    tooltipFrame:AddDoubleLine(
      L("DISENCHANT") .. countString,
      WHITE_FONT_COLOR:WrapTextInColorCode(
        L("UNKNOWN") .. "  "
      )
    )
  end
end

function AuctionHouseHelper.Tooltip.AddProspectTip (
  tooltipFrame, prospectValue, countString
)
  if not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.PROSPECT_TOOLTIPS) then
    return
  end

  if prospectValue ~= nil then
    tooltipFrame:AddDoubleLine(
      L("PROSPECT") .. countString,
      WHITE_FONT_COLOR:WrapTextInColorCode(
        AuctionHouseHelper.Utilities.CreatePaddedMoneyString(prospectValue)
      )
    )
  else
    tooltipFrame:AddDoubleLine(
      L("PROSPECT") .. countString,
      WHITE_FONT_COLOR:WrapTextInColorCode(
        L("UNKNOWN") .. "  "
      )
    )
  end
end

function AuctionHouseHelper.Tooltip.AddMillTip (
  tooltipFrame, millValue, countString
)
  if not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.MILL_TOOLTIPS) then
    return
  end

  if millValue ~= nil then
    tooltipFrame:AddDoubleLine(
      L("MILL") .. countString,
      WHITE_FONT_COLOR:WrapTextInColorCode(
        AuctionHouseHelper.Utilities.CreatePaddedMoneyString(millValue)
      )
    )
  else
    tooltipFrame:AddDoubleLine(
      L("MILL") .. countString,
      WHITE_FONT_COLOR:WrapTextInColorCode(
        L("UNKNOWN") .. "  "
      )
    )
  end
end

local PET_TOOLTIP_SPACING = " "
function AuctionHouseHelper.Tooltip.AddPetTip(
  speciesID
)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelper.Tooltip.AddPetTip", speciesID)
  if not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUCTION_TOOLTIPS) or
     not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.PET_TOOLTIPS) then
    return
  end

  local key = "p:" .. tostring(speciesID)
  local price = AuctionHouseHelper.Database:GetPrice(key)
  BattlePetTooltip:AddLine(" ")
  if price ~= nil then
    BattlePetTooltip:AddLine(
      L("AUCTION") .. PET_TOOLTIP_SPACING ..
      WHITE_FONT_COLOR:WrapTextInColorCode(
        AuctionHouseHelper.Utilities.CreatePaddedMoneyString(price)
      )
    )
  else
    BattlePetTooltip:AddLine(
      L("AUCTION") .. PET_TOOLTIP_SPACING ..
      WHITE_FONT_COLOR:WrapTextInColorCode(
        L("UNKNOWN")
      )
    )
  end
end
