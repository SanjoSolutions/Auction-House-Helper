function AuctionHouseHelper.API.v1.GetAuctionPriceByItemID(callerID, itemID)
  AuctionHouseHelper.API.InternalVerifyID(callerID)

  if type(itemID) ~= "number" then
    AuctionHouseHelper.API.ComposeError(
      callerID,
      "Usage AuctionHouseHelper.API.v1.GetAuctionPriceByItemID(string, number)"
    )
  end

  if AuctionHouseHelper.Database == nil then
    return nil
  end

  return AuctionHouseHelper.Database:GetPrice(tostring(itemID))
end

function AuctionHouseHelper.API.v1.GetAuctionPriceByItemLink(callerID, itemLink)
  AuctionHouseHelper.API.InternalVerifyID(callerID)

  if type(itemLink) ~= "string" then
    AuctionHouseHelper.API.ComposeError(
      callerID,
      "Usage AuctionHouseHelper.API.v1.GetAuctionPriceByItemLink(string, string)"
    )
  end

  if AuctionHouseHelper.Database == nil then
    return nil
  end

  local dbKeys = nil
  -- Use that the callback is called immediately (and populates dbKeys) if the
  -- item info for item levels is available now.
  AuctionHouseHelper.Utilities.DBKeyFromLink(itemLink, function(dbKeysCallback)
    dbKeys = dbKeysCallback
  end)

  if dbKeys then
    return AuctionHouseHelper.Database:GetFirstPrice(dbKeys)
  else
    return AuctionHouseHelper.Database:GetPrice(
      AuctionHouseHelper.Utilities.BasicDBKeyFromLink(itemLink)
    )
  end
end
