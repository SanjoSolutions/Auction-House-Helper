AuctionHouseHelperShoppingItemMixin = CreateFromMixins(AuctionHouseHelperEscapeToCloseMixin)

local NO_QUALITY = ""

local function InitializeQualityDropDown(dropDown)
  local qualityStrings = {}
  local qualityIDs = {}

  table.insert(qualityStrings, AUCTION_HOUSE_HELPER_L_ANY_UPPER)
  table.insert(qualityIDs, NO_QUALITY)

  for _, quality in ipairs(AuctionHouseHelper.Constants.QualityIDs) do
    table.insert(qualityStrings, AuctionHouseHelper.Utilities.CreateColoredQuality(quality))
    table.insert(qualityIDs, tostring(quality))
  end

  dropDown:InitAgain(qualityStrings, qualityIDs)
end

local function InitializeTierDropDown(dropDown)
  local tierStrings = {}
  local tierIDs = {}

  table.insert(tierStrings, AUCTION_HOUSE_HELPER_L_ANY_UPPER)
  table.insert(tierIDs, NO_QUALITY)

  if not AuctionHouseHelper.Constants.IsClassic then
    for tier = 1, 3 do
      table.insert(tierStrings, C_Texture.GetCraftingReagentQualityChatIcon(tier))
      table.insert(tierIDs, tostring(tier))
    end
  end

  dropDown:InitAgain(tierStrings, tierIDs)
end

local function InitializeExpansionDropDown(dropDown)
  local expansionStrings = {}
  local expansionIDs = {}

  table.insert(expansionStrings, AUCTION_HOUSE_HELPER_L_ANY_UPPER)
  table.insert(expansionIDs, NO_QUALITY)

  for i = 0, LE_EXPANSION_LEVEL_CURRENT do
    local name = _G["EXPANSION_NAME" .. i]

    table.insert(expansionStrings, name)
    table.insert(expansionIDs, tostring(i))
  end

  dropDown:InitAgain(expansionStrings, expansionIDs)
end

function AuctionHouseHelperShoppingItemMixin:OnLoad()
  self.onFinishedClicked = function() end

  self.SearchContainer.ResetSearchStringButton:SetClickCallback(function()
    self.SearchContainer.SearchString:SetText("")
  end)

  self.QualityContainer.ResetQualityButton:SetClickCallback(function()
    self.QualityContainer.DropDown:SetValue(NO_QUALITY)
  end)

  self.TierContainer.ResetTierButton:SetClickCallback(function()
    self.TierContainer.DropDown:SetValue(NO_QUALITY)
  end)

  self.ExpansionContainer.ResetExpansionButton:SetClickCallback(function()
    self.ExpansionContainer.DropDown:SetValue(NO_QUALITY)
  end)

  local onEnterCallback = function()
    self:OnFinishedClicked()
  end

  self.LevelRange:SetCallbacks({
    OnEnter = onEnterCallback,
    OnTab = function()
      self.ItemLevelRange:SetFocus()
    end
  })

  self.ItemLevelRange:SetCallbacks({
    OnEnter = onEnterCallback,
    OnTab = function()
      self.PriceRange:SetFocus()
    end
  })

  self.PriceRange:SetCallbacks({
    OnEnter = onEnterCallback,
    OnTab = function()
      self.CraftedLevelRange:SetFocus()
    end
  })

  self.CraftedLevelRange:SetCallbacks({
    OnEnter = onEnterCallback,
    OnTab = function()
      self.SearchContainer.SearchString:SetFocus()
    end
  })

  InitializeExpansionDropDown(self.ExpansionContainer.DropDown)
  InitializeQualityDropDown(self.QualityContainer.DropDown)
  InitializeTierDropDown(self.TierContainer.DropDown)

  if not AuctionHouseHelper.Constants.IsClassic then
    self:SetHeight(420)
    self.TierContainer:Show()
    self.ExpansionContainer:Show()
  else
    self:SetHeight(340)
    self.TierContainer:Hide()
    self.ExpansionContainer:Hide()
  end

  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded
  })
end

function AuctionHouseHelperShoppingItemMixin:Init(title, finishedButtonText)
  self.DialogTitle:SetText(title)
  self.Finished:SetText(finishedButtonText)
  DynamicResizeButton_Resize(self.Finished)
end

function AuctionHouseHelperShoppingItemMixin:OnShow()
  self:ResetAll()
  self.SearchContainer.SearchString:SetFocus()

  AuctionHouseHelper.EventBus
    :RegisterSource(self, "add item dialog")
    :Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionHouseHelperShoppingItemMixin:OnHide()
  self:Hide()

  AuctionHouseHelper.EventBus
    :RegisterSource(self, "add item dialog")
    :Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionHouseHelperShoppingItemMixin:OnCancelClicked()
  self:Hide()
