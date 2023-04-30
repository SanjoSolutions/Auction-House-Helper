AuctionHouseHelperConfigQuantitiesFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigQuantitiesFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigQuantitiesFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_QUANTITIES_CATEGORY
  self.parent = "Auction House Helper"

  self:SetupPanel()

end

function AuctionHouseHelperConfigQuantitiesFrameMixin:OnShow()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigQuantitiesFrameMixin:OnShow()")

  local settings = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.DEFAULT_QUANTITIES)
  for _, quantityOption in ipairs(self.Quantities) do
    -- We use or 0 to permit adding more quantities later
    quantityOption:SetNumber(settings[quantityOption.classID] or 0)
  end
end

function AuctionHouseHelperConfigQuantitiesFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigQuantitiesFrameMixin:Save()")

  local settings = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.DEFAULT_QUANTITIES)
  for _, quantityOption in ipairs(self.Quantities) do
    settings[quantityOption.classID] = quantityOption:GetNumber()
  end
end

function AuctionHouseHelperConfigQuantitiesFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigQuantitiesFrameMixin:Cancel()")
end
