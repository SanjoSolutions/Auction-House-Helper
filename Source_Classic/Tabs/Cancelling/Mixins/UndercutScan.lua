AuctionHouseHelperUndercutScanMixin = {}

local ABORT_EVENTS = {
  "AUCTION_HOUSE_CLOSED"
}

local QUERY_EVENTS = {
  AuctionHouseHelper.AH.Events.ScanResultsUpdate,
  AuctionHouseHelper.AH.Events.ScanAborted,
}

local THROTTLE_EVENTS = {
  AuctionHouseHelper.AH.Events.Ready,
}

function AuctionHouseHelperUndercutScanMixin:OnLoad()
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperUndercutScanMixin")
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Cancelling.Events.RequestCancel,
    AuctionHouseHelper.Cancelling.Events.RequestCancelUndercut,
  })

  self.seenPrices = {}

  self:SetCancel()
end

function AuctionHouseHelperUndercutScanMixin:AnyUndercutItems()
  local allAuctions = AuctionHouseHelper.AH.DumpAuctions("owner")
  for _, auction in ipairs(allAuctions) do
    local cutoffPrice = self.seenPrices[AuctionHouseHelper.Search.GetCleanItemLink(auction.itemLink)]
    if cutoffPrice ~= nil and
       AuctionHouseHelper.Utilities.ToUnitPrice(auction) > cutoffPrice then
      return true
    end
  end
end

function AuctionHouseHelperUndercutScanMixin:OnShow()
  SetOverrideBinding(self, false, AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CANCEL_UNDERCUT_SHORTCUT), "CLICK AuctionHouseHelperCancelUndercutButton:LeftButton")
  AuctionHouseHelper.EventBus:Register(self, THROTTLE_EVENTS)
end

function AuctionHouseHelperUndercutScanMixin:OnHide()
  ClearOverrideBindings(self)
  AuctionHouseHelper.EventBus:Unregister(self, THROTTLE_EVENTS)

  -- Stop scan when changing away from the Cancelling tab
  AuctionHouseHelper.AH.AbortQuery()
  self:EndScan()
end

function AuctionHouseHelperUndercutScanMixin:StartScan()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperUndercutScanMixin:OnUndercutScanButtonClick()")

  self.seenPrices = {}
  self.allOwnedAuctions = AuctionHouseHelper.AH.DumpAuctions("owner")
  self.scanIndex = 0

  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Cancelling.Events.UndercutScanStart)

  FrameUtil.RegisterFrameForEvents(self, ABORT_EVENTS)

  self.StartScanButton:SetEnabled(false)
  self:SetCancel()

  self:NextStep()
end

function AuctionHouseHelperUndercutScanMixin:SetCancel()
  self.CancelNextButton:SetEnabled(self:AnyUndercutItems() and AuctionHouseHelper.AH.IsNotThrottled())
end

function AuctionHouseHelperUndercutScanMixin:EndScan()
  AuctionHouseHelper.Debug.Message("undercut scan ended")

  FrameUtil.UnregisterFrameForEvents(self, ABORT_EVENTS)
  AuctionHouseHelper.EventBus:Unregister(self, QUERY_EVENTS)

  self.StartScanButton:SetEnabled(true)

  self:SetCancel()
end

function AuctionHouseHelperUndercutScanMixin:NextStep()
  AuctionHouseHelper.Debug.Message("undercut scan: next step")
  self.scanIndex = self.scanIndex + 1

  if self.scanIndex > #self.allOwnedAuctions then
    self:EndScan()
    return
  end

  self.currentAuction = self.allOwnedAuctions[self.scanIndex]
  local info = self.currentAuction.info
  local cleanLink = AuctionHouseHelper.Search.GetCleanItemLink(self.currentAuction.itemLink)

  if (info[AuctionHouseHelper.Constants.AuctionItemInfo.SaleStatus] == 1 or
      info[AuctionHouseHelper.Constants.AuctionItemInfo.BidAmount] ~= 0) then
    AuctionHouseHelper.Debug.Message("undercut scan skip", self.currentAuction.itemLink)

    self:NextStep()
  elseif self.seenPrices[cleanLink] ~= nil then
    --The price has already been seen and reported by an event, so move on.
    self:NextStep()
  else
    AuctionHouseHelper.Debug.Message("undercut scan searching for undercuts", self.currentAuction.itemLink, cleanLink)

    self:SearchForUndercuts(self.currentAuction)
  end
