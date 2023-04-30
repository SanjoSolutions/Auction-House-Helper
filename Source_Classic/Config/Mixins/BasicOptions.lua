AuctionHouseHelperConfigBasicOptionsFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigBasicOptionsFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigBasicOptionsFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_BASIC_OPTIONS_CATEGORY
  self.parent = "Auction House Helper"

  self:SetupPanel()
end

function AuctionHouseHelperConfigBasicOptionsFrameMixin:OnShow()
  self.DefaultTab:SetValue(tostring(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.DEFAULT_TAB)))
  self.ShowCraftingInfo:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW))
  self.ShowCraftingCost:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW_COST))
  self.ShowCraftingProfit:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW_PROFIT))
end

function AuctionHouseHelperConfigBasicOptionsFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigBasicOptionsFrameMixin:Save()")

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.DEFAULT_TAB, tonumber(self.DefaultTab:GetValue()))
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW, self.ShowCraftingInfo:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW_COST, self.ShowCraftingCost:GetChecked())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW_PROFIT, self.ShowCraftingProfit:GetChecked())
end

function AuctionHouseHelperConfigBasicOptionsFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigBasicOptionsFrameMixin:Cancel()")
end
