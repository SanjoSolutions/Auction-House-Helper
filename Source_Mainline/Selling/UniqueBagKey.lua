function AuctionHouseHelper.Selling.UniqueBagKey(entry)
  local result = AuctionHouseHelper.Utilities.ItemKeyString(entry.itemKey) .. " " .. entry.quality

  if entry.itemKey.battlePetSpeciesID ~= 0 then
    result = result .. " " .. tostring(AuctionHouseHelper.Utilities.GetPetLevelFromLink(entry.itemLink))
  end

  if not entry.auctionable then
    result = result .. " x"
  end

  return result
end
