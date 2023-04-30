AuctionHouseHelperIncrementalScanFrameMixin = {}

local INCREMENTAL_SCAN_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_CLOSED"
}

function AuctionHouseHelperIncrementalScanFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperIncrementalScanFrameMixin:OnLoad")
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperIncrementalScanFrameMixin")

  self.doingFullScan = false
  self.state = AuctionHouseHelper.SavedState

  self:RegisterForEvents()
end

function AuctionHouseHelperIncrementalScanFrameMixin:RegisterForEvents()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperIncrementalScanFrameMixin:RegisterForEvents()")

  FrameUtil.RegisterFrameForEvents(self, INCREMENTAL_SCAN_EVENTS)
end

function AuctionHouseHelperIncrementalScanFrameMixin:UnregisterForEvents()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperIncrementalScanFrameMixin:UnregisterForEvents()")

  FrameUtil.UnregisterFrameForEvents(self, INCREMENTAL_SCAN_EVENTS)
end

function AuctionHouseHelperIncrementalScanFrameMixin:OnEvent(event, ...)
  if event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self.info = {} -- New search results so reset info
    self.rawScan = {}

    local browseResults = C_AuctionHouse.GetBrowseResults()
    -- Check this is probably the start of a new batch, as the UPDATED event
    -- will fire when doing other specific items searches (to update the price
    -- and quantity) on any size search results.
    if #browseResults <= AuctionHouseHelper.Constants.SummaryBatchSize then
      self:AddPrices(browseResults)
      self:NextStep()
    end
  elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:AddPrices(...)
    self:NextStep()

  elseif event == "AUCTION_HOUSE_CLOSED" and self.doingFullScan then
    self.doingFullScan = false
    AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_FULL_SCAN_FAILED_SUMMARY)
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.IncrementalScan.Events.ScanFailed)
  end
end

function AuctionHouseHelperIncrementalScanFrameMixin:IsAutoscanReady()
  local timeSinceLastScan = time() - (self.state.TimeOfLastBrowseScan or 0)

  return timeSinceLastScan >= (AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUTOSCAN_INTERVAL) * 60)
end

function AuctionHouseHelperIncrementalScanFrameMixin:InitiateScan()
  if not self.doingFullScan then
    AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_STARTING_FULL_SCAN_SUMMARY)
    AuctionHouseHelper.AH.SendBrowseQuery({searchString = "", sorts = {}, filters = {}, itemClassFilters = {}})
    self.previousDatabaseCount = AuctionHouseHelper.Database:GetItemCount()
    self.doingFullScan = true

    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.IncrementalScan.Events.ScanStart)
    self:FireProgressEvent()
  else
    AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_FULL_SCAN_IN_PROGRESS)
  end
end

function AuctionHouseHelperIncrementalScanFrameMixin:FireProgressEvent()
  local infoCount = 0

  if self.info ~= nil then
    for _, _  in pairs(self.info) do
      infoCount = infoCount + 1
    end
  end

  local dbCount = AuctionHouseHelper.Database:GetItemCount()

  -- 10% complete after making the browse request
  local progress = 0.1

  if dbCount == 0 then
    -- 50% done if we don't have anything in the database
    progress = 0.5
  elseif dbCount > infoCount then
    -- 10%-90% complete when processing browse results
    progress = progress + 0.8 * infoCount / dbCount
  else
    -- 90% if got more browse results than prices already in the database
    progress = 0.9
  end

  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.IncrementalScan.Events.ScanProgress, progress)
end

function AuctionHouseHelperIncrementalScanFrameMixin:AddPrices(results)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperIncrementalScanFrameMixin:AddPrices()", results)

  for _, resultInfo in ipairs(results) do
    if resultInfo.totalQuantity ~= 0 then
      local allDBKeys = AuctionHouseHelper.Utilities.DBKeyFromBrowseResult(resultInfo)

      for index, dbKey in ipairs(allDBKeys) do
        if self.info[dbKey] == nil then
          self.info[dbKey] = {}
        end

        table.insert(self.info[dbKey],
          { price = resultInfo.minPrice, available = resultInfo.totalQuantity }
        )
      end
      if self.doingFullScan then
        table.insert(self.rawScan, resultInfo)
      end
    end
  end

  if self.doingFullScan then
    self:FireProgressEvent()
  end
end

function AuctionHouseHelperIncrementalScanFrameMixin:NextStep()
  if self.doingFullScan and not AuctionHouseHelper.AH.HasFullBrowseResults() then
    AuctionHouseHelper.AH.RequestMoreBrowseResults()
  else
    local count = AuctionHouseHelper.Database:ProcessScan(self.info)
    local rawScan = self.rawScan

    self.info = {} --Already processed, so clear
    self.rawScan = {}

    if self.doingFullScan then
      AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_FINISHED_PROCESSING:format(count))
      self.doingFullScan = false

      self.state.TimeOfLastBrowseScan = time()
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.IncrementalScan.Events.ScanComplete, rawScan)
    end
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.IncrementalScan.Events.PricesProcessed)
  end
end
