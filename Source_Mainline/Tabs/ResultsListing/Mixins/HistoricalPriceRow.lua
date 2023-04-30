AuctionHouseHelperHistoricalPriceRowMixin = CreateFromMixins(AuctionHouseHelperResultsRowTemplateMixin)

function AuctionHouseHelperHistoricalPriceRowMixin:OnClick(button, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperHistoricalPriceRowMixin:OnClick()")

  if button == "LeftButton" then
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "HistoricalPriceRow")
      :Fire(self, AuctionHouseHelper.Selling.Events.PriceSelected, self.rowData.minSeen)
      :UnregisterSource(self)
  elseif button == "RightButton" then
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "HistoricalPriceRow")
      :Fire(self, AuctionHouseHelper.Selling.Events.PriceSelected, self.rowData.maxSeen)
      :UnregisterSource(self)
  end
end
