function AuctionHouseHelper.Selling.UniqueBagKey(entry)
  local result = AuctionHouseHelper.Search.GetCleanItemLink(entry.itemLink)

  if not entry.auctionable then
    result = result .. " x"
  end

  return result
end
