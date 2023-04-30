function AuctionHouseHelper.Utilities.ItemKeyString(itemKey)
    return
      itemKey.itemID .. " " ..
      itemKey.itemSuffix .. " " ..
      itemKey.itemLevel .. " " ..
      itemKey.battlePetSpeciesID
end
