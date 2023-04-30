local CANCELLING_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTION_HOUSE_HELPER_L_NAME,
    cellTemplate = "AuctionHouseHelperItemKeyCellTemplate",
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_QUANTITY,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "quantity" },
    width = 70
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_UNIT_PRICE,
    headerParameters = { "price" },
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "price" },
    width = 150,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_BID_PRICE,
    headerParameters = { "bidPrice" },
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "bidPrice" },
    width = 150,
    defaultHide = true,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_BIDDER,
    headerParameters = { "bidder" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "bidder" },
    defaultHide = true,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_TIME_LEFT,
    headerParameters = { "timeLeft" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "timeLeftPretty" },
    width = 90,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_IS_UNDERCUT,
    headerParameters = { "undercut" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "undercut" },
    width = 90,
  },
}

local DATA_EVENTS = {
  "OWNED_AUCTIONS_UPDATED",
  "AUCTION_CANCELED"
}

local EVENT_BUS_EVENTS = {
  AuctionHouseHelper.Cancelling.Events.RequestCancel,
  AuctionHouseHelper.Cancelling.Events.UndercutStatus,
  AuctionHouseHelper.Cancelling.Events.UndercutScanStart,
}

local function DumpOwnedAuctions(callback)
  local result = {}

  local waiting = C_AuctionHouse.GetNumOwnedAuctions()

  for index = 1, C_AuctionHouse.GetNumOwnedAuctions() do
    local index = index
    local info = C_AuctionHouse.GetOwnedAuctionInfo(index)

    table.insert(result, info)

    AuctionHouseHelper.AH.GetItemKeyInfo(info.itemKey, function(itemKeyInfo)
      waiting = waiting - 1
      result[index].searchName = itemKeyInfo.itemName
      if waiting == 0 then
        callback(result)
      end
    end)
  end

  if C_AuctionHouse.GetNumOwnedAuctions() == 0 then
    callback(result)
  end
end

AuctionHouseHelperCancellingDataProviderMixin = CreateFromMixins(AuctionHouseHelperDataProviderMixin, AuctionHouseHelperItemKeyLoadingMixin)

function AuctionHouseHelperCancellingDataProviderMixin:OnLoad()
  AuctionHouseHelperDataProviderMixin.OnLoad(self)
  AuctionHouseHelperItemKeyLoadingMixin.OnLoad(self)

  self.waitingforCancellation = {}
  self.beenCancelled = {}

  self.undercutInfo = {}
end

function AuctionHouseHelperCancellingDataProviderMixin:OnShow()
  AuctionHouseHelper.EventBus:Register(self, EVENT_BUS_EVENTS)

  self:QueryAuctions()

  FrameUtil.RegisterFrameForEvents(self, DATA_EVENTS)
end

function AuctionHouseHelperCancellingDataProviderMixin:OnHide()
  AuctionHouseHelper.EventBus:Unregister(self, EVENT_BUS_EVENTS)

  FrameUtil.UnregisterFrameForEvents(self, DATA_EVENTS)
end

function AuctionHouseHelperCancellingDataProviderMixin:QueryAuctions()
  self.onPreserveScroll()
  self.onSearchStarted()

  AuctionHouseHelper.AH.QueryOwnedAuctions({{sortOrder = 1, reverseSort = false}})
end

function AuctionHouseHelperCancellingDataProviderMixin:NoQueryRefresh()
  self.onPreserveScroll()
  DumpOwnedAuctions(function(auctions)
    self:PopulateAuctions(auctions)
  end)
end

local COMPARATORS = {
  price = AuctionHouseHelper.Utilities.NumberComparator,
  bidPrice = AuctionHouseHelper.Utilities.NumberComparator,
  name = AuctionHouseHelper.Utilities.StringComparator,
  bidder = AuctionHouseHelper.Utilities.StringComparator,
  quantity = AuctionHouseHelper.Utilities.NumberComparator,
  timeLeft = AuctionHouseHelper.Utilities.NumberComparator,
  undercut = AuctionHouseHelper.Utilities.StringComparator,
}

function AuctionHouseHelperCancellingDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionHouseHelperCancellingDataProviderMixin:OnEvent(eventName, auctionID, ...)
  if eventName == "AUCTION_CANCELED" then
    if (tIndexOf(self.waitingforCancellation, auctionID) ~= nil and
        tIndexOf(self.beenCancelled, auctionID) == nil) then
      table.insert(self.beenCancelled, auctionID)
      self:NoQueryRefresh()
    else
      self:QueryAuctions()
    end

  elseif eventName == "OWNED_AUCTIONS_UPDATED" then
    DumpOwnedAuctions(function(auctions)
      self:PopulateAuctions(auctions)
    end)
  end
