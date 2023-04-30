function AuctionHouseHelper.Selling.DoesItemMatch(originalItemKey, originalItemLink, targetItemKey, targetItemLink)
  local matchType = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_ITEM_MATCHING)

  if matchType == AuctionHouseHelper.Config.ItemMatching.ITEM_NAME_AND_LEVEL then
    local sameKey = AuctionHouseHelper.Utilities.ItemKeyString(originalItemKey) == AuctionHouseHelper.Utilities.ItemKeyString(targetItemKey)
    if originalItemKey.battlePetSpeciesID ~= 0 then
      return sameKey and AuctionHouseHelper.Utilities.GetPetLevelFromLink(originalItemLink) == AuctionHouseHelper.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return sameKey
    end
  elseif matchType == AuctionHouseHelper.Config.ItemMatching.ITEM_ID then
    return originalItemKey.itemID == targetItemKey.itemID
  elseif matchType == AuctionHouseHelper.Config.ItemMatching.ITEM_NAME_ONLY then
    return originalItemKey.itemID == targetItemKey.itemID and originalItemKey.itemSuffix == targetItemKey.itemSuffix
  elseif matchType == AuctionHouseHelper.Config.ItemMatching.ITEM_ID_AND_LEVEL then
    if originalItemKey.battlePetSpeciesID ~= 0 then
      return AuctionHouseHelper.Utilities.GetPetLevelFromLink(originalItemLink) == AuctionHouseHelper.Utilities.GetPetLevelFromLink(targetItemLink)
    else
      return originalItemKey.itemID == targetItemKey.itemID and originalItemKey.itemLevel == targetItemKey.itemLevel
    end
  end
  return true
end
