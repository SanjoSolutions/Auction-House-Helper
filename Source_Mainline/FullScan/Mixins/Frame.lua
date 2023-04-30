AuctionHouseHelperFullScanFrameMixin = {}

local FULL_SCAN_EVENTS = {
  "REPLICATE_ITEM_LIST_UPDATE",
  "AUCTION_HOUSE_CLOSED"
}

function AuctionHouseHelperFullScanFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperFullScanFrameMixin:OnLoad")
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperFullScanFrameMixin")
  self.state = AuctionHouseHelper.SavedState
end

function AuctionHouseHelperFullScanFrameMixin:ResetData()
  self.scanData = {}
  self.dbKeysMapping = {}
end

function AuctionHouseHelperFullScanFrameMixin:InitiateScan()
  if self:CanInitiate() then
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.FullScan.Events.ScanStart)

    self.state.TimeOfLastReplicateScan = time()

    self.inProgress = true

    self:RegisterForEvents()
    AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_STARTING_FULL_SCAN_REPLICATE)
    C_AuctionHouse.ReplicateItems()
    -- 10% complete after making the replicate request
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.FullScan.Events.ScanProgress, 0.1)
  else
    AuctionHouseHelper.Utilities.Message(self:NextScanMessage())
  end
end

function AuctionHouseHelperFullScanFrameMixin:IsAutoscanReady()
  local timeSinceLastScan = time() - (self.state.TimeOfLastReplicateScan or 0)

  return timeSinceLastScan >= (AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUTOSCAN_INTERVAL) * 60) and self:CanInitiate()
end

function AuctionHouseHelperFullScanFrameMixin:CanInitiate()
  return
   ( self.state.TimeOfLastReplicateScan ~= nil and
     time() - self.state.TimeOfLastReplicateScan > 60 * 15 and
     not self.inProgress
   ) or self.state.TimeOfLastReplicateScan == nil
end

function AuctionHouseHelperFullScanFrameMixin:NextScanMessage()
  local timeSinceLastScan = time() - self.state.TimeOfLastReplicateScan
  local minutesUntilNextScan = 15 - math.ceil(timeSinceLastScan / 60)
  local secondsUntilNextScan = (15 * 60 - timeSinceLastScan) % 60

  return AUCTION_HOUSE_HELPER_L_NEXT_SCAN_MESSAGE:format(minutesUntilNextScan, secondsUntilNextScan)
end

function AuctionHouseHelperFullScanFrameMixin:RegisterForEvents()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperFullScanFrameMixin:RegisterForEvents()")

  FrameUtil.RegisterFrameForEvents(self, FULL_SCAN_EVENTS)
end

function AuctionHouseHelperFullScanFrameMixin:UnregisterForEvents()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperFullScanFrameMixin:UnregisterForEvents()")

  FrameUtil.UnregisterFrameForEvents(self, FULL_SCAN_EVENTS)
end

function AuctionHouseHelperFullScanFrameMixin:CacheScanData()
  -- 20% complete after server response
  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.FullScan.Events.ScanProgress, 0.2)

  self:ResetData()
  self.waitingForData = C_AuctionHouse.GetNumReplicateItems()

  self:ProcessBatch(
    0,
    250,
    self.waitingForData
  )
end

