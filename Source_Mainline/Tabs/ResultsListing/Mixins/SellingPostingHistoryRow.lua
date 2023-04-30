AuctionHouseHelperSellingPostingHistoryRowMixin = CreateFromMixins(AuctionHouseHelperResultsRowTemplateMixin)

function AuctionHouseHelperSellingPostingHistoryRowMixin:OnClick(button, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperPostingHistoryRowMixin:OnClick()")

  AuctionHouseHelper.EventBus
    :RegisterSource(self, "SellingPostingHistoryRow")
    :Fire(self, AuctionHouseHelper.Selling.Events.PriceSelected, self.rowData.price)
    :UnregisterSource(self)
end
