AuctionHouseHelperItemHistoryFrameMixin = CreateFromMixins(AuctionHouseHelperEscapeToCloseMixin)

function AuctionHouseHelperItemHistoryFrameMixin:Init()
  self.ResultsListing:Init(self.DataProvider)

  AuctionHouseHelper.EventBus:Register(self, { AuctionHouseHelper.Shopping.Tab.Events.ShowHistoricalPrices })
  self.isDocked = false
end

function AuctionHouseHelperItemHistoryFrameMixin:OnShow()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperItemHistoryFrameMixin:OnShow()")

  AuctionHouseHelper.EventBus
    :RegisterSource(self, "lists item history dialog")
    :Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionHouseHelperItemHistoryFrameMixin:OnHide()
  self:Hide()

  AuctionHouseHelper.EventBus
    :RegisterSource(self, "lists item history 1")
    :Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionHouseHelperItemHistoryFrameMixin:ReceiveEvent(event, itemInfo)
  if event == AuctionHouseHelper.Shopping.Tab.Events.ShowHistoricalPrices then
    self.Title:SetText(AUCTION_HOUSE_HELPER_L_X_PRICE_HISTORY:format(itemInfo.name))
  end
end

function AuctionHouseHelperItemHistoryFrameMixin:OnDockDialogClicked()
  self:ClearAllPoints()
  if self.isDocked then
    self:SetPoint("CENTER", self:GetParent(), "CENTER")
    --Reset flipping
    self.Dock.Arrow:SetTexCoord(0, 1, 0, 1)
  else
    self:SetPoint("LEFT", AuctionHouseFrame or AuctionFrame, "RIGHT")
    --Flip the texture to point back in
    self.Dock.Arrow:SetTexCoord(1, 0, 0, 1)
  end

  self.isDocked = not self.isDocked
end

function AuctionHouseHelperItemHistoryFrameMixin:OnCloseDialogClicked()
  self:Hide()
end
