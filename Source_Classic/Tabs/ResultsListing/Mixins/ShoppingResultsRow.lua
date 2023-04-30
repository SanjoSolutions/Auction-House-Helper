AuctionHouseHelperShoppingResultsRowMixin = CreateFromMixins(AuctionHouseHelperResultsRowTemplateMixin)

function AuctionHouseHelperShoppingResultsRowMixin:OnClick(button, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperShoppingResultsRowMixin:OnClick()")
  AuctionHouseHelperResultsRowTemplateMixin.OnClick(self, button, ...)

  if self.rowData.itemLink == nil then
    return
  end

  if button == "RightButton" then
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "ShoppingResultsRowMixin")
      :Fire(self, AuctionHouseHelper.Shopping.Tab.Events.ShowHistoricalPrices, self.rowData)
      :UnregisterSource(self)
  else

    AuctionHouseHelper.EventBus
      :RegisterSource(self, "ShoppingResultsRowMixin")
      :Fire(self, AuctionHouseHelper.Buying.Events.ShowForShopping, self.rowData)
      :UnregisterSource(self)
  end
end
