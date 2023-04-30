AuctionHouseHelperAHScanFrameMixin = {}

local SCAN_EVENTS = {
  "AUCTION_ITEM_LIST_UPDATE",
}

local function ParamsForBlizzardAPI(query, page)
  return query.searchString, query.minLevel, query.maxLevel, page, nil, query.quality, false, query.isExact or false, query.itemClassFilters
end

function AuctionHouseHelperAHScanFrameMixin:OnLoad()
  self.scanRunning = false
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperAHScanFrameMixin")
end

function AuctionHouseHelperAHScanFrameMixin:IsOnLastPage()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperAHScanFrameMixin:IsOnLastPage()")

  --Loaded all the terms from API
  return (
    (self.endPage ~= -1 and self.nextPage > self.endPage) or
    GetNumAuctionItems("list") < AuctionHouseHelper.Constants.MaxResultsPerPage
  )
end

function AuctionHouseHelperAHScanFrameMixin:GotAllOwners()
  local result = true
  local allAuctions = AuctionHouseHelper.AH.DumpAuctions("list")
  for _, auction in ipairs(allAuctions) do
    result = result and auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Owner] ~= nil
  end

  return result
end

function AuctionHouseHelperAHScanFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_ITEM_LIST_UPDATE" and self.waitingOnPage and self.sentQuery and self:GotAllOwners() then
    self.waitingOnPage = false
    self:ProcessSearchResults()
  end
end

function AuctionHouseHelperAHScanFrameMixin:StartQuery(query, startPage, endPage)
  if self.scanRunning then
    error("Scan already running")
  end
  self:RegisterEvents()

  self.scanRunning = true

  self.nextPage = startPage
  self.endPage = endPage
  self.query = query
  self:DoNextSearchQuery()
end

function AuctionHouseHelperAHScanFrameMixin:AbortQuery()
  if self.scanRunning then
    AuctionHouseHelper.AH.Queue:Remove(self.lastQueuedItem)
    self.scanRunning = false
    self:UnregisterEvents()
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.ScanAborted)
  end
end

function AuctionHouseHelperAHScanFrameMixin:DoNextSearchQuery()
  local page = self.nextPage
  self.sentQuery = false

  self.lastQueuedItem = function()
    self.sentQuery = true
    SortAuctionSetSort("list", "unitprice")
    QueryAuctionItems(ParamsForBlizzardAPI(self.query, page))
  end
  AuctionHouseHelper.AH.Queue:Enqueue(self.lastQueuedItem)

  self.waitingOnPage = true
  self.nextPage = self.nextPage + 1

  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.ScanPageStart, page)
end

function AuctionHouseHelperAHScanFrameMixin:ProcessSearchResults()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperAHScanFrameMixin:ProcessSearchResults()")

  local results = self:GetCurrentPage()

  if self:IsOnLastPage() then
    self.scanRunning = false
    self:UnregisterEvents()
  else
    self:DoNextSearchQuery()
  end
  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.ScanResultsUpdate, results, not self.scanRunning)
end

function AuctionHouseHelperAHScanFrameMixin:GetCurrentPage()
  local results = AuctionHouseHelper.AH.DumpAuctions("list")
  for _, entry in ipairs(results) do
    entry.query = self.query
    entry.page = self.nextPage - 1
  end

  return results
end

function AuctionHouseHelperAHScanFrameMixin:RegisterEvents()
  FrameUtil.RegisterFrameForEvents(self, SCAN_EVENTS)
end

function AuctionHouseHelperAHScanFrameMixin:UnregisterEvents()
  FrameUtil.UnregisterFrameForEvents(self, SCAN_EVENTS)
end
