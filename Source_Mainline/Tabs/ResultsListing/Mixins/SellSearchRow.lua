AuctionHouseHelperSellSearchRowMixin = CreateFromMixins(AuctionHouseHelperResultsRowTemplateMixin)

local function BuyEntry(entry)
  AuctionHouseHelper.EventBus
    :RegisterSource(BuyEntry, "BuyEntry")
    :Fire(BuyEntry, AuctionHouseHelper.Selling.Events.ShowConfirmPurchase, entry)
    :UnregisterSource(BuyEntry)
end

function AuctionHouseHelperSellSearchRowMixin:OnEnter()
  if AuctionHouseUtil ~= nil then
    AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  end
  AuctionHouseHelperResultsRowTemplateMixin.OnEnter(self)
end

function AuctionHouseHelperSellSearchRowMixin:OnLeave()
  if AuctionHouseUtil ~= nil then
    AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  end
  AuctionHouseHelperResultsRowTemplateMixin.OnLeave(self)
end

function AuctionHouseHelperSellSearchRowMixin:OnClick(button, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperSellSearchRowMixin:OnClick()")

  if AuctionHouseHelper.Utilities.IsShortcutActive(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_CANCEL_SHORTCUT), button) then
    if C_AuctionHouse.CanCancelAuction(self.rowData.auctionID) then
      AuctionHouseHelper.EventBus
        :RegisterSource(self, "SellSearchRow")
        :Fire(self, AuctionHouseHelper.Cancelling.Events.RequestCancel, self.rowData.auctionID)
        :UnregisterSource(self)
    end

  elseif AuctionHouseHelper.Utilities.IsShortcutActive(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_BUY_SHORTCUT), button) then
    if self.rowData.canBuy then
      BuyEntry(self.rowData)
    end

  elseif IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);

  elseif IsModifiedClick("CHATLINK") then
    ChatEdit_InsertLink(self.rowData.itemLink)

  else
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "SellSearchRow")
      :Fire(self, AuctionHouseHelper.Selling.Events.PriceSelected, self.rowData.price or self.rowData.bidPrice, true)
      :UnregisterSource(self)
  end
end
