AuctionHouseHelperConfigSellingShortcutsFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigSellingShortcutsFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingShortcutsFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_SELLING_SHORTCUTS_CATEGORY
  self.parent = "Auction House Helper"

  self:SetupPanel()
end

function AuctionHouseHelperConfigSellingShortcutsFrameMixin:OnShow()
  self.BagSelectShortcut:SetValue(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_BAG_SELECT_SHORTCUT))

  self.PostShortcut:SetShortcut(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_POST_SHORTCUT))
  self.SkipShortcut:SetShortcut(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_SKIP_SHORTCUT))
end

function AuctionHouseHelperConfigSellingShortcutsFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingShortcutsFrameMixin:Save()")

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_BAG_SELECT_SHORTCUT, self.BagSelectShortcut:GetValue())

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_POST_SHORTCUT, self.PostShortcut:GetShortcut())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_SKIP_SHORTCUT, self.SkipShortcut:GetShortcut())
end

function AuctionHouseHelperConfigSellingShortcutsFrameMixin:UnhideAllClicked()
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS, {})
  self.UnhideAll:Disable()
end

function AuctionHouseHelperConfigSellingShortcutsFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingShortcutsFrameMixin:Cancel()")
end
