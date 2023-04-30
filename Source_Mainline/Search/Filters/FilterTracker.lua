AuctionHouseHelper.Search.Filters.FilterTrackerMixin = {}

function AuctionHouseHelper.Search.Filters.FilterTrackerMixin:Init(browseResult)
  self.result = true
  self.browseResult = browseResult
  -- Used to avoid giving a final result before all the filters have run
  self.waitingSet = false
  -- Number of filters required to pass (will not pass until self.waitingSet is
  -- true though)
  self.waiting = 0
end

function AuctionHouseHelper.Search.Filters.FilterTrackerMixin:SetWaiting(numNeededFilters)
  if self.waitingSet then
    error("waiting state already set")
  end
  self.waitingSet = true
  self.waiting = self.waiting + numNeededFilters
  self:CompleteCheck()
end

function AuctionHouseHelper.Search.Filters.FilterTrackerMixin:CompleteCheck()
  if self.waitingSet and self.waiting <= 0 then
    AuctionHouseHelper.EventBus:RegisterSource(self, "Search Filter Tracker")
    if self.result then
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Search.Events.SearchResultsReady, {self.browseResult})
    else
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Search.Events.SearchResultsReady, {})
    end
    AuctionHouseHelper.EventBus:UnregisterSource(self)
  end
end


function AuctionHouseHelper.Search.Filters.FilterTrackerMixin:ReportFilterComplete(
  result
)
  self.waiting = self.waiting - 1
  self.result = self.result and result
  self:CompleteCheck()
end
