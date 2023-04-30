local function isDisenchantable(itemInfo)
  return
    #itemInfo == 0 or (
      (
        itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.CLASS] == Enum.ItemClass.Weapon or
        itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.CLASS] == Enum.ItemClass.Armor
      ) and
      itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.RARITY] >= Enum.ItemQuality.Uncommon and
      itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.RARITY] <= Enum.ItemQuality.Epic
    )
end

function AuctionHouseHelper.Enchant.DisenchantStatus(itemInfo)
  return {
    isDisenchantable = isDisenchantable(itemInfo),
    supportedXpac =
      itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.XPAC] >=
        LE_EXPANSION_WARLORDS_OF_DRAENOR
  }
end

local function GetDisenchantReagents(itemInfo)
  local xpac = AuctionHouseHelper.Enchant.DE_TABLE[
    itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.XPAC]
  ]
  if xpac then
    return xpac[itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.RARITY]]
  else
    return nil
  end
end

function AuctionHouseHelper.Enchant.GetDisenchantAuctionPrice(itemLink, itemInfo)
  if not isDisenchantable(itemInfo) then
    return nil
  end

  local disenchantInfo = GetDisenchantReagents(itemInfo)

  if disenchantInfo == nil then
    return nil
  end

  local price = 0

  for reagentKey, allDrops in pairs(disenchantInfo) do
    local reagentPrice = AuctionHouseHelper.Database:GetPrice(reagentKey)

    if reagentPrice == nil then
      return nil
    end

    for index, drop in ipairs(allDrops) do
      price = price + reagentPrice * index * drop
    end
  end

  return price
end
