-- This mixin is used to work around that when the item key info for an item
-- isn't in the Blizzard cache the SendSellSearchQuery and SendSearchQuery APIs
-- will often ignore any search requests for that specific item.
--
-- There's 2 parts.
-- 1. The AttemptSearch function waits for the item to be in the cache before
-- doing a search request.
-- 2. The event listener looks for the right itemID/itemKey for the search
-- results, and verifies that a valid set of returns was returned, as sometimes no
-- results are returned when there are actually some results.
-- 3. If 2. failed, attempt to search again.
AuctionHouseHelperAHSearchScanFrameMixin = {}

local SEARCH_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "COMMODITY_SEARCH_RESULTS_UPDATED",
}

function AuctionHouseHelperAHSearchScanFrameMixin:OnLoad()
  AuctionHouseHelper.EventBus:RegisterSource(self, "AHSearchScanFrameMixin")
end

function AuctionHouseHelperAHSearchScanFrameMixin:OnHide()
  if self.searchFunc ~= nil then
    AuctionHouseHelper.AH.Queue:Remove(self.searchFunc)
    self.searchFunc = nil
  end
  self:SetScript("OnUpdate", nil)
  FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
end

function AuctionHouseHelperAHSearchScanFrameMixin:OnUpdate()
  self:AttemptSearch()
end

function AuctionHouseHelperAHSearchScanFrameMixin:OnEvent(eventName, ...)
  if eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" and self:ValidateItemInfo(...) then
    local itemID = ...
    local has = C_AuctionHouse.HasSearchResults(C_AuctionHouse.MakeItemKey(itemID))
    local full = C_AuctionHouse.HasFullCommoditySearchResults(itemID)
    local quantity = C_AuctionHouse.GetCommoditySearchResultsQuantity(itemID)

    -- Check for not having results OR supposedly having results when not all
    -- results are there and there are 0 loaded.
    if (not has) or (has and not full and quantity == 0) then
      self:AttemptSearch()
    else
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.CommoditySearchResultsReady, itemID)
      FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
    end
  elseif eventName == "ITEM_SEARCH_RESULTS_UPDATED" and self:ValidateItemInfo(...) then
    local itemKey = ...
    local has = C_AuctionHouse.HasSearchResults(itemKey)
    local full = C_AuctionHouse.HasFullItemSearchResults(itemKey)
    local quantity = C_AuctionHouse.GetItemSearchResultsQuantity(itemKey)

    -- Check for not having results OR supposedly having results when not all
    -- results are there and there are 0 loaded.
    if (not has) or (has and not full and quantity == 0) then
      self:AttemptSearch()
    else
      FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.ItemSearchResultsReady, itemKey)
    end
  end
end

-- itemKeyGenerator: Function that when called returns the item key intended for
-- the search. Parameter is useful when the item key depends on Blizzard caches
-- to retry getting the item key when the cache is ready.
-- rawSearch: Function with an item key as its only parameter to run the
-- Blizzard API search command
function AuctionHouseHelperAHSearchScanFrameMixin:SetSearch(itemKeyGenerator, rawSearch)
  if self.searchFunc ~= nil then
    AuctionHouseHelper.AH.Queue:Remove(self.searchFunc)
    self.searchFunc = nil
  end
  self.itemKeyGenerator = itemKeyGenerator
  self.rawSearch = rawSearch
  self:AttemptSearch()
end

function AuctionHouseHelperAHSearchScanFrameMixin:ValidateItemInfo(itemInfo)
  return (type(itemInfo) == "number" and self.itemKey.itemID == itemInfo) or
    (type(itemInfo) == "table" and AuctionHouseHelper.Utilities.ItemKeyString(itemInfo) == AuctionHouseHelper.Utilities.ItemKeyString(self.itemKey))
end

function AuctionHouseHelperAHSearchScanFrameMixin:AttemptSearch()
  if self.searchFunc ~= nil then
    AuctionHouseHelper.AH.Queue:Remove(self.searchFunc)
  end
  self.searchFunc = function()
    self.searchFunc = nil
    self.itemKey = self.itemKeyGenerator()
    if C_AuctionHouse.GetItemKeyInfo(self.itemKey) then
      FrameUtil.RegisterFrameForEvents(self, SEARCH_EVENTS)
      self:SetScript("OnUpdate", nil)
      self.rawSearch(self.itemKey)
    else
      self:SetScript("OnUpdate", self.OnUpdate)
    end
  end
  AuctionHouseHelper.AH.Queue:Enqueue(self.searchFunc)
end
