AuctionHouseHelper.Shopping.Recents = {}

function AuctionHouseHelper.Shopping.Recents.Save(searchText)
  local prevIndex = tIndexOf(AUCTION_HOUSE_HELPER_RECENT_SEARCHES, searchText)
  if prevIndex ~= nil then
    table.remove(AUCTION_HOUSE_HELPER_RECENT_SEARCHES, prevIndex)
  end

  table.insert(AUCTION_HOUSE_HELPER_RECENT_SEARCHES, 1, searchText)

  while #AUCTION_HOUSE_HELPER_RECENT_SEARCHES > AuctionHouseHelper.Constants.RecentsListLimit do
    table.remove(AUCTION_HOUSE_HELPER_RECENT_SEARCHES)
  end

  AuctionHouseHelper.EventBus
    :RegisterSource(AuctionHouseHelper.Shopping.Recents.Save, "save recents entry")
    :Fire(AuctionHouseHelper.Shopping.Recents.Save, AuctionHouseHelper.Shopping.Events.RecentSearchesUpdate)
    :UnregisterSource(AuctionHouseHelper.Shopping.Recents.Save)
end

function AuctionHouseHelper.Shopping.Recents.DeleteEntry(searchTerm)
  local index = tIndexOf(AUCTION_HOUSE_HELPER_RECENT_SEARCHES, searchTerm)

  if index ~= nil then
    table.remove(AUCTION_HOUSE_HELPER_RECENT_SEARCHES, index)
    AuctionHouseHelper.EventBus
      :RegisterSource(AuctionHouseHelper.Shopping.Recents.DeleteEntry, "delete recents entry")
      :Fire(AuctionHouseHelper.Shopping.Recents.DeleteEntry, AuctionHouseHelper.Shopping.Events.RecentSearchesUpdate)
      :UnregisterSource(AuctionHouseHelper.Shopping.Recents.DeleteEntry)
  end
end

function AuctionHouseHelper.Shopping.Recents.GetAll()
  return AUCTION_HOUSE_HELPER_RECENT_SEARCHES
end
