AuctionHouseHelperItemKeyLoadingMixin = {}

function AuctionHouseHelperItemKeyLoadingMixin:OnLoad()
  AuctionHouseHelper.EventBus:Register(self, {AuctionHouseHelper.AH.Events.ItemKeyInfo})

  self:SetOnEntryProcessedCallback(function(entry)
    AuctionHouseHelper.AH.GetItemKeyInfo(entry.itemKey, function(itemKeyInfo, wasCached)
      self:ProcessItemKey(entry, itemKeyInfo)
      if wasCached then
        self:NotifyCacheUsed()
      end
    end)
  end)
end

function AuctionHouseHelperItemKeyLoadingMixin:ProcessItemKey(rowEntry, itemKeyInfo)
  local text = AuctionHouseUtil.GetItemDisplayTextFromItemKey(
    rowEntry.itemKey,
    itemKeyInfo,
    false
  )

  rowEntry.itemName = text
  rowEntry.name = AuctionHouseHelper.Utilities.RemoveTextColor(text):gsub("|A.-Tier(%d).-|a", AUCTION_HOUSE_HELPER_L_TIER .. " %1")
  rowEntry.iconTexture = itemKeyInfo.iconFileID
  rowEntry.noneAvailable = rowEntry.totalQuantity == 0

  self:SetDirty()
end
