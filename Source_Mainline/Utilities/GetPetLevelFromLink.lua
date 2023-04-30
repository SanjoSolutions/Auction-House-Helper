function AuctionHouseHelper.Utilities.GetPetLevelFromLink(itemLink)
  local _, _, level = strsplit(":", itemLink)

  return tonumber(level)
end
