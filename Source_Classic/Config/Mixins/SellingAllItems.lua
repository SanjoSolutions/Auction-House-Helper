AuctionHouseHelperConfigSellingAllItemsFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingAllItemsFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_SELLING_ALL_ITEMS_CATEGORY
  self.parent = "Auction House Helper"
  self.beenShown = false

  self:SetupPanel()

  self.SalesPreference:SetOnChange(function(selectedValue)
    self:OnSalesPreferenceChange(selectedValue)
  end)
end

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:OnShow()
  self.beenShown = true
  self.currentUndercutPreference = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUCTION_SALES_PREFERENCE)

  self.DurationGroup:SetSelectedValue(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUCTION_DURATION))
  self.SaveLastDurationAsDefault:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SAVE_LAST_DURATION_AS_DEFAULT))
  self.SalesPreference:SetSelectedValue(self.currentUndercutPreference)

  self:OnSalesPreferenceChange(self.currentUndercutPreference)

  self.UndercutPercentage:SetNumber(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.UNDERCUT_PERCENTAGE))
  self.UndercutValue:SetAmount(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.UNDERCUT_STATIC_VALUE))

  self.GearPriceMultiplier:SetNumber(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.GEAR_PRICE_MULTIPLIER))

  self.StartingPricePercentage:SetNumber(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.STARTING_PRICE_PERCENTAGE))

  local defaultStacks = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.DEFAULT_SELLING_STACKS)
  self.DefaultStacks.StackSize:SetNumber(defaultStacks.stackSize)
  self.DefaultStacks.NumStacks:SetNumber(defaultStacks.numStacks)
  self.DefaultStacks.StackSize:Show()
  self.DefaultStacks.NumStacks:Show()
  self.DefaultStacks:SetMaxStackSize(0)
  self.DefaultStacks:SetMaxNumStacks(0)

  self.ResetStackSizeMemory:SetEnabled(next(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.STACK_SIZE_MEMORY)) ~= nil)
end

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:OnSalesPreferenceChange(selectedValue)
  self.currentUndercutPreference = selectedValue

  if self.currentUndercutPreference == AuctionHouseHelper.Config.SalesTypes.PERCENTAGE then
    self.UndercutPercentage:Show()
    self.UndercutValue:Hide()
  else
    self.UndercutValue:Show()
    self.UndercutPercentage:Hide()
  end
end

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:Save()
  if not self.beenShown then
    return
  end

  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingAllItemsFrameMixin:Save()")

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.AUCTION_DURATION, self.DurationGroup:GetValue())
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SAVE_LAST_DURATION_AS_DEFAULT, self.SaveLastDurationAsDefault:GetChecked())

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.AUCTION_SALES_PREFERENCE, self.SalesPreference:GetValue())
  AuctionHouseHelper.Config.Set(
    AuctionHouseHelper.Config.Options.UNDERCUT_PERCENTAGE,
    AuctionHouseHelper.Utilities.ValidatePercentage(self.UndercutPercentage:GetNumber())
  )
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.UNDERCUT_STATIC_VALUE, self.UndercutValue:GetAmount())

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.GEAR_PRICE_MULTIPLIER, self.GearPriceMultiplier:GetNumber())

  local newPercentage = AuctionHouseHelper.Utilities.ValidatePercentage(self.StartingPricePercentage:GetNumber())
  if newPercentage > 0 then
    AuctionHouseHelper.Config.Set(
      AuctionHouseHelper.Config.Options.STARTING_PRICE_PERCENTAGE,
      newPercentage
    )
  end

  local defaultStacks = {
    stackSize = self.DefaultStacks.StackSize:GetNumber(),
    numStacks = self.DefaultStacks.NumStacks:GetNumber()
  }
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.DEFAULT_SELLING_STACKS, defaultStacks)
end

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:ResetStackSizeMemoryClicked()
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.STACK_SIZE_MEMORY, {})
  self.ResetStackSizeMemory:Disable()
end

function AuctionHouseHelperConfigSellingAllItemsFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigSellingAllItemsFrameMixin:Cancel()")
end
