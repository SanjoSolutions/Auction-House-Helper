function AuctionHouseHelper.API.v1.GetVendorPriceByItemID(callerID, itemID)
  AuctionHouseHelper.API.InternalVerifyID(callerID)

  if type(itemID) ~= "number" then
    AuctionHouseHelper.API.ComposeError(
      callerID,
      "Usage AuctionHouseHelper.API.v1.GetVendorPriceByItemID(string, number)"
    )
  end

  return AUCTION_HOUSE_HELPER_VENDOR_PRICE_CACHE[tostring(itemID)]
end

function AuctionHouseHelper.API.v1.GetVendorPriceByItemLink(callerID, itemLink)
  AuctionHouseHelper.API.InternalVerifyID(callerID)

  if type(itemLink) ~= "string" then
    AuctionHouseHelper.API.ComposeError(
      callerID,
      "Usage AuctionHouseHelper.API.v1.GetVendorPriceByItemLink(string, string)"
    )
  end

  local dbKeys = nil
  -- Use that the callback is called immediately (and populates dbKeys) if the
  -- item info for item levels is available now.
  AuctionHouseHelper.Utilities.DBKeyFromLink(itemLink, function(dbKeysCallback)
    dbKeys = dbKeysCallback
  end)

  if dbKeys then
    for _, key in ipairs(dbKeys) do
      if AUCTION_HOUSE_HELPER_VENDOR_PRICE_CACHE[key] then
        return AUCTION_HOUSE_HELPER_VENDOR_PRICE_CACHE[key]
      end
    end
  else
    return AUCTION_HOUSE_HELPER_VENDOR_PRICE_CACHE[AuctionHouseHelper.Utilities.BasicDBKeyFromLink(itemLink)]
  end
end
