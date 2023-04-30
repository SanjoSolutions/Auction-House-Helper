AuctionHouseHelperSellingHistoricalPriceProviderMixin = CreateFromMixins(AuctionHouseHelperHistoricalPriceProviderMixin)

function AuctionHouseHelperSellingHistoricalPriceProviderMixin:OnLoad()
  AuctionHouseHelperHistoricalPriceProviderMixin.OnLoad(self)

  AuctionHouseHelper.EventBus:Register( self, {
    AuctionHouseHelper.Selling.Events.BagItemClicked,
    AuctionHouseHelper.Selling.Events.RefreshHistory,
  })
end

function AuctionHouseHelperSellingHistoricalPriceProviderMixin:ReceiveEvent(eventName, itemInfo)
  if eventName == AuctionHouseHelper.Selling.Events.BagItemClicked then
    local dbKey = AuctionHouseHelper.Utilities.DBKeyFromBrowseResult({ itemKey = itemInfo.itemKey })[1]
    self.lastDBKey = dbKey

    self:SetItem(dbKey)

  elseif eventName == AuctionHouseHelper.Selling.Events.RefreshHistory and self.lastDBKey ~= nil then
    self:SetItem(self.lastDBKey)
  end
end

function AuctionHouseHelperSellingHistoricalPriceProviderMixin:GetRowTemplate()
  return "AuctionHouseHelperHistoricalPriceRowTemplate"
end

function AuctionHouseHelperSellingHistoricalPriceProviderMixin:GetColumnHideStates()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.COLUMNS_HISTORICAL_PRICES)
end
