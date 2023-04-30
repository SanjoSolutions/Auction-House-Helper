AuctionHouseHelper.Search.Filters.PriceMixin = {}

function AuctionHouseHelper.Search.Filters.PriceMixin:Init(filterTracker, browseResult, limits)
  self.limits = limits
  filterTracker:ReportFilterComplete(self:PriceCheck(browseResult.minPrice))
end

function AuctionHouseHelper.Search.Filters.PriceMixin:PriceCheck(price)
  return
    (
      --Minimum price check
      self.limits.min == nil or
      self.limits.min <= price
    ) and (
      --Maximum price check
      self.limits.max == nil or
      self.limits.max >= price
    )
end
