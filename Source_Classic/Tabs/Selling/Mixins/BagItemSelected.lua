AuctionHouseHelperBagItemSelectedMixin = CreateFromMixins(AuctionHouseHelperBagItemMixin)

local seenBag, seenSlot

function AuctionHouseHelperBagItemSelectedMixin:OnClick(button)
  local wasCursorItem = C_Cursor.GetCursorItem()
  if not self:ProcessCursor() then
    if button == "LeftButton" and not wasCursorItem and self.itemInfo ~= nil then
      self:SearchInShoppingTab()
    else
      AuctionHouseHelperBagItemMixin.OnClick(self, button)
    end
  end
end

function AuctionHouseHelperBagItemSelectedMixin:SearchInShoppingTab()
  local item = Item:CreateFromItemLink(self.itemInfo.itemLink)
  item:ContinueOnItemLoad(function()
    AuctionHouseHelper.API.v1.MultiSearchExact(AUCTION_HOUSE_HELPER_L_SELLING_TAB, { item:GetItemName() })
  end)
end

function AuctionHouseHelperBagItemSelectedMixin:OnReceiveDrag()
  self:ProcessCursor()
end

function AuctionHouseHelperBagItemSelectedMixin:ProcessCursor()
  local location = C_Cursor.GetCursorItem()
  ClearCursor()

  if not location then
    AuctionHouseHelper.Debug.Message("nothing on cursor")
    return false
  end

  -- Case when picking up a key from your keyring, WoW doesn't always give a
  -- valid item location for the cursor, causing an error unless we either:
  --  1. Ignore it
  --  2. Replace the location with one that is valid based on a hook on bag
  --  clicks.
  -- We use 2.
  if not location:HasAnyLocation() then
    AuctionHouseHelper.Debug.Message("AuctionHouseHelperBagItemSelected", "recovering")
    location = ItemLocation:CreateFromBagAndSlot(seenBag, seenSlot)
  end

  if not C_Item.DoesItemExist(location) then
    AuctionHouseHelper.Debug.Message("AuctionHouseHelperBagItemSelected", "not exists")
    return false
  end

  local itemInfo = AuctionHouseHelper.Utilities.ItemInfoFromLocation(location)
  itemInfo.count = AuctionHouseHelper.Selling.GetItemCount(location)

  if not AuctionHouseHelper.EventBus:IsSourceRegistered(self) then
    AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperBagItemSelectedMixin")
  end

  if itemInfo.auctionable then
    AuctionHouseHelper.Debug.Message("AuctionHouseHelperBagItemSelected", "auctionable")
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Selling.Events.BagItemClicked, itemInfo)
    return true
  end

  AuctionHouseHelper.Debug.Message("AuctionHouseHelperBagItemSelected", "err")
  UIErrorsFrame:AddMessage(ERR_AUCTION_BOUND_ITEM, 1.0, 0.1, 0.1, 1.0)
  return false
end

local function HookForPickup(bag, slot)
  seenBag = bag
  seenSlot = slot
end

-- Record clicks on bag items so that we can make keyring items being picked up
-- and placed in the Selling tab work.
if C_Container and C_Container.PickupContainerItem then
  hooksecurefunc(C_Container, "PickupContainerItem", HookForPickup)
else
  hooksecurefunc("PickupContainerItem", HookForPickup)
end
