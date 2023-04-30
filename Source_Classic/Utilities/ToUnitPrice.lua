function AuctionHouseHelper.Utilities.ToUnitPrice(entry)
  local quantity = entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity]
  if quantity ~= 0 then
    return math.ceil(entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.Buyout] / quantity)
  else
    return 0
  end
end
