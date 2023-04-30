function AuctionHouseHelper.AH.SendSearchQueryByGenerator(itemKeyGenerator, sorts, splitOwnedItems)
  function rawSearch(itemKey)
    C_AuctionHouse.SendSearchQuery(itemKey, sorts, splitOwnedItems)
  end

  AuctionHouseHelper.AH.Internals.searchScan:SetSearch(itemKeyGenerator, rawSearch)
end

function AuctionHouseHelper.AH.SendSearchQueryByItemKey(itemKey, sorts, splitOwnedItems)
  function itemKeyGenerator()
    return itemKey
  end
  function rawSearch(itemKey)
    C_AuctionHouse.SendSearchQuery(itemKey, sorts, splitOwnedItems)
  end

  AuctionHouseHelper.AH.Internals.searchScan:SetSearch(itemKeyGenerator, rawSearch)
end

function AuctionHouseHelper.AH.SendSellSearchQueryByGenerator(itemKeyGenerator, sorts, splitOwnedItems)
  function rawSearch(itemKey)
    C_AuctionHouse.SendSellSearchQuery(itemKey, sorts, splitOwnedItems)
  end

  AuctionHouseHelper.AH.Internals.searchScan:SetSearch(itemKeyGenerator, rawSearch)
end

function AuctionHouseHelper.AH.SendSellSearchQueryByItemKey(itemKey, sorts, splitOwnedItems)
  function itemKeyGenerator()
    return itemKey
  end
  function rawSearch(itemKey)
    C_AuctionHouse.SendSellSearchQuery(itemKey, sorts, splitOwnedItems)
  end

  AuctionHouseHelper.AH.Internals.searchScan:SetSearch(itemKeyGenerator, rawSearch)
end

function AuctionHouseHelper.AH.QueryOwnedAuctions(...)
  local args = {...}
  AuctionHouseHelper.AH.Queue:Enqueue(function()
    C_AuctionHouse.QueryOwnedAuctions(unpack(args))
  end)
end

local sentBrowseQuery = true
function AuctionHouseHelper.AH.SendBrowseQuery(...)
  local args = {...}
  sentBrowseQuery = false
  AuctionHouseHelper.AH.Queue:Enqueue(function()
    sentBrowseQuery = true
    C_AuctionHouse.SendBrowseQuery(unpack(args))
  end)
end

function AuctionHouseHelper.AH.HasFullBrowseResults()
  return sentBrowseQuery and C_AuctionHouse.HasFullBrowseResults()
end

function AuctionHouseHelper.AH.RequestMoreBrowseResults(...)
  local args = {...}
  AuctionHouseHelper.AH.Queue:Enqueue(function()
    C_AuctionHouse.RequestMoreBrowseResults(unpack(args))
  end)
end

-- Event ThrottleUpdate will fire whenever the state changes
function AuctionHouseHelper.AH.IsNotThrottled()
  return AuctionHouseHelper.AH.Internals.throttling:IsReady()
end

function AuctionHouseHelper.AH.CancelAuction(...)
  -- Can't be queued, "protected" call
  C_AuctionHouse.CancelAuction(...)
end

function AuctionHouseHelper.AH.ReplicateItems()
  C_AuctionHouse.ReplicateItems()
end

function AuctionHouseHelper.AH.GetItemKeyInfo(itemKey, callback)
  AuctionHouseHelper.AH.Internals.itemKeyLoader:Get(itemKey, callback)
end

function AuctionHouseHelper.AH.GetAuctionItemSubClasses(classID)
  return C_AuctionHouse.GetAuctionItemSubClasses(classID)
end
