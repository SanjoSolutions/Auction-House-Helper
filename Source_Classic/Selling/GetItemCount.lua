local function GetNumSlots(bag)
  if C_Container and C_Container.GetContainerNumSlots then
    return C_Container.GetContainerNumSlots(bag)
  else
    return GetContainerNumSlots(bag)
  end
end

function AuctionHouseHelper.Selling.GetItemCount(itemLocation)
  local locationKey = AuctionHouseHelper.Selling.UniqueBagKey(AuctionHouseHelper.Utilities.ItemInfoFromLocation(itemLocation))

  local count = 0
  for _, bagId in ipairs(AuctionHouseHelper.Constants.BagIDs) do
    for slot = 1, GetNumSlots(bagId) do
      local location = ItemLocation:CreateFromBagAndSlot(bagId, slot)
      if C_Item.DoesItemExist(location) then
        local itemInfo = AuctionHouseHelper.Utilities.ItemInfoFromLocation(location)
        local tempId = AuctionHouseHelper.Selling.UniqueBagKey(itemInfo)
        if tempId == locationKey then
          count = count + itemInfo.count
        end
      end
    end
  end
  return count
end
