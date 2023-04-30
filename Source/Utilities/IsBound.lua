function AuctionHouseHelper.Utilities.IsBound(itemInfo)
  local bindType = itemInfo[AuctionHouseHelper.Constants.ITEM_INFO.BIND_TYPE]

  return bindType == LE_ITEM_BIND_ON_ACQUIRE or bindType == LE_ITEM_BIND_QUEST
end
