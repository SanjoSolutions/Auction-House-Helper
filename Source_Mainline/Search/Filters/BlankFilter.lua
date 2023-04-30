AuctionHouseHelper.Search.Filters.BlankFilterMixin = {}

function AuctionHouseHelper.Search.Filters.BlankFilterMixin:Init(filterTracker, browseResult)
  filterTracker:ReportFilterComplete(true)
end
