AuctionHouseHelperConfigShoppingFrameMixin = CreateFromMixins(AuctionHouseHelperPanelConfigMixin)

function AuctionHouseHelperConfigShoppingFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigShoppingFrameMixin:OnLoad()")

  self.name = AUCTION_HOUSE_HELPER_L_CONFIG_SHOPPING_CATEGORY
  self.parent = "Auction House Helper"

  self:SetupPanel()
end

local function GetShoppingListNames()
  local names = {AUCTION_HOUSE_HELPER_L_NONE}
  local values = {AuctionHouseHelper.Constants.NO_LIST}

  if AuctionHouseHelper.Shopping.ListManager == nil then
    return names, values
  end

  for index = 1, AuctionHouseHelper.Shopping.ListManager:GetCount() do
    local list = AuctionHouseHelper.Shopping.ListManager:GetByIndex(index)
    table.insert(names, list:GetName())
    table.insert(values, list:GetName())
  end
  return names, values
end

function AuctionHouseHelperConfigShoppingFrameMixin:OnShow()
  self.AutoListSearch:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUTO_LIST_SEARCH))

  self.DefaultShoppingList:InitAgain(GetShoppingListNames())

  local currentDefault = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.DEFAULT_LIST)
  if AuctionHouseHelper.Shopping.ListManager and AuctionHouseHelper.Shopping.ListManager:GetIndexForName(currentDefault) == nil then
    currentDefault = ""
  end

  self.DefaultShoppingList:SetValue(currentDefault)

  self.ListMissingTerms:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SHOPPING_LIST_MISSING_TERMS))
end

function AuctionHouseHelperConfigShoppingFrameMixin:Save()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigShoppingFrameMixin:Save()")

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.AUTO_LIST_SEARCH, self.AutoListSearch:GetChecked())

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.DEFAULT_LIST, self.DefaultShoppingList:GetValue())

  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SHOPPING_LIST_MISSING_TERMS, self.ListMissingTerms:GetChecked())
end

function AuctionHouseHelperConfigShoppingFrameMixin:Cancel()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigShoppingFrameMixin:Cancel()")
end
