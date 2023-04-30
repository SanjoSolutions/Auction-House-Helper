local POSTING_HISTORY_PROVIDER_LAYOUT ={
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_UNIT_PRICE,
    headerParameters = { "price" },
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "price" }
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_QUANTITY,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "quantity" },
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

AuctionHouseHelperPostingHistoryProviderMixin = CreateFromMixins(AuctionHouseHelperDataProviderMixin)

function AuctionHouseHelperPostingHistoryProviderMixin:OnLoad()
  AuctionHouseHelperDataProviderMixin.OnLoad(self)
end

function AuctionHouseHelperPostingHistoryProviderMixin:OnShow()
  self:Reset()
end

function AuctionHouseHelperPostingHistoryProviderMixin:SetItem(dbKey)
  self:Reset()

  -- Reset columns
  self.onSearchStarted()

  local entries = AuctionHouseHelper.PostingHistory:GetPriceHistory(dbKey)
  table.sort(entries, function(a, b) return b.rawDay < a.rawDay end)

  self:AppendEntries(entries, true)
end

function AuctionHouseHelperPostingHistoryProviderMixin:GetTableLayout()
  return POSTING_HISTORY_PROVIDER_LAYOUT
end

function AuctionHouseHelperPostingHistoryProviderMixin:UniqueKey(entry)
  return tostring(tostring(entry.price) .. tostring(entry.rawDay))
end

local COMPARATORS = {
  price = AuctionHouseHelper.Utilities.NumberComparator,
  quantity = AuctionHouseHelper.Utilities.NumberComparator,
  rawDay = AuctionHouseHelper.Utilities.StringComparator
}

function AuctionHouseHelperPostingHistoryProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end