end

function AuctionHouseHelperCancellingDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == AuctionHouseHelper.Cancelling.Events.RequestCancel then
    table.insert(self.waitingforCancellation, eventData)

  elseif eventName == AuctionHouseHelper.Cancelling.Events.UndercutScanStart then
    self.undercutInfo = {}

    self:NoQueryRefresh()

  elseif eventName == AuctionHouseHelper.Cancelling.Events.UndercutStatus then
    local isUndercut = ...
    if isUndercut then
      self.undercutInfo[eventData] = AUCTION_HOUSE_HELPER_L_UNDERCUT_YES
    else
      self.undercutInfo[eventData] = AUCTION_HOUSE_HELPER_L_UNDERCUT_NO
    end

    self:NoQueryRefresh()
  end
end

function AuctionHouseHelperCancellingDataProviderMixin:IsValidAuction(auctionInfo)
  return
    --We don't handle WoW Tokens (can't cancel and no time left)
    auctionInfo.itemKey.itemID ~= AuctionHouseHelper.Constants.WOW_TOKEN_ID and
    auctionInfo.status == 0 and
    tIndexOf(self.beenCancelled, auctionInfo.auctionID) == nil
end

function AuctionHouseHelperCancellingDataProviderMixin:IsSoldAuction(auctionInfo)
  return
    auctionInfo.itemKey.itemID ~= AuctionHouseHelper.Constants.WOW_TOKEN_ID and
    auctionInfo.status == 1
end

function AuctionHouseHelperCancellingDataProviderMixin:FilterAuction(auctionInfo)
  local searchString = self:GetParent().SearchFilter:GetText()
  if searchString ~= "" then
    return string.find(string.lower(auctionInfo.searchName), string.lower(searchString), 1, true)
  else
    return true
  end
end

function AuctionHouseHelperCancellingDataProviderMixin:PopulateAuctions(auctions)
  self:Reset()

  local results = {}
  local totalOnSale = 0
  local totalPending = 0

  for _, info in ipairs(auctions) do
    local price = info.buyoutAmount or info.bidAmount
    --Only display unsold and uncancelled (yet) auctions
    if self:IsValidAuction(info) then
      totalOnSale = totalOnSale + price * info.quantity
      if self:FilterAuction(info) then
        local entry = {
          id = info.auctionID,
          quantity = info.quantity,
          price = info.buyoutAmount,
          bidPrice = info.bidAmount,
          bidder = info.bidder,
          itemKey = info.itemKey,
          itemLink = info.itemLink, -- Used for tooltips
          timeLeft = info.timeLeftSeconds,
          timeLeftPretty = AuctionHouseHelper.Utilities.FormatTimeLeft(info.timeLeftSeconds),
          cancelled = (tIndexOf(self.waitingforCancellation, info.auctionID) ~= nil),
          undercut = self.undercutInfo[info.auctionID] or AUCTION_HOUSE_HELPER_L_UNDERCUT_UNKNOWN,
          searchName = info.searchName,
        }
        if info.bidder ~= nil then
          entry.undercut = AUCTION_HOUSE_HELPER_L_UNDERCUT_BID
        end

        table.insert(results, entry)
      end
    elseif self:IsSoldAuction(info) then
      totalPending = totalPending + price
    end
  end
  self:AppendEntries(results, true)

  AuctionHouseHelper.EventBus:RegisterSource(self, "CancellingDataProvider")
    :Fire(self, AuctionHouseHelper.Cancelling.Events.TotalUpdated, totalOnSale, totalPending)
    :UnregisterSource(self)
end

function AuctionHouseHelperCancellingDataProviderMixin:UniqueKey(entry)
  return tostring(entry.id)
end

function AuctionHouseHelperCancellingDataProviderMixin:GetTableLayout()
  return CANCELLING_TABLE_LAYOUT
end

function AuctionHouseHelperCancellingDataProviderMixin:GetColumnHideStates()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.COLUMNS_CANCELLING)
end

function AuctionHouseHelperCancellingDataProviderMixin:GetRowTemplate()
  return "AuctionHouseHelperCancellingListResultsRowTemplate"
end
