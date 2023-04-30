function AuctionHouseHelper.CraftingInfo.CacheVendorPrices()
  for i = 1, GetMerchantNumItems() do
    local itemID = GetMerchantItemID(i)
    if itemID ~= nil then
      local item = Item:CreateFromItemID(itemID)
      if not item:IsItemEmpty() then
        item:ContinueOnItemLoad(function()
          local price, stack, numAvailable = select(3, GetMerchantItemInfo(i))
          local itemLink = GetMerchantItemLink(i)
          local dbKey = AuctionHouseHelper.Utilities.BasicDBKeyFromLink(itemLink)
          if dbKey ~= nil and price ~= 0 and numAvailable == -1 then
            local oldPrice = AUCTION_HOUSE_HELPER_VENDOR_PRICE_CACHE[dbKey]
            local newPrice = price / stack
            AUCTION_HOUSE_HELPER_VENDOR_PRICE_CACHE[dbKey] = newPrice
          elseif dbKey ~= nil then
            AUCTION_HOUSE_HELPER_VENDOR_PRICE_CACHE[dbKey] = nil
          end
        end)
      end
    end
  end
end
