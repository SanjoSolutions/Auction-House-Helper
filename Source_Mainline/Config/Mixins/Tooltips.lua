AuctionHouseHelperConfigTooltipsFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigTooltipsFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigTooltipsFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_TOOLTIPS_CATEGORY
  self.parent = "Auction House Helper"

  self:SetupPanel()
end

function AuctionHouseHelperConfigTooltipsFrameMixin:OnShow()
  self.MailboxTooltips:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.MAILBOX_TOOLTIPS))
  self.PetTooltips:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.PET_TOOLTIPS))
  self.VendorTooltips:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.VENDOR_TOOLTIPS))
  self.AuctionTooltips:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUCTION_TOOLTIPS))
  self.EnchantTooltips:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.ENCHANT_TOOLTIPS))
  self.ShiftStackTooltips:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SHIFT_STACK_TOOLTIPS))
end

function AuctionHouseHelperConfigTooltipsFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigTooltipsFrameMixin:Save()")

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.MAILBOX_TOOLTIPS, self.MailboxTooltips:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.PET_TOOLTIPS, self.PetTooltips:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.VENDOR_TOOLTIPS, self.VendorTooltips:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.AUCTION_TOOLTIPS, self.AuctionTooltips:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.ENCHANT_TOOLTIPS, self.EnchantTooltips:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SHIFT_STACK_TOOLTIPS, self.ShiftStackTooltips:GetChecked())
end

function AuctionHouseHelperConfigTooltipsFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigTooltipsFrameMixin:Cancel()")
end
