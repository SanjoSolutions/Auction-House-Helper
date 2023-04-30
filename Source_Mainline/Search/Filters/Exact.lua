-- Exact search terms
AuctionHouseHelper.Search.Filters.ExactMixin = {}

function AuctionHouseHelper.Search.Filters.ExactMixin:Init(filterTracker, browseResult, match)
  self.match = match
  
  AuctionHouseHelper.AH.GetItemKeyInfo(browseResult.itemKey, function(itemKeyInfo)
    filterTracker:ReportFilterComplete(self:ExactMatchCheck(itemKeyInfo))
  end)
end

function AuctionHouseHelper.Search.Filters.ExactMixin:ExactMatchCheck(itemKeyInfo)
  return string.lower(itemKeyInfo.itemName) == string.lower(self.match)
end
