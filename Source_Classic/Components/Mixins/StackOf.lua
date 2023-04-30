AuctionHouseHelperStackOfInputMixin = CreateFromMixins(AuctionHouseHelperConfigTooltipMixin)

function AuctionHouseHelperStackOfInputMixin:OnLoad()
  self.maxStackSize = 0
  self.maxNumStacks = 0
end

function AuctionHouseHelperStackOfInputMixin:SetMaxNumStacks(max)
  self.maxNumStacks = max
end

function AuctionHouseHelperStackOfInputMixin:GetConfig()
  return {
    numStacks = self.NumStacks:GetNumber(),
    stackSize = self.StackSize:GetNumber(),
  }
end

function AuctionHouseHelperStackOfInputMixin:SetConfig(config)
  self.NumStacks:SetNumber(config.numStacks)
  self.StackSize:SetNumber(config.stackSize)
end

function AuctionHouseHelperStackOfInputMixin:SetMaxStackSize(max)
  self.maxStackSize = max
  self.MaxStackSize:SetText(AUCTION_HOUSE_HELPER_L_MAX_COLON_X:format(max))
end

function AuctionHouseHelperStackOfInputMixin:SetMaxNumStacks(max)
  self.maxNumStacks = max
  self.MaxNumStacks:SetText(AUCTION_HOUSE_HELPER_L_MAX_COLON_X:format(max))
end

function AuctionHouseHelperStackOfInputMixin:MaxNumStacksClicked()
  self.NumStacks:SetNumber(self.maxNumStacks)
end

function AuctionHouseHelperStackOfInputMixin:MaxStackSizeClicked()
  self.StackSize:SetNumber(self.maxStackSize)
end
