StaticPopupDialogs[AuctionHouseHelper.Constants.DialogNames.SellingConfirmPost] = {
  text = "",
  button1 = ACCEPT,
  button2 = CANCEL,
  OnShow = function(self)
    AuctionHouseHelper.EventBus:RegisterSource(self, "Selling Confirm Post Low Price Dialog")
  end,
  OnHide = function(self)
    AuctionHouseHelper.EventBus:UnregisterSource(self)
  end,
  OnAccept = function(self)
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Selling.Events.ConfirmPost)
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}

StaticPopupDialogs[AuctionHouseHelper.Constants.DialogNames.SellingConfirmUnhideAll] = {
  text = AUCTION_HOUSE_HELPER_L_CONFIRM_UNHIDE_ALL,
  button1 = ACCEPT,
  button2 = CANCEL,
  OnShow = function(self)
    AuctionHouseHelper.EventBus:RegisterSource(self, "Selling Confirm Unhide All Dialog")
  end,
  OnHide = function(self)
    AuctionHouseHelper.EventBus:UnregisterSource(self)
  end,
  OnAccept = function(self)
    AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS, {})
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Selling.Events.BagRefresh)
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}
