function AuctionHouseHelper.Utilities.IsVendorable(itemInfo)
  local sellPrice = itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.SELL_PRICE]
  local isReagent = itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.REAGENT]
  local isArtifact = itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.RARITY] == Enum.ItemQuality.Artifact
  local isLegendary = itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.RARITY] == Enum.ItemQuality.Legendary

  return sellPrice ~= nil and sellPrice > 0 and not isArtifact and (isReagent or not isLegendary)
end
