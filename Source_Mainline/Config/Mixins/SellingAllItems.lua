AuctionHouseHelperConfigSellingAllItemsFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingAllItemsFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_SELLING_ALL_ITEMS_CATEGORY
  self.parent = "Auction House Helper"

  self:SetupPanel()

  self.ItemSalesPreference:SetOnChange(function(selectedValue)
    self:OnSalesPreferenceChange(selectedValue)
  end)
end

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:OnShow()
  self.currentItemDuration = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUCTION_DURATION)
  self.currentItemSalesPreference = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUCTION_SALES_PREFERENCE)

  self.DurationGroup:SetSelectedValue(self.currentItemDuration)
  self.SaveLastDurationAsDefault:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SAVE_LAST_DURATION_AS_DEFAULT))
  self.ItemSalesPreference:SetSelectedValue(self.currentItemSalesPreference)

  self:OnSalesPreferenceChange(self.currentItemSalesPreference)

  self.ItemUndercutPercentage:SetNumber(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.UNDERCUT_PERCENTAGE))
  self.ItemUndercutValue:SetAmount(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.UNDERCUT_STATIC_VALUE))

  self.GearPriceMultiplier:SetNumber(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.GEAR_PRICE_MULTIPLIER))
  self.ItemMatching:SetSelectedValue(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_ITEM_MATCHING))
end

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:OnSalesPreferenceChange(selectedValue)
  self.currentItemSalesPreference = selectedValue

  if self.currentItemSalesPreference == AuctionHouseHelper.Config.SalesTypes.PERCENTAGE then
    self.ItemUndercutPercentage:Show()
    self.ItemUndercutValue:Hide()
  else
    self.ItemUndercutValue:Show()
    self.ItemUndercutPercentage:Hide()
  end
end

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingAllItemsFrameMixin:Save()")

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.AUCTION_DURATION, self.DurationGroup:GetValue())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SAVE_LAST_DURATION_AS_DEFAULT, self.SaveLastDurationAsDefault:GetChecked())

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.AUCTION_SALES_PREFERENCE, self.ItemSalesPreference:GetValue())
  AuctionHouseHelper.Config.Set(
    AuctionHouseHelper.Config.Options.UNDERCUT_PERCENTAGE,
    AuctionHouseHelper.Utilities.ValidatePercentage(self.ItemUndercutPercentage:GetNumber())
  )
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.UNDERCUT_STATIC_VALUE, tonumber(self.ItemUndercutValue:GetAmount()))

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.GEAR_PRICE_MULTIPLIER, self.GearPriceMultiplier:GetNumber())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_ITEM_MATCHING, self.ItemMatching:GetValue())
end

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingAllItemsFrameMixin:Cancel()")
end
