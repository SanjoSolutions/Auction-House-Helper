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
    headerParameters = { "stackSize" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "availablePretty" },
    width = 110,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_UNIT_PRICE,
    headerParameters = { "unitPrice" },
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "unitPrice" },
    width = 150,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_STACK_PRICE,
    headerParameters = { "stackPrice" },
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "stackPrice" },
    defaultHide = true,
    width = 150,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_BID_PRICE,
    headerParameters = { "minBid" },
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "minBid" },
    defaultHide = true,
    width = 150,
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
  "AUCTION_OWNED_LIST_UPDATE",
}

local EVENT_BUS_EVENTS = {
  AuctionHouseHelper.Cancelling.Events.UndercutStatus,
  AuctionHouseHelper.Cancelling.Events.UndercutScanStart,
  AuctionHouseHelper.AH.Events.ThrottleUpdate,
}

AuctionHouseHelperCancellingDataProviderMixin = CreateFromMixins(AuctionHouseHelperDataProviderMixin, AuctionHouseHelperItemStringLoadingMixin)

function AuctionHouseHelperCancellingDataProviderMixin:OnLoad()
  AuctionHouseHelperDataProviderMixin.OnLoad(self)
  AuctionHouseHelperItemStringLoadingMixin.OnLoad(self)

  self.undercutCutoff = {}
end

function AuctionHouseHelperCancellingDataProviderMixin:OnShow()
  AuctionHouseHelper.EventBus:Register(self, EVENT_BUS_EVENTS)

  self:NoQueryRefresh()

  FrameUtil.RegisterFrameForEvents(self, DATA_EVENTS)
end

function AuctionHouseHelperCancellingDataProviderMixin:OnHide()
  AuctionHouseHelper.EventBus:Unregister(self, EVENT_BUS_EVENTS)

  FrameUtil.UnregisterFrameForEvents(self, DATA_EVENTS)
end

function AuctionHouseHelperCancellingDataProviderMixin:NoQueryRefresh()
  self.onPreserveScroll()
  self:PopulateAuctions()
end

local COMPARATORS = {
  unitPrice = AuctionHouseHelper.Utilities.NumberComparator,
  stackPrice = AuctionHouseHelper.Utilities.NumberComparator,
  bidAmount = AuctionHouseHelper.Utilities.NumberComparator,
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
  if eventName == "AUCTION_OWNED_LIST_UPDATE" then
    self:NoQueryRefresh()
  end
end

function AuctionHouseHelperCancellingDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == AuctionHouseHelper.Cancelling.Events.UndercutScanStart then
    self.undercutCutoff = {}

    self:NoQueryRefresh()

  elseif eventName == AuctionHouseHelper.Cancelling.Events.UndercutStatus then
    self.undercutCutoff[eventData] = ...

    self:NoQueryRefresh()
  elseif eventName == AuctionHouseHelper.AH.Events.ThrottleUpdate then
    if eventData then
      self:NoQueryRefresh()
    end
  end
end

function AuctionHouseHelperCancellingDataProviderMixin:IsValidAuction(auctionInfo)
  return not auctionInfo.isSold and (auctionInfo.stackPrice ~= 0 or auctionInfo.minBid ~= 0)
end

function AuctionHouseHelperCancellingDataProviderMixin:IsSoldAuction(auctionInfo)
  return auctionInfo.isSold and auctionInfo.stackPrice ~= 0
end


function AuctionHouseHelperCancellingDataProviderMixin:FilterAuction(auctionInfo)
  local searchString = self:GetParent().SearchFilter:GetText()
  if searchString ~= "" then
    local name = AuctionHouseHelper.Utilities.GetNameFromLink(auctionInfo.itemLink)
    return string.find(string.lower(name), string.lower(searchString), 1, true)
  else
    return true
  end
end

local function ToUniqueKey(entry)
  return AuctionHouseHelper.Search.GetCleanItemLink(entry.itemLink) .. " " .. entry.stackPrice .. " " .. entry.stackSize .. " " .. tostring(entry.isSold) .. " " .. tostring(entry.bidAmount) .. " " .. tostring(entry.minBid) .. " " .. tostring(entry.bidder) .. " " .. entry.timeLeft
end

local function GroupAuctions(allAuctions)
  local seenDetails = {}

  local results = {}
  for _, auction in ipairs(allAuctions) do
    local newEntry = {
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
    }
    if newEntry.itemLink ~= nil then
      local key = ToUniqueKey(newEntry)
      if seenDetails[key] then
        seenDetails[key].numStacks = seenDetails[key].numStacks + 1
      else
        seenDetails[key] = newEntry
        table.insert(results, newEntry)
      end
    end
  end

  return results
end

function AuctionHouseHelperCancellingDataProviderMixin:PopulateAuctions()
  self:Reset()
  local allAuctions = GroupAuctions(AuctionHouseHelper.AH.DumpAuctions("owner"))
  local totalOnSale = 0
  local totalPending = 0

  local results = {}
  for _, auction in ipairs(allAuctions) do

    --Only display unsold and uncancelled (yet) auctions
    if self:IsValidAuction(auction)  then
      if self:FilterAuction(auction) then
        totalOnSale = totalOnSale + auction.stackPrice * auction.numStacks

        local cleanLink = AuctionHouseHelper.Search.GetCleanItemLink(auction.itemLink)
        local undercutStatus
        if auction.bidAmount ~= 0 then
          undercutStatus = AUCTION_HOUSE_HELPER_L_UNDERCUT_BID
        elseif self.undercutCutoff[cleanLink] == nil then
          undercutStatus = AUCTION_HOUSE_HELPER_L_UNDERCUT_UNKNOWN
        elseif self.undercutCutoff[cleanLink] < auction.unitPrice then
          undercutStatus = AUCTION_HOUSE_HELPER_L_UNDERCUT_YES
        else
          undercutStatus = AUCTION_HOUSE_HELPER_L_UNDERCUT_NO
        end
        table.insert(results, {
          numStacks = auction.numStacks,
          stackSize = auction.stackSize,
          stackPrice = auction.stackPrice,
          minBid = auction.minBid,
          itemString = cleanLink,
          unitPrice = auction.unitPrice,
          bidder = auction.bidder or "",
          bidAmount = auction.bidAmount,
          itemLink = auction.itemLink, -- Used for tooltips
          timeLeft = auction.timeLeft,
          timeLeftPretty = AuctionHouseHelper.Utilities.FormatTimeLeftBand(auction.timeLeft),
          undercut = undercutStatus,
        })
        AuctionHouseHelper.Utilities.SetStacksText(results[#results])
      end
    elseif self:IsSoldAuction(auction) then
      totalPending = totalPending + auction.stackPrice * auction.numStacks
    end
  end
  self:AppendEntries(results, true)

  AuctionHouseHelper.EventBus:RegisterSource(self, "CancellingDataProvider")
    :Fire(self, AuctionHouseHelper.Cancelling.Events.TotalUpdated, totalOnSale, totalPending)
    :UnregisterSource(self)
end

function AuctionHouseHelperCancellingDataProviderMixin:UniqueKey(entry)
  return tostring(entry)
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
