AuctionHouseHelperMultisellProgress = {}

local MULTISELL_EVENTS = {
  "AUCTION_MULTISELL_START",
  "AUCTION_MULTISELL_UPDATE",
  "AUCTION_MULTISELL_FAILURE",
}

function AuctionHouseHelperMultisellProgress:SetDetails(icon, quantity)
  self.icon = icon
  self.quantity = quantity
end

function AuctionHouseHelperMultisellProgress:OnShow()
  FrameUtil.RegisterFrameForEvents(self, MULTISELL_EVENTS)
end

function AuctionHouseHelperMultisellProgress:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, MULTISELL_EVENTS)
  C_AuctionHouse.CancelSell()
  AuctionHouseMultisellProgressFrame:Hide()
end

function AuctionHouseHelperMultisellProgress:OnEvent(event, ...)
  if self.icon == nil or self.quantity == nil then
    AuctionHouseHelper.Debug.Message("Missing multisell item info")
    return
  end

  if event == "AUCTION_MULTISELL_START" then
    AuctionHouseMultisellProgressFrame:Start(self.icon, self.quantity)
    AuctionHouseMultisellProgressFrame:Show()
    AuctionHouseMultisellProgressFrame.ProgressBar:Show()

  elseif event == "AUCTION_MULTISELL_UPDATE" then
    local numPosted, total = ...
    AuctionHouseMultisellProgressFrame:Refresh(numPosted, total)

    if numPosted == total then
      AuctionHouseMultisellProgressFrame:Hide()
    end

  elseif event == "AUCTION_MULTISELL_FAILURE" then
    AuctionHouseMultisellProgressFrame:Hide()
  end
end
