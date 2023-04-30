AuctionHouseHelperSellingPostingHistoryProviderMixin = CreateFromMixins(AuctionHouseHelperPostingHistoryProviderMixin)

function AuctionHouseHelperSellingPostingHistoryProviderMixin:OnLoad()
  AuctionHouseHelperPostingHistoryProviderMixin.OnLoad(self)

  AuctionHouseHelper.EventBus:Register( self, {
    AuctionHouseHelper.Selling.Events.BagItemClicked,
    AuctionHouseHelper.Selling.Events.RefreshHistory,
  })
end

function AuctionHouseHelperSellingPostingHistoryProviderMixin:GetColumnHideStates()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.COLUMNS_POSTING_HISTORY)
end

function AuctionHouseHelperSellingPostingHistoryProviderMixin:ReceiveEvent(eventName, eventData)
  if eventName == AuctionHouseHelper.Selling.Events.BagItemClicked then
    local dbKey = AuctionHouseHelper.Utilities.DBKeyFromBrowseResult({ itemKey = eventData.itemKey })[1]
    self.lastDBKey = dbKey

    self:SetItem(dbKey)

  elseif eventName == AuctionHouseHelper.Selling.Events.RefreshHistory and self.lastDBKey ~= nil then
    self:SetItem(self.lastDBKey)
  end
end

function AuctionHouseHelperSellingPostingHistoryProviderMixin:GetRowTemplate()
  return "AuctionHouseHelperSellingPostingHistoryRowTemplate"
end
