AuctionHouseHelperBuyingRealmHistoryDataProviderMixin = CreateFromMixins(AuctionHouseHelperHistoricalPriceProviderMixin)

function AuctionHouseHelperBuyingRealmHistoryDataProviderMixin:SetItemLink(itemLink)
  AuctionHouseHelper.Utilities.DBKeyFromLink(itemLink, function(dbKeys)
    self:SetItem(dbKeys[1])
  end)
end

function AuctionHouseHelperBuyingRealmHistoryDataProviderMixin:GetColumnHideStates()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.COLUMNS_BUYING_HISTORICAL_PRICES)
end

function AuctionHouseHelperBuyingRealmHistoryDataProviderMixin:GetRowTemplate()
  return "AuctionHouseHelperBuyingHistoricalPriceRowTemplate"
end
