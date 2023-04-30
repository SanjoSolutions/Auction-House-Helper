AuctionHouseHelperBuyingPostingHistoryProviderMixin = CreateFromMixins(AuctionHouseHelperPostingHistoryProviderMixin)

function AuctionHouseHelperBuyingPostingHistoryProviderMixin:OnLoad()
  AuctionHouseHelperPostingHistoryProviderMixin.OnLoad(self)
end

function AuctionHouseHelperBuyingPostingHistoryProviderMixin:SetItemLink(itemLink)
  AuctionHouseHelper.Utilities.DBKeyFromLink(itemLink, function(dbKeys)
    self:SetItem(dbKeys[1])
  end)
end

function AuctionHouseHelperBuyingPostingHistoryProviderMixin:GetColumnHideStates()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.COLUMNS_POSTING_HISTORY)
end

function AuctionHouseHelperBuyingPostingHistoryProviderMixin:GetRowTemplate()
  return "AuctionHouseHelperBuyingPostingHistoryRowTemplate"
end