end

function AuctionHouseHelperUndercutScanMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_CLOSED" then
    self:EndScan()
  end
end

function AuctionHouseHelperUndercutScanMixin:ReceiveEvent(eventName, ...)
  if eventName == AuctionHouseHelper.Cancelling.Events.RequestCancel then
    self.CancelNextButton:Disable()

  elseif eventName == AuctionHouseHelper.AH.Events.Ready then
    self:SetCancel()

  elseif eventName == AuctionHouseHelper.Cancelling.Events.RequestCancelUndercut then
    if self.CancelNextButton:IsEnabled() then
      self:CancelNextAuction()
    end

  elseif eventName == AuctionHouseHelper.AH.Events.ScanResultsUpdate then
    local cleanLink = AuctionHouseHelper.Search.GetCleanItemLink(self.currentAuction.itemLink)
    local results, gotAllResults = ...
    for _, r in ipairs(results) do
      local resultCleanLink = AuctionHouseHelper.Search.GetCleanItemLink(r.itemLink)
      local unitPrice = AuctionHouseHelper.Utilities.ToUnitPrice(r)
      if cleanLink == resultCleanLink and unitPrice ~= 0 then
        -- Assumes that scan results are sorted by Blizzard column unitprice
        self.seenPrices[cleanLink] = unitPrice
        break
      end
    end
    if self.seenPrices[cleanLink] ~= nil or gotAllResults then
      AuctionHouseHelper.Debug.Message("undercut scan: next step", self.currentAuction and self.currentAuction.itemLink)
      if not gotAllResults then
        AuctionHouseHelper.AH.AbortQuery()
      else
        AuctionHouseHelper.EventBus:Unregister(self, QUERY_EVENTS)
      end

      self:ProcessUndercutResult(cleanLink, self.seenPrices[cleanLink])
      self:NextStep()
    end

  elseif eventName == AuctionHouseHelper.AH.Events.ScanAborted then
    AuctionHouseHelper.Debug.Message("undercut scan: aborting", self.currentAuction and self.currentAuction.itemLink)
    AuctionHouseHelper.EventBus:Unregister(self, QUERY_EVENTS)
  end
end

function AuctionHouseHelperUndercutScanMixin:SearchForUndercuts(auction)
  local name = AuctionHouseHelper.Utilities.GetNameFromLink(auction.itemLink)
  AuctionHouseHelper.Debug.Message("undercut scan: searching", name)

  AuctionHouseHelper.AH.AbortQuery()

  AuctionHouseHelper.EventBus:Register(self, QUERY_EVENTS)
  AuctionHouseHelper.AH.QueryAuctionItems({
    searchString = name,
    isExact = true,
  })
end

function AuctionHouseHelperUndercutScanMixin:ProcessUndercutResult(cleanLink, cutoffPrice)
  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Cancelling.Events.UndercutStatus, cleanLink, cutoffPrice)
end

function AuctionHouseHelperUndercutScanMixin:CancelNextAuction()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperUndercutScanMixin:CancelNextAuction()")

  local allAuctions = AuctionHouseHelper.AH.DumpAuctions("owner")
  for _, auction in ipairs(allAuctions) do
    local cutoffPrice = self.seenPrices[AuctionHouseHelper.Search.GetCleanItemLink(auction.itemLink)]
    if cutoffPrice ~= nil and
       AuctionHouseHelper.Utilities.ToUnitPrice(auction) > cutoffPrice then
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Cancelling.Events.RequestCancel, {
        itemLink = auction.itemLink,
        unitPrice = AuctionHouseHelper.Utilities.ToUnitPrice(auction),
        stackPrice = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Buyout],
        stackSize = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity],
        isSold = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.SaleStatus] == 1,
        numStacks = 1,
        isOwned = true,
        bidAmount = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.BidAmount],
        minBid = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.MinBid],
        bidder = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Bidder],
        timeLeft = auction.timeLeft,
      })
      return
    end
  end
end
