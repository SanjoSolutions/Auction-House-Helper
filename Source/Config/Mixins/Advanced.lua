AuctionHouseHelperConfigAdvancedFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigAdvancedFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigAdvancedFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_ADVANCED_CATEGORY
  self.parent = "Auction House Helper"

  self:SetupPanel()
end

function AuctionHouseHelperConfigAdvancedFrameMixin:OnShow()
  self.ReplicateScan:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.REPLICATE_SCAN))
  self.Debug:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.DEBUG))
end

function AuctionHouseHelperConfigAdvancedFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigAdvancedFrameMixin:Save()")

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.REPLICATE_SCAN, self.ReplicateScan:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.DEBUG, self.Debug:GetChecked())
end

function AuctionHouseHelperConfigAdvancedFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigAdvancedFrameMixin:Cancel()")
end
