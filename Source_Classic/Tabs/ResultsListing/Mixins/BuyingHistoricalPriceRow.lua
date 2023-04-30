AuctionHouseHelperBuyingHistoricalPriceRowMixin = CreateFromMixins(AuctionHouseHelperResultsRowTemplateMixin)

function AuctionHouseHelperBuyingHistoricalPriceRowMixin:OnClick(button, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperBuyingHistoricalPriceRowMixin:OnClick()")

  if button == "LeftButton" then
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "BuyingHistoricalPriceRow")
      :Fire(self, AuctionHouseHelper.Buying.Events.HistoricalPrice, self.rowData.minSeen)
      :UnregisterSource(self)
  elseif button == "RightButton" then
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "BuyingHistoricalPriceRow")
      :Fire(self, AuctionHouseHelper.Buying.Events.HistoricalPrice, self.rowData.maxSeen)
      :UnregisterSource(self)
  end
end
