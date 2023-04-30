AuctionHouseHelperConfigSellingFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigSellingFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_SELLING_CATEGORY
  self.parent = "Auction House Helper"

  self:SetupPanel()
end

function AuctionHouseHelperConfigSellingFrameMixin:OnShow()
  self.AuctionChatLog:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUCTION_CHAT_LOG))
  self.ShowBidPrice:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SHOW_SELLING_BID_PRICE))
  self.BagCollapsed:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_BAG_COLLAPSED))
  self.ConfirmPostLowPrice:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_CONFIRM_LOW_PRICE))
  self.AlwaysLoadMore:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_ALWAYS_LOAD_MORE))
  self.GreyPostButton:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_GREY_POST_BUTTON))

  self.BagShown:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SHOW_SELLING_BAG))
  self.IconSize:SetNumber(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_ICON_SIZE))
  self.AutoSelectNext:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_AUTO_SELECT_NEXT))
  self.AutoSelectStackRemainder:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_POST_STACK_REMAINDER))
  self.MissingFavourites:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_MISSING_FAVOURITES))

  self.UnhideAll:SetEnabled(#(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS)) ~= 0)
end

function AuctionHouseHelperConfigSellingFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingFrameMixin:Save()")

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.AUCTION_CHAT_LOG, self.AuctionChatLog:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SHOW_SELLING_BID_PRICE, self.ShowBidPrice:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_BAG_COLLAPSED, self.BagCollapsed:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_CONFIRM_LOW_PRICE, self.ConfirmPostLowPrice:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_ALWAYS_LOAD_MORE, self.AlwaysLoadMore:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_GREY_POST_BUTTON, self.GreyPostButton:GetChecked())

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SHOW_SELLING_BAG, self.BagShown:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_ICON_SIZE, math.min(50, math.max(10, self.IconSize:GetNumber())))
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_AUTO_SELECT_NEXT, self.AutoSelectNext:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_POST_STACK_REMAINDER, self.AutoSelectStackRemainder:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_MISSING_FAVOURITES, self.MissingFavourites:GetChecked())
end

function AuctionHouseHelperConfigSellingFrameMixin:UnhideAllClicked()
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS, {})
  self.UnhideAll:Disable()
end

function AuctionHouseHelperConfigSellingFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingFrameMixin:Cancel()")
end
