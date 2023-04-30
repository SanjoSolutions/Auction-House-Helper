AuctionHouseHelperShoppingHistoricalPriceProviderMixin = CreateFromMixins(AuctionHouseHelperHistoricalPriceProviderMixin)

function AuctionHouseHelperShoppingHistoricalPriceProviderMixin:OnLoad()
  AuctionHouseHelperHistoricalPriceProviderMixin.OnLoad(self)

  AuctionHouseHelper.EventBus:Register( self, { AuctionHouseHelper.Shopping.Tab.Events.ShowHistoricalPrices })
end

function AuctionHouseHelperShoppingHistoricalPriceProviderMixin:ReceiveEvent(event, itemInfo)
  if event == AuctionHouseHelper.Shopping.Tab.Events.ShowHistoricalPrices then
    AuctionHouseHelper.Utilities.DBKeyFromLink(itemInfo.itemLink, function(dbKeys)
      self:SetItem(dbKeys[1])
    end)
  end
end

function AuctionHouseHelperShoppingHistoricalPriceProviderMixin:GetColumnHideStates()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.COLUMNS_SHOPPING_HISTORICAL_PRICES)
end
