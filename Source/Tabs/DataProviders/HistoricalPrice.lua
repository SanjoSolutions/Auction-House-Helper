local HISTORICAL_PRICE_PROVIDER_LAYOUT ={
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_UNIT_PRICE,
    headerParameters = { "minSeen" },
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "minSeen" }
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_UPPER_UNIT_PRICE,
    headerParameters = { "maxSeen" },
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "maxSeen" },
    defaultHide = true
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "available" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "availableFormatted" },
    width = 100
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_DATE,
    headerParameters = { "rawDay" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "date" }
  },
}

AuctionHouseHelperHistoricalPriceProviderMixin = CreateFromMixins(AuctionHouseHelperDataProviderMixin)

function AuctionHouseHelperHistoricalPriceProviderMixin:OnShow()
  self:Reset()
end

function AuctionHouseHelperHistoricalPriceProviderMixin:SetItem(dbKey)
  self:Reset()

  -- Reset columns
  self.onSearchStarted()

  local entries = AuctionHouseHelper.Database:GetPriceHistory(dbKey)

  for _, entry in ipairs(entries) do
    if entry.available then
      entry.availableFormatted = FormatLargeNumber(entry.available)
    else
      entry.availableFormatted = ""
    end
  end

  self:AppendEntries(entries, true)
end

function AuctionHouseHelperHistoricalPriceProviderMixin:GetTableLayout()
  return HISTORICAL_PRICE_PROVIDER_LAYOUT
end

function AuctionHouseHelperHistoricalPriceProviderMixin:UniqueKey(entry)
  return tostring(entry.rawDay)
end

local COMPARATORS = {
  minSeen = AuctionHouseHelper.Utilities.NumberComparator,
  maxSeen = AuctionHouseHelper.Utilities.NumberComparator,
  available = AuctionHouseHelper.Utilities.NumberComparator,
  rawDay = AuctionHouseHelper.Utilities.StringComparator
}

function AuctionHouseHelperHistoricalPriceProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end
