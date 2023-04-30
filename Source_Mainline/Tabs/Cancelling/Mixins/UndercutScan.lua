AuctionHouseHelperUndercutScanMixin = {}

local UNDERCUT_START_STOP_EVENTS = {
  "OWNED_AUCTIONS_UPDATED",
  "AUCTION_HOUSE_CLOSED"
}

local AH_SCAN_EVENTS = {
  AuctionHouseHelper.AH.Events.CommoditySearchResultsReady,
  AuctionHouseHelper.AH.Events.ItemSearchResultsReady,
}

local CANCELLING_EVENTS = {
  "AUCTION_CANCELED"
}

function AuctionHouseHelperUndercutScanMixin:OnLoad()
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperUndercutScanMixin")
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Cancelling.Events.RequestCancel,
    AuctionHouseHelper.Cancelling.Events.RequestCancelUndercut,
  })

  self.undercutAuctions = {}
  self.seenAuctionResults = {}

  self:SetCancel()
end

function AuctionHouseHelperUndercutScanMixin:OnShow()
  SetOverrideBinding(self, false, AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CANCEL_UNDERCUT_SHORTCUT), "CLICK AuctionHouseHelperCancelUndercutButton:LeftButton")
end

function AuctionHouseHelperUndercutScanMixin:OnHide()
  ClearOverrideBindings(self)
  FrameUtil.UnregisterFrameForEvents(self, CANCELLING_EVENTS)
end

function AuctionHouseHelperUndercutScanMixin:StartScan()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperUndercutScanMixin:OnUndercutScanButtonClick()")

  self.currentAuction = nil
  self.undercutAuctions = {}
  self.seenAuctionResults = {}

  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Cancelling.Events.UndercutScanStart)

  FrameUtil.RegisterFrameForEvents(self, UNDERCUT_START_STOP_EVENTS)
  AuctionHouseHelper.EventBus:Register(self, AH_SCAN_EVENTS)

  self.StartScanButton:SetEnabled(false)
  self:SetCancel()

  self:GetParent().DataProvider:QueryAuctions()
end

function AuctionHouseHelperUndercutScanMixin:SetCancel()
  self.CancelNextButton:SetEnabled(#self.undercutAuctions > 0)
end

function AuctionHouseHelperUndercutScanMixin:EndScan()
  AuctionHouseHelper.Debug.Message("undercut scan ended")

  FrameUtil.UnregisterFrameForEvents(self, UNDERCUT_START_STOP_EVENTS)
  AuctionHouseHelper.EventBus:Unregister(self, AH_SCAN_EVENTS)

  self.StartScanButton:SetEnabled(true)

  self:SetCancel()
end

local function ShouldInclude(itemKey)
  if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.UNDERCUT_SCAN_NOT_LIFO) then
    return true
  else
    local classID = select(6, GetItemInfoInstant(itemKey.itemID))

    return classID ~= Enum.ItemClass.Weapon and classID ~= Enum.ItemClass.Armor and
          itemKey.battlePetSpeciesID == 0
  end
end
function AuctionHouseHelperUndercutScanMixin:NextStep()
  AuctionHouseHelper.Debug.Message("next step")
  self.scanIndex = self.scanIndex + 1

  if self.scanIndex > C_AuctionHouse.GetNumOwnedAuctions() then
    self:EndScan()
    return
  end

  self.currentAuction = C_AuctionHouse.GetOwnedAuctionInfo(self.scanIndex)
  local itemKeyString = AuctionHouseHelper.Utilities.ItemKeyString(self.currentAuction.itemKey)

  if (self.currentAuction.status == 1 or
      self.currentAuction.buyoutAmount == nil or
      self.currentAuction.bidder ~= nil or
      self.currentAuction.itemKey.itemID == AuctionHouseHelper.Constants.WOW_TOKEN_ID or
      not ShouldInclude(self.currentAuction.itemKey)) then
    AuctionHouseHelper.Debug.Message("undercut scan skip")

    self:NextStep()
  elseif self.seenAuctionResults[itemKeyString] ~= nil then
    AuctionHouseHelper.Debug.Message("undercut scan already seen")

    self:ProcessUndercutResult(
      self.currentAuction,
      self.seenAuctionResults[itemKeyString]
    )

    self:NextStep()
  else
    AuctionHouseHelper.Debug.Message("undercut scan searching for undercuts", self.currentAuction.auctionID)

    self:SearchForUndercuts(self.currentAuction)
  end
end

