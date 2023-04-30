local SHOPPING_LIST_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "minPrice" },
    headerText = AUCTION_HOUSE_HELPER_L_RESULTS_PRICE_COLUMN,
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "minPrice" },
    width = 140
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTION_HOUSE_HELPER_L_RESULTS_NAME_COLUMN,
    cellTemplate = "AuctionHouseHelperItemKeyCellTemplate"
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "isOwned" },
    headerText = AUCTION_HOUSE_HELPER_L_OWNED_COLUMN,
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "isOwned" },
    defaultHide = true,
    width = 70,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "isTop" },
    headerText = AUCTION_HOUSE_HELPER_L_IS_TOP_COLUMN,
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "isTop" },
    defaultHide = true,
    width = 70,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "totalQuantity" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "totalQuantityString" },
    width = 70
  }
}

AuctionHouseHelperShoppingDataProviderMixin = CreateFromMixins(AuctionHouseHelperDataProviderMixin, AuctionHouseHelperItemStringLoadingMixin)

function AuctionHouseHelperShoppingDataProviderMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperShoppingDataProviderMixin:OnLoad()")

  self:SetUpEvents()

  AuctionHouseHelperDataProviderMixin.OnLoad(self)
  AuctionHouseHelperItemStringLoadingMixin.OnLoad(self)
end

function AuctionHouseHelperShoppingDataProviderMixin:SetUpEvents()
  AuctionHouseHelper.EventBus:RegisterSource(self, "Shopping List Data Provider")

  AuctionHouseHelper.EventBus:Register( self, {
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchIncrementalUpdate
  })
end

function AuctionHouseHelperShoppingDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted then
    self:Reset()
    self.onSearchStarted()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded then
    self:AppendEntries(self:AddDetails(eventData), true)
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchIncrementalUpdate then
    self:AppendEntries(self:AddDetails(eventData))
  end
end

function AuctionHouseHelperShoppingDataProviderMixin:AddDetails(entries)
  for _, entry in ipairs(entries) do
    if entry.containsOwnerItem then
      entry.isOwned = AUCTION_HOUSE_HELPER_L_UNDERCUT_YES
    else
      entry.isOwned = ""
    end

    if entry.isTopItem then
      entry.isTop = GREEN_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_HELPER_L_UNDERCUT_YES)
    else
      entry.isTop = RED_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_HELPER_L_UNDERCUT_NO)
    end

    if not entry.complete then
      entry.totalQuantityString = AUCTION_HOUSE_HELPER_L_UNDERCUT_UNKNOWN
    else
      entry.totalQuantityString = tostring(entry.totalQuantity)
    end
  end

  return entries
end

function AuctionHouseHelperShoppingDataProviderMixin:UniqueKey(entry)
  return entry.itemString
end

local COMPARATORS = {
  minPrice = AuctionHouseHelper.Utilities.NumberComparator,
  name = AuctionHouseHelper.Utilities.StringComparator,
  isOwned = AuctionHouseHelper.Utilities.StringComparator,
  totalQuantity = AuctionHouseHelper.Utilities.NumberComparator
}

function AuctionHouseHelperShoppingDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionHouseHelperShoppingDataProviderMixin:GetTableLayout()
  return SHOPPING_LIST_TABLE_LAYOUT
end

function AuctionHouseHelperShoppingDataProviderMixin:GetColumnHideStates()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.COLUMNS_SHOPPING)
end

function AuctionHouseHelperShoppingDataProviderMixin:GetRowTemplate()
  return "AuctionHouseHelperShoppingResultsRowTemplate"
end