function AuctionHouseHelperFullScanFrameMixin:ProcessBatch(startIndex, stepSize, limit)
  if startIndex >= limit then
    C_Timer.After(2, function()
      if self.waitingForData > 0 then
        self.waitingForData = 0
        self:EndProcessing()
      end
    end)
    return
  end

  -- 20-100% complete when 0-100% through caching the scan
  AuctionHouseHelper.EventBus:Fire(self,
    AuctionHouseHelper.FullScan.Events.ScanProgress,
    0.2 + startIndex/limit*0.8
  )

  AuctionHouseHelper.Debug.Message("AuctionHouseHelperFullScanFrameMixin:ProcessBatch (links)", startIndex, stepSize, limit)

  local i = startIndex
  while i < startIndex+stepSize and i < limit do
    local info = { C_AuctionHouse.GetReplicateItemInfo(i) }
    local link = C_AuctionHouse.GetReplicateItemLink(i)
    local timeLeft = C_AuctionHouse.GetReplicateItemTimeLeft(i)
    local index = i

    -- Glitch in Blizzard APIs sometimes items with no item data are returned
    -- Workaround is to ignore them and filter out the nils after the scan is
    -- finished.
    if not C_Item.DoesItemExistByID(info[17]) then
      self.waitingForData = self.waitingForData - 1
      if self.waitingForData == 0 then
        self:EndProcessing()
      end
    elseif not info[18] then
      ItemEventListener:AddCallback(info[17], function()
        local link = C_AuctionHouse.GetReplicateItemLink(index)

        AuctionHouseHelper.Utilities.DBKeyFromLink(link, function(dbKeys)
          self.waitingForData = self.waitingForData - 1

          self.scanData[index + 1] = {
            replicateInfo = { C_AuctionHouse.GetReplicateItemInfo(index) },
            itemLink      = link,
            timeLeft      = C_AuctionHouse.GetReplicateItemTimeLeft(index),
          }
          self.dbKeysMapping[index + 1] = dbKeys

          if self.waitingForData == 0 then
            self:EndProcessing()
          end
        end)
      end)
    else
      AuctionHouseHelper.Utilities.DBKeyFromLink(link, function(dbKeys)
        self.waitingForData = self.waitingForData - 1
        self.scanData[index + 1] = {
          replicateInfo = info,
          itemLink      = link,
          timeLeft      = timeLeft,
        }
        self.dbKeysMapping[index + 1] = dbKeys

        if self.waitingForData == 0 then
          self:EndProcessing()
        end
      end)
    end

    i = i + 1
  end

  C_Timer.After(0.01, function()
    self:ProcessBatch(startIndex + stepSize, stepSize, limit)
  end)
end

function AuctionHouseHelperFullScanFrameMixin:OnEvent(event, ...)
  if event == "REPLICATE_ITEM_LIST_UPDATE" then
    AuctionHouseHelper.Debug.Message("REPLICATE_ITEM_LIST_UPDATE")

    FrameUtil.UnregisterFrameForEvents(self, { "REPLICATE_ITEM_LIST_UPDATE" })
    self:CacheScanData()
  elseif event =="AUCTION_HOUSE_CLOSED" then
    self:UnregisterForEvents()

    if self.inProgress then
      self.inProgress = false
      self:ResetData()

      AuctionHouseHelper.Utilities.Message(
        AUCTION_HOUSE_HELPER_L_FULL_SCAN_FAILED_REPLICATE .. " " .. self:NextScanMessage()
      )
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.FullScan.Events.ScanFailed)
    end
  end
end

local function GetInfo(replicateInfo, itemLink)
  local count = replicateInfo[3]
  local buyoutPrice = replicateInfo[10]
  local effectivePrice = buyoutPrice / count
  local available = replicateInfo[3]
    
  return effectivePrice, available
end


local function MergeInfo(scanData, dbKeysMapping)
  local allInfo = {}
  local index = 0

  for index = 1, #scanData do
    local effectivePrice, available = GetInfo(scanData[index].replicateInfo)

    -- Checks as apparently it returns 0 available in some cases
    if available > 0 and effectivePrice ~= 0 then
      for _, dbKey in ipairs(dbKeysMapping[index]) do
        if allInfo[dbKey] == nil then
          allInfo[dbKey] = {}
        end

        table.insert(allInfo[dbKey],
          { price = effectivePrice, available = available }
        )
      end
    end
  end

  return allInfo
end

function AuctionHouseHelperFullScanFrameMixin:EndProcessing()
  local fixedScanData = {}
  local fixedDbKeysMapping = {}

  -- Removes the nil holes for items that have item data missing
  for i = 1, #self.scanData do
    if self.scanData[i] ~= nil then
      table.insert(fixedScanData, self.scanData[i])
      table.insert(fixedDbKeysMapping, self.dbKeysMapping[i])
    end
  end

  local count = AuctionHouseHelper.Database:ProcessScan(MergeInfo(fixedScanData, fixedDbKeysMapping))
  AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_FINISHED_PROCESSING:format(count))

  self.inProgress = false
  self:ResetData()

  self:UnregisterForEvents()

  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.FullScan.Events.ScanComplete, fixedScanData)
end
