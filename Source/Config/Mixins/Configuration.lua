AuctionHouseHelperConfigFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigFrameMixin:OnLoad()")

  self.name = "Auction House Helper"
  self:SetParent(SettingsPanel or InterfaceOptionsFrame)

  self:SetupPanel()
end

function AuctionHouseHelperConfigFrameMixin:Show()
  if InterfaceOptionsFrame then
    InterfaceOptionsFrame_OpenToCategory(AuctionHouseHelperConfigBasicOptionsFrame)
  end
  -- For some reason OnShow doesn't fire?
  AuctionHouseHelperConfigBasicOptionsFrame:OnShow()
end

function AuctionHouseHelperConfigFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigFrameMixin:Save()")
end

function AuctionHouseHelperConfigFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigFrameMixin:Cancel()")
end
