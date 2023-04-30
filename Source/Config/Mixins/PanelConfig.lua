AuctionHouseHelperPanelConfigMixin = {}

function AuctionHouseHelperPanelConfigMixin:SetupPanel()
  self.cancel = function()
    self:Cancel()
  end

  self.okay = function()
    self:Save()
  end

  InterfaceOptions_AddCategory(self, "AuctionHouseHelper")
end

-- Derive
function AuctionHouseHelperPanelConfigMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperPanelConfigMixin:Cancel() Unimplemented")
end

-- Derive
function AuctionHouseHelperPanelConfigMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperPanelConfigMixin:Save() Unimplemented")
end