function AuctionHouseHelperUndercutScanMixin:OnEvent(eventName, ...)
  if eventName == "OWNED_AUCTIONS_UPDATED" then
    if not self.currentAuction then
      AuctionHouseHelper.Debug.Message("next step auto")

      self.scanIndex = 0

      self:NextStep()
    else
      AuctionHouseHelper.Debug.Message("list no step auto")
    end

  elseif eventName == "AUCTION_HOUSE_CLOSED" then
    self:EndScan()

  elseif eventName == "AUCTION_CANCELED" then
    FrameUtil.UnregisterFrameForEvents(self, CANCELLING_EVENTS)
    self:SetCancel()
  end
end

function AuctionHouseHelperUndercutScanMixin:ReceiveEvent(eventName, ...)
  if eventName == AuctionHouseHelper.Cancelling.Events.RequestCancel then
    local auctionID = ...
    -- Used to disable button if all the undercut auctions have been cancelled
    for index, info in ipairs(self.undercutAuctions) do
      if info.auctionID == auctionID then
        table.remove(self.undercutAuctions, index)
        break
      end
    end
  elseif eventName == AuctionHouseHelper.Cancelling.Events.RequestCancelUndercut then
    if self.CancelNextButton:IsEnabled() then
      self:CancelNextAuction()
    end

  else -- AH_SCAN_EVENTS
    AuctionHouseHelper.Debug.Message("search results")
    self:ProcessSearchResults(self.currentAuction, ...)
  end
end

function AuctionHouseHelperUndercutScanMixin:SearchForUndercuts(auctionInfo)
  AuctionHouseHelper.AH.GetItemKeyInfo(auctionInfo.itemKey, function(itemKeyInfo)
    local sortingOrder = nil

    if itemKeyInfo == nil then
      self:EndScan()
    elseif itemKeyInfo.isCommodity then
      sortingOrder = {sortOrder = 0, reverseSort = false}
    else
      sortingOrder = {sortOrder = 4, reverseSort = false}
    end

    if not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.UNDERCUT_SCAN_GEAR_MATCH_ILVL_VARIANTS) and
       AuctionHouseHelper.Utilities.IsEquipment(select(6, GetItemInfoInstant(auctionInfo.itemKey.itemID))) then
      self.expectedItemKey = {itemID = auctionInfo.itemKey.itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}
      AuctionHouseHelper.AH.SendSellSearchQueryByItemKey(self.expectedItemKey, {sortingOrder}, true)
    else
      self.expectedItemKey = auctionInfo.itemKey
      AuctionHouseHelper.AH.SendSearchQueryByItemKey(auctionInfo.itemKey, {sortingOrder}, true)
    end
  end)
end

function AuctionHouseHelperUndercutScanMixin:ProcessSearchResults(auctionInfo, ...)
  AuctionHouseHelper.AH.GetItemKeyInfo(auctionInfo.itemKey, function(itemKeyInfo)
    local notUndercutIDs = {}
    local resultCount = 0

    if itemKeyInfo.isCommodity then
      resultCount = C_AuctionHouse.GetNumCommoditySearchResults(self.expectedItemKey.itemID)
    else
      resultCount = C_AuctionHouse.GetNumItemSearchResults(self.expectedItemKey)
    end

    -- Identify all auctions which aren't undercut
    for index = 1, resultCount do
      local resultInfo
      if itemKeyInfo.isCommodity then
        resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(self.expectedItemKey.itemID, index)
      else
        resultInfo = C_AuctionHouse.GetItemSearchResultInfo(self.expectedItemKey, index)
      end

      if resultInfo.owners[1] ~= "player" then
        break
      else
        table.insert(notUndercutIDs, resultInfo.auctionID)
      end
    end

    if resultCount == 0 then
      return
    end

    self:ProcessUndercutResult(auctionInfo, notUndercutIDs)

    self:NextStep()
  end)
end

function AuctionHouseHelperUndercutScanMixin:ProcessUndercutResult(auctionInfo, notUndercutIDs)
  local isUndercut = tIndexOf(notUndercutIDs, auctionInfo.auctionID) == nil
  if isUndercut then
    table.insert(self.undercutAuctions, auctionInfo)
  end

  local itemKeyString = AuctionHouseHelper.Utilities.ItemKeyString(self.currentAuction.itemKey)
  self.seenAuctionResults[itemKeyString] = notUndercutIDs

  AuctionHouseHelper.EventBus:Fire(
    self,
    AuctionHouseHelper.Cancelling.Events.UndercutStatus,
    auctionInfo.auctionID,
    isUndercut
  )
end

function AuctionHouseHelperUndercutScanMixin:CancelNextAuction()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperUndercutScanMixin:CancelNextAuction()")
  FrameUtil.RegisterFrameForEvents(self, CANCELLING_EVENTS)

  AuctionHouseHelper.EventBus:Fire(
    self,
    AuctionHouseHelper.Cancelling.Events.RequestCancel,
    self.undercutAuctions[1].auctionID
  )

  self.CancelNextButton:Disable()
end
