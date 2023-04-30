AuctionHouseHelperBuyingPostingHistoryRowMixin = CreateFromMixins(AuctionHouseHelperResultsRowTemplateMixin)

function AuctionHouseHelperBuyingPostingHistoryRowMixin:OnClick(button, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperBuyingPostingHistoryRowMixin:OnClick()")

  if button == "LeftButton" then
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "BuyingPostingHistoryRow")
      :Fire(self, AuctionHouseHelper.Buying.Events.HistoricalPrice, self.rowData.price)
      :UnregisterSource(self)
  end
end
