AuctionHouseHelperBuyAuctionsResultsRowMixin = CreateFromMixins(AuctionHouseHelperResultsRowTemplateMixin)

function AuctionHouseHelperBuyAuctionsResultsRowMixin:Populate(...)
  AuctionHouseHelperResultsRowTemplateMixin.Populate(self, ...)

  self.SelectedHighlight:SetShown(self.rowData.isSelected)
  self:SetAlpha(self.rowData.numStacks == 0 and 0.5 or 1.0)
end

function AuctionHouseHelperBuyAuctionsResultsRowMixin:OnEnter()
  if not self.rowData.notReady then
    AuctionHouseHelperResultsRowTemplateMixin.OnEnter(self)
  end
end

function AuctionHouseHelperBuyAuctionsResultsRowMixin:OnLeave()
  if not self.rowData.notReady then
    AuctionHouseHelperResultsRowTemplateMixin.OnLeave(self)
  end
end

function AuctionHouseHelperBuyAuctionsResultsRowMixin:OnClick(button, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperBuyAuctionsResultsRowMixin:OnClick()")

  if self.rowData.numStacks < 1 or self.rowData.stackPrice == nil or self.rowData.notReady then
    return
  end
  self.rowData.isSelected = not self.rowData.isSelected

  if self.rowData.isSelected then
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "BuyAuctionResultsRow")
      :Fire(self, AuctionHouseHelper.Buying.Events.AuctionFocussed, self.rowData)
      :UnregisterSource(self)
  else
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "BuyAuctionResultsRow")
      :Fire(self, AuctionHouseHelper.Buying.Events.AuctionFocussed, nil)
      :UnregisterSource(self)
  end
end
