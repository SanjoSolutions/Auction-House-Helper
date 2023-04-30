AuctionHouseHelperConfigProfileFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigProfileFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigProfileFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_PROFILE_CATEGORY
  self.parent = "Auction House Helper"

  self:SetupPanel()
end

function AuctionHouseHelperConfigProfileFrameMixin:OnShow()
  self.ProfileToggle:SetChecked(AuctionHouseHelper.Config.IsCharacterConfig())
end

function AuctionHouseHelperConfigProfileFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigProfileFrameMixin:Save()")

  AuctionHouseHelper.Config.SetCharacterConfig(self.ProfileToggle:GetChecked())
end

function AuctionHouseHelperConfigProfileFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigProfileFrameMixin:Cancel()")
end
