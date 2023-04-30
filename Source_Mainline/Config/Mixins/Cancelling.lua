AuctionHouseHelperConfigCancellingFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigCancellingFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigCancellingFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_CANCELLING_CATEGORY
  self.parent = "Auction House Helper"

  self:SetupPanel()
end

function AuctionHouseHelperConfigCancellingFrameMixin:OnShow()
  self.UndercutScanPetsGear:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.UNDERCUT_SCAN_NOT_LIFO))
  self.UndercutScanMatchIlvlVariants:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.UNDERCUT_SCAN_GEAR_MATCH_ILVL_VARIANTS))
  self.CancelUndercutShortcut:SetShortcut(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CANCEL_UNDERCUT_SHORTCUT))
end

function AuctionHouseHelperConfigCancellingFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigCancellingFrameMixin:Save()")

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.UNDERCUT_SCAN_NOT_LIFO, self.UndercutScanPetsGear:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.UNDERCUT_SCAN_GEAR_MATCH_ILVL_VARIANTS, self.UndercutScanMatchIlvlVariants:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.CANCEL_UNDERCUT_SHORTCUT, self.CancelUndercutShortcut:GetShortcut())
end

function AuctionHouseHelperConfigCancellingFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigCancellingFrameMixin:Cancel()")
end
