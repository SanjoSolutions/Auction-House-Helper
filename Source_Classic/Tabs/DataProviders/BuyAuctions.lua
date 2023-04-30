local BUY_AUCTIONS_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "unitPrice" },
    headerText = AUCTION_HOUSE_HELPER_L_UNIT_PRICE,
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "unitPrice" },
    width = 145,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "stackSize" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "availablePretty" },
    width = 120,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "stackPrice" },
    headerText = AUCTION_HOUSE_HELPER_L_RESULTS_STACK_PRICE_COLUMN,
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "stackPrice" },
    width = 145,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "otherSellers" },
    headerText = AUCTION_HOUSE_HELPER_L_SELLERS_COLUMN,
    cellTemplate = "AuctionHouseHelperTooltipStringCellTemplate",
    cellParameters = { "otherSellers" },
    defaultHide = true,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "isOwnedText" },
    headerText = AUCTION_HOUSE_HELPER_L_YOU_COLUMN,
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "isOwnedText" },
  },
}

local BUY_EVENTS = {
  AuctionHouseHelper.AH.Events.ScanResultsUpdate,
  AuctionHouseHelper.AH.Events.ScanAborted,
}

AuctionHouseHelperBuyAuctionsDataProviderMixin = CreateFromMixins(AuctionHouseHelperDataProviderMixin)

function AuctionHouseHelperBuyAuctionsDataProviderMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperBuyAuctionsDataProviderMixin:OnLoad()")
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperBuyAuctionsDataProviderMixin")

  AuctionHouseHelperDataProviderMixin.OnLoad(self)
  self:SetUpEvents()
  self.gotAllResults = true
  self.requestAllResults = true
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:SetUpEvents()
  AuctionHouseHelper.EventBus:RegisterSource(self, "Buy Auctions Data Provider")

  AuctionHouseHelper.EventBus:Register( self, {
    AuctionHouseHelper.Buying.Events.AuctionFocussed,
    AuctionHouseHelper.Buying.Events.StacksUpdated,
  })
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:SetAuctions(entries)
  self.allAuctions = {}
  self:ImportAdditionalResults(entries)
  self:PopulateAuctions()
  self:SetSelectedIndex(1)
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:SetQuery(itemLink)
  self:Reset()

  if itemLink == nil then
    self.query = nil
    self.searchKey = nil
  else
    self.searchKey = AuctionHouseHelper.Search.GetCleanItemLink(itemLink)
    self.query = {
      searchString = AuctionHouseHelper.Utilities.GetNameFromLink(itemLink),
      minLevel = nil, maxLevel = nil,
      itemClassFilters = {},
      isExact = true,
    }
  end
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:SetRequestAllResults(newValue)
  self.requestAllResults = newValue
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:GetRequestAllResults()
  return self.requestAllResults
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == AuctionHouseHelper.AH.Events.ScanResultsUpdate then
    self.gotAllResults = ...
    if self.gotAllResults then
      AuctionHouseHelper.EventBus:Unregister(self, BUY_EVENTS)
    end

    self:ImportAdditionalResults(eventData)

    if not self.requestAllResults and #self.allAuctions > 0 then
      AuctionHouseHelper.AH.AbortQuery()
      self.gotAllResults = true
    end

    self:PopulateAuctions()

    if self.gotAllResults then
      self:ReportNewMinPrice()
      self:SetSelectedIndex(1)

      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Buying.Events.ViewSetup, result)
    end

  elseif eventName == AuctionHouseHelper.AH.Events.ScanAborted then
    AuctionHouseHelper.EventBus:Unregister(self, BUY_EVENTS)
    self.onSearchEnded()
  elseif eventName == AuctionHouseHelper.Buying.Events.AuctionFocussed and self:IsShown() then
    for _, entry in ipairs(self.results) do
      entry.isSelected = entry == eventData
    end
    self:SetDirty()
  elseif eventName == AuctionHouseHelper.Buying.Events.StacksUpdated and self:IsShown() then
    self:SetDirty()
  end
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:RefreshQuery()
  self:Reset()

  if self.query ~= nil then
    AuctionHouseHelper.AH.AbortQuery()

    self.onSearchStarted()

    self.allAuctions = {}
    self.gotAllResults = false
    AuctionHouseHelper.EventBus:Register(self, BUY_EVENTS)
    AuctionHouseHelper.AH.QueryAuctionItems(self.query)
  end
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:HasAllQueriedResults()
  return self.gotAllResults
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:EndAnyQuery()
  AuctionHouseHelper.AH.AbortQuery()
  AuctionHouseHelper.EventBus:Unregister(self, BUY_EVENTS)
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:ImportAdditionalResults(results)
  local waiting = #results
  for _, entry in ipairs(results) do
    local itemID = entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.ItemID]
    local itemString = AuctionHouseHelper.Search.GetCleanItemLink(entry.itemLink)
    if self.searchKey == itemString then
      table.insert(self.allAuctions, entry)
    end
  end
end

local function ToStackSize(entry)
  return entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity]
