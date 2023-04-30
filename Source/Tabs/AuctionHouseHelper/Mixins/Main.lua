AuctionHouseHelperConfigTabMixin = {}

function AuctionHouseHelperConfigTabMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigTabMixin:OnLoad()")

  if AuctionHouseHelper.Constants.IsClassic then
    -- Reposition lower down translator entries so that they don't go past the
    -- bottom of the tab
    self.frFR:SetPoint("TOPLEFT", self.deDE, "TOPLEFT", 300, 0)
  end
end

function AuctionHouseHelperConfigTabMixin:OpenOptions()
  if InterfaceOptionsFrame ~= nil then
    InterfaceOptionsFrame:Show()
    InterfaceOptionsFrame_OpenToCategory(AUCTION_HOUSE_HELPER_L_CONFIG_BASIC_OPTIONS_CATEGORY)
  else -- Dragonflight
    Settings.OpenToCategory(AUCTION_HOUSE_HELPER_L_AUCTION_HOUSE_HELPER)
  end
end
