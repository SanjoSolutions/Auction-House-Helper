local function SelectOwnItem(itemLocation)
  if not itemLocation:IsValid() or not C_AuctionHouse.IsSellItemValid(itemLocation) then
    return
  end

  -- Deselect any items in the "Sell" tab
  AuctionHouseFrame.ItemSellFrame:SetItem(nil, nil, false)
  AuctionHouseFrame.CommoditiesSellFrame:SetItem(nil, nil, false)

  AuctionHouseHelperTabs_Selling:Click()

  local itemInfo = AuctionHouseHelper.Utilities.ItemInfoFromLocation(itemLocation)
  itemInfo.count = C_AuctionHouse.GetAvailablePostCount(itemLocation)

  AuctionHouseHelper.EventBus
    :RegisterSource(SelectOwnItem, "ContainerFrameItemButton_OnModifiedClick hook")
    :Fire(SelectOwnItem, AuctionHouseHelper.Selling.Events.BagItemClicked, itemInfo)
    :UnregisterSource(SelectOwnItem)
end

local function AHShown()
  return AuctionHouseFrame and AuctionHouseFrame:IsShown()
end

hooksecurefunc(_G, "ContainerFrameItemButton_OnClick", function(self, button)
  if AHShown() and
      AuctionHouseHelper.Utilities.IsShortcutActive(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_BAG_SELECT_SHORTCUT), button) then
    local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetBagID(), self:GetID());
    SelectOwnItem(itemLocation)
  end
end)

hooksecurefunc(_G, "HandleModifiedItemClick", function(itemLink, itemLocation)
  if itemLocation ~= nil and AHShown() and
      AuctionHouseHelper.Utilities.IsShortcutActive(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_BAG_SELECT_SHORTCUT), GetMouseButtonClicked()) then
    SelectOwnItem(itemLocation)
  end
end)
