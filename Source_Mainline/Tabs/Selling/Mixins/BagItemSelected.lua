AuctionHouseHelperBagItemSelectedMixin = CreateFromMixins(AuctionHouseHelperBagItemMixin)

function AuctionHouseHelperBagItemSelectedMixin:OnClick(button)
  local wasCursorItem = C_Cursor.GetCursorItem()
  if not self:ProcessCursor() then
    if button == "LeftButton" and not wasCursorItem and self.itemInfo ~= nil then
      self:SearchInShoppingTab()
    else
      AuctionHouseHelperBagItemMixin.OnClick(self, button)
    end
  end
end

function AuctionHouseHelperBagItemSelectedMixin:SearchInShoppingTab()
  AuctionHouseHelper.AH.GetItemKeyInfo(self.itemInfo.itemKey, function(itemInfo)
    AuctionHouseHelper.API.v1.MultiSearchExact(AUCTION_HOUSE_HELPER_L_SELLING_TAB, { itemInfo.itemName })
  end)
end

function AuctionHouseHelperBagItemSelectedMixin:OnReceiveDrag()
  self:ProcessCursor()
end

function AuctionHouseHelperBagItemSelectedMixin:ProcessCursor()
  local location = C_Cursor.GetCursorItem()
  ClearCursor()

  if location and C_AuctionHouse.IsSellItemValid(location, true) then
    local itemInfo = AuctionHouseHelper.Utilities.ItemInfoFromLocation(location)
    itemInfo.count = C_AuctionHouse.GetAvailablePostCount(location)

    if not AuctionHouseHelper.EventBus:IsSourceRegistered(self) then
      AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperBagItemSelectedMixin")
    end
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Selling.Events.BagItemClicked, itemInfo)

    return true
  end
  return false
end
