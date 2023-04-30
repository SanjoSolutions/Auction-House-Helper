AuctionHouseHelper.Search.Filters.TierMixin = {}

function AuctionHouseHelper.Search.Filters.TierMixin:Init(filterTracker, browseResult, tier)
  self.tier = tier

  filterTracker:ReportFilterComplete(self:FilterCheck(browseResult.itemKey))
end

function AuctionHouseHelper.Search.Filters.TierMixin:FilterCheck(itemKey)
  return self:TierCheck(itemKey)
end

function AuctionHouseHelper.Search.Filters.TierMixin:TierCheck(itemKey)
  return C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemKey.itemID) == self.tier
end
