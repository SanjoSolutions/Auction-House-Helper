AuctionHouseHelperConfigShoppingAltFrameMixin = CreateFromMixins(AuctionHouseHelperConfigShoppingFrameMixin)

function AuctionHouseHelperConfigShoppingAltFrameMixin:OnShow()
  AuctionHouseHelperConfigShoppingFrameMixin.OnShow(self)

  self.AlwaysLoadMore:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SHOPPING_ALWAYS_LOAD_MORE))
end

function AuctionHouseHelperConfigShoppingAltFrameMixin:Save()
  AuctionHouseHelperConfigShoppingFrameMixin.Save(self)

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SHOPPING_ALWAYS_LOAD_MORE, self.AlwaysLoadMore:GetChecked())
end