end

function AuctionHouseHelperShoppingItemMixin:SetOnFinishedClicked(callback)
  self.onFinishedClicked = callback
end

function AuctionHouseHelperShoppingItemMixin:OnFinishedClicked()
  if not self.Finished:IsEnabled() then
    return
  end

  self:Hide()

  if self:HasItemInfo() then
    self.onFinishedClicked(self:GetItemString())
  else
    AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_NO_ITEM_INFO_SPECIFIED)
  end
end

function AuctionHouseHelperShoppingItemMixin:HasItemInfo()
  return
    self:GetItemString()
      :gsub(AuctionHouseHelper.Constants.AdvancedSearchDivider, "")
      :gsub("\"", "")
      :len() > 0
end

function AuctionHouseHelperShoppingItemMixin:GetItemString()
  local search = {
    searchString = self.SearchContainer.SearchString:GetText(),
    isExact = self.SearchContainer.IsExact:GetChecked(),
    categoryKey = self.FilterKeySelector:GetValue(),
    minLevel = self.LevelRange:GetMin(),
    maxLevel = self.LevelRange:GetMax(),
    minItemLevel = self.ItemLevelRange:GetMin(),
    maxItemLevel = self.ItemLevelRange:GetMax(),
    minCraftedLevel = self.CraftedLevelRange:GetMin(),
    maxCraftedLevel = self.CraftedLevelRange:GetMax(),
    minPrice = self.PriceRange:GetMin() * 10000,
    maxPrice = self.PriceRange:GetMax() * 10000,
    expansion = tonumber(self.ExpansionContainer.DropDown:GetValue()),
    quality = tonumber(self.QualityContainer.DropDown:GetValue()),
    tier = tonumber(self.TierContainer.DropDown:GetValue()),
  }
  
  return AuctionHouseHelper.Search.ReconstituteAdvancedSearch(search)
end

function AuctionHouseHelperShoppingItemMixin:SetItemString(itemString)
  local search = AuctionHouseHelper.Search.SplitAdvancedSearch(itemString)

  self.SearchContainer.IsExact:SetChecked(search.isExact)
  self.SearchContainer.SearchString:SetText(search.searchString)

  self.FilterKeySelector:SetValue(search.categoryKey)

  self.ItemLevelRange:SetMin(search.minItemLevel)
  self.ItemLevelRange:SetMax(search.maxItemLevel)

  self.LevelRange:SetMin(search.minLevel)
  self.LevelRange:SetMax(search.maxLevel)

  self.CraftedLevelRange:SetMin(search.minCraftedLevel)
  self.CraftedLevelRange:SetMax(search.maxCraftedLevel)

  if search.minPrice ~= nil then
    self.PriceRange:SetMin(search.minPrice/10000)
  else
    self.PriceRange:SetMin(nil)
  end

  if search.maxPrice ~= nil then
    self.PriceRange:SetMax(search.maxPrice/10000)
  else
    self.PriceRange:SetMax(nil)
  end

  if search.quality == nil then
    self.QualityContainer.DropDown:SetValue(NO_QUALITY)
  else
    self.QualityContainer.DropDown:SetValue(tostring(search.quality))
  end

  if AuctionHouseHelper.Constants.IsClassic or search.tier == nil then
    self.TierContainer.DropDown:SetValue(NO_QUALITY)
  else
    self.TierContainer.DropDown:SetValue(tostring(search.tier))
  end

  if AuctionHouseHelper.Constants.IsClassic or search.expansion == nil then
    self.ExpansionContainer.DropDown:SetValue(NO_QUALITY)
  else
    self.ExpansionContainer.DropDown:SetValue(tostring(search.expansion))
  end
end

function AuctionHouseHelperShoppingItemMixin:ResetAll()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperShoppingItemMixin:ResetAll()")

  self.SearchContainer.SearchString:SetText("")
  self.SearchContainer.IsExact:SetChecked(false)

  self.FilterKeySelector:Reset()

  self.ItemLevelRange:Reset()
  self.LevelRange:Reset()
  self.PriceRange:Reset()
  self.CraftedLevelRange:Reset()
end

function AuctionHouseHelperShoppingItemMixin:ReceiveEvent(eventName)
  if eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted then
    self.Finished:Disable()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded then
    self.Finished:Enable()
  end
end