end
local function ToOwner(entry)
  return tostring(entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.Owner])
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:PopulateAuctions()
  self:Reset()

  table.sort(self.allAuctions, function(a, b)
    local unitA = AuctionHouseHelper.Utilities.ToUnitPrice(a)
    local unitB = AuctionHouseHelper.Utilities.ToUnitPrice(b)
    if unitA == unitB then
      local stackA = ToStackSize(a)
      local stackB = ToStackSize(b)
      if stackA == stackB then
        local ownerA = ToOwner(a)
        local ownerB = ToOwner(b)
        return ownerA < ownerB
      else
        return stackA > stackB
      end
    else
      return unitA < unitB
    end
  end)

  local bidOnlyItems = false
  local results = {}
  for _, auction in ipairs(self.allAuctions) do
    local newEntry = {
      itemLink = auction.itemLink,
      unitPrice = AuctionHouseHelper.Utilities.ToUnitPrice(auction),
      stackPrice = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Buyout],
      stackSize = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity],
      numStacks = 1,
      isOwned = ToOwner(auction) == (GetUnitName("player")),
      otherSellers = ToOwner(auction),
      bidAmount = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.BidAmount],
      isSelected = false, --Used by rows to determine highlight
      notReady = true,
      query = auction.query,
      page = auction.page,
    }
    if newEntry.unitPrice == 0 then
      newEntry.unitPrice = nil
      newEntry.stackPrice = nil
    end

    if newEntry.isOwned then
      newEntry.otherSellers = GREEN_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_HELPER_L_YOU)
      newEntry.isOwnedText = AUCTION_HOUSE_HELPER_L_UNDERCUT_YES
    else
      newEntry.isOwnedText = ""
    end
    AuctionHouseHelper.Utilities.SetStacksText(newEntry)

    if newEntry.unitPrice == nil then
      bidOnlyItems = true
    else
      local prevResult = results[#results] or {}
      if prevResult.unitPrice == newEntry.unitPrice and
         prevResult.stackSize == newEntry.stackSize and
         prevResult.itemLink == newEntry.itemLink and
         prevResult.otherSellers == newEntry.otherSellers and
         (prevResult.bidAmount == newEntry.bidAmount or prevResult.unitPrice == nil) then
        prevResult.numStacks = prevResult.numStacks + 1
        AuctionHouseHelper.Utilities.SetStacksText(prevResult)
      else
        prevResult.nextEntry = newEntry
        table.insert(results, newEntry)
      end
      results[#results].page = math.min(results[#results].page, auction.page)
    end
  end

  if bidOnlyItems then
    table.insert(results, {
      itemLink = self.query.itemLink,
      unitPrice = nil,
      stackPrice = nil,
      stackSize = 0,
      numStacks = 0,
      isOwned = false,
      otherSellers = "",
      bidAmount = 0,
      isSelected = false,
      notReady = true,
      query = self.query,
      page = 0,
    })
    results[#results].availablePretty = AUCTION_HOUSE_HELPER_L_BID_ONLY_AVAILABLE
  end

  self:AppendEntries(results, self.gotAllResults)
  self.currentResults = results
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:PurgeAndReplaceOwnedAuctions(ownedAuctions)
  if self.query ~= nil then
    self.onPreserveScroll()
    local prevSelectedIndex = self:GetSelectedIndex()

    local newAllAuctions = {}
    for _, entry in ipairs(self.allAuctions) do
      if ToOwner(entry) ~= (GetUnitName("player")) then
        table.insert(newAllAuctions, entry)
      end
    end

    self.allAuctions = newAllAuctions

    for _, entry in ipairs(ownedAuctions) do
      entry.page = 0
      entry.query = self.query
    end

    self:ImportAdditionalResults(ownedAuctions)
    self:PopulateAuctions()

    self:SetSelectedIndex(prevSelectedIndex or 1)
    self:SetDirty()
  end
end

-- Set a new price in the price database based on the current results.
-- Assumes being called after PopulateAuctions which will have sorted the
-- auctions from min price to max AND that all the results have been acquired
function AuctionHouseHelperBuyAuctionsDataProviderMixin:ReportNewMinPrice()
  if #self.allAuctions > 0 then
    local minPrice = 0
    local index = 1
    while minPrice == 0 and index <= #self.allAuctions do
      minPrice = AuctionHouseHelper.Utilities.ToUnitPrice(self.allAuctions[index])
      index = index + 1
    end

    local available = 0
    for _, auction in ipairs(self.allAuctions) do
      available = available + auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity]
    end

    if minPrice ~= 0 and available > 0 then
      AuctionHouseHelper.Utilities.DBKeyFromLink(self.allAuctions[1].itemLink, function(dbKeys)
        for _, key in ipairs(dbKeys) do
          AuctionHouseHelper.Database:SetPrice(key, minPrice, available)
        end
      end)
    end
  end
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:GetSelectedIndex()
  for index, result in ipairs(self.currentResults) do
    if result.isSelected then
      return index
    end
  end
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:SetSelectedIndex(newSelectedIndex)
  self.onPreserveScroll()
  for index, result in ipairs(self.currentResults) do
    result.notReady = false
    result.isSelected = false

    if index == newSelectedIndex and result.unitPrice ~= nil then
      result.isSelected = true
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Buying.Events.AuctionFocussed, result)
    end
  end
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:UniqueKey(entry)
  return tostring(entry)
end

local COMPARATORS = {
  unitPrice = AuctionHouseHelper.Utilities.NumberComparator,
  stackPrice = AuctionHouseHelper.Utilities.NumberComparator,
  name = AuctionHouseHelper.Utilities.StringComparator,
  stackSize = AuctionHouseHelper.Utilities.StringComparator,
  numStacks = AuctionHouseHelper.Utilities.NumberComparator,
  otherSellers = AuctionHouseHelper.Utilities.StringComparator,
  isOwnedText = AuctionHouseHelper.Utilities.StringComparator,
}

function AuctionHouseHelperBuyAuctionsDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:GetTableLayout()
  return BUY_AUCTIONS_TABLE_LAYOUT
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:GetColumnHideStates()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.COLUMNS_BUY_AUCTIONS)
end

function AuctionHouseHelperBuyAuctionsDataProviderMixin:GetRowTemplate()
  return "AuctionHouseHelperBuyAuctionsResultsRowTemplate"
end
