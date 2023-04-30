local BAG_TABLE_LAYOUT = { }
local BAG_EVENTS = {
  "BAG_UPDATE",
}
local BAG_AUCTION_HOUSE_HELPER_EVENTS = {
  AuctionHouseHelper.Selling.Events.BagRefresh,
}

AuctionHouseHelperBagDataProviderMixin = CreateFromMixins(AuctionHouseHelperDataProviderMixin)

function AuctionHouseHelperBagDataProviderMixin:Reload()
  self:Reset()
  self:LoadBagData()

  --Reload once more, as in some cases a full scan running/having run will cause
  --the initial load to miss items and some information
  C_Timer.After(0.01, function()
    self:Reset()
    self:LoadBagData()
  end)
end

function AuctionHouseHelperBagDataProviderMixin:ReceiveEvent(event)
  if event == AuctionHouseHelper.Selling.Events.BagRefresh then
    self:Reload()
  end
end

function AuctionHouseHelperBagDataProviderMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, BAG_EVENTS)
  AuctionHouseHelper.EventBus:Register(self, BAG_AUCTION_HOUSE_HELPER_EVENTS)

  self:Reload()
end

function AuctionHouseHelperBagDataProviderMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, BAG_EVENTS)
  AuctionHouseHelper.EventBus:Unregister(self, BAG_AUCTION_HOUSE_HELPER_EVENTS)
end

local function IsIgnoredItemKey(keyString)
  return tIndexOf(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS), keyString) ~= nil
end

function AuctionHouseHelperBagDataProviderMixin:LoadBagData()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperBagDataProviderMixin:LoadBagData()")

  local itemMap = {}
  local orderedKeys = {}
  local results = {}
  local index = 0

  local function NumSlots(bagID)
    if C_Container and C_Container.GetContainerNumSlots then
      return C_Container.GetContainerNumSlots(bagID)
    else
      return GetContainerNumSlots(bagID)
    end
  end

  for _, bagId in ipairs(AuctionHouseHelper.Constants.BagIDs) do
    for slot = 1, NumSlots(bagId) do
      index = index + 1

      local location = ItemLocation:CreateFromBagAndSlot(bagId, slot)
      if C_Item.DoesItemExist(location) then
        local itemInfo = AuctionHouseHelper.Utilities.ItemInfoFromLocation(location)
        local tempId = self:UniqueKey(itemInfo)

        if not IsIgnoredItemKey(tempId) and itemInfo.bagListing then

          if itemMap[tempId] == nil then
            table.insert(orderedKeys, tempId)
            itemMap[tempId] = itemInfo
          else
            itemMap[tempId].count = itemMap[tempId].count + itemInfo.count
          end
        end
      end
    end
  end

  orderedKeys = AuctionHouseHelper.Utilities.ReverseArray(orderedKeys)

  for key, item in pairs(itemMap) do
    table.insert(results, item)
  end

  table.sort(results, function(left, right)
    return AuctionHouseHelper.Selling.UniqueBagKey(left) < AuctionHouseHelper.Selling.UniqueBagKey(right)
  end)

  self:AppendEntries(results, true)
end

function AuctionHouseHelperBagDataProviderMixin:OnEvent(...)
  self:Reload()
end

function AuctionHouseHelperBagDataProviderMixin:UniqueKey(entry)
  return AuctionHouseHelper.Selling.UniqueBagKey(entry)
end

function AuctionHouseHelperBagDataProviderMixin:GetTableLayout()
  return BAG_TABLE_LAYOUT
end

function AuctionHouseHelperBagDataProviderMixin:GetRowTemplate()
  return "AuctionHouseHelperBagListResultsRowTemplate"
end

local COMPARATORS = {
  name = AuctionHouseHelper.Utilities.StringComparator,
  class = AuctionHouseHelper.Utilities.NumberComparator,
  count = AuctionHouseHelper.Utilities.NumberComparator
}

function AuctionHouseHelperBagDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end
