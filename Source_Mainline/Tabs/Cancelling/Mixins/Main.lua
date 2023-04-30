AuctionHouseHelperCancellingFrameMixin = {}

function AuctionHouseHelperCancellingFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperCancellingFrameMixin:OnLoad()")

  self.ResultsListing:Init(self.DataProvider)

  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Cancelling.Events.RequestCancel,
    AuctionHouseHelper.Cancelling.Events.TotalUpdated,
  })

  self.SearchFilter:HookScript("OnTextChanged", function()
    self.DataProvider:NoQueryRefresh()
  end)
end

function AuctionHouseHelperCancellingFrameMixin:RefreshButtonClicked()
  self.DataProvider:QueryAuctions()
end

local ConfirmBidPricePopup = "AuctionHouseHelperConfirmBidPricePopupDialog"

StaticPopupDialogs[ConfirmBidPricePopup] = {
  text = AUCTION_HOUSE_HELPER_L_BID_EXISTING_ON_OWNED_AUCTION,
  button1 = ACCEPT,
  button2 = CANCEL,
  OnAccept = function(self)
    AuctionHouseHelper.AH.CancelAuction(self.data)
  end,
  hasMoneyFrame = 1,
  showAlert = 1,
  timeout = 0,
  exclusive = 1,
  hideOnEscape = 1
}

function AuctionHouseHelperCancellingFrameMixin:ReceiveEvent(eventName, ...)
  if eventName == AuctionHouseHelper.Cancelling.Events.RequestCancel then
    local auctionID = ...
    AuctionHouseHelper.Debug.Message("Executing cancel request", auctionID)

    local cancelCost = C_AuctionHouse.GetCancelCost(auctionID)
    if cancelCost > 0 then
      local dialog = StaticPopup_Show(ConfirmBidPricePopup)
      if dialog then
        dialog.data = auctionID
        MoneyFrame_Update(dialog.moneyFrame, cancelCost);
      end
    else
      AuctionHouseHelper.AH.CancelAuction(auctionID)
    end

    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)

  elseif eventName == AuctionHouseHelper.Cancelling.Events.TotalUpdated then
    local totalOnSale, totalPending = ...

    local text = AUCTION_HOUSE_HELPER_L_TOTAL_ON_SALE:format(
        GetMoneyString(totalOnSale, true)
      )
    if totalPending > 0 then
      text = text .. " " ..
      AUCTION_HOUSE_HELPER_L_TOTAL_PENDING:format(
        GetMoneyString(totalPending, true)
      )
    end

    self.Total:SetText(text)
  end
end
