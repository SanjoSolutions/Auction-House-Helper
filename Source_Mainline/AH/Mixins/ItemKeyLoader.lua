AuctionHouseHelperAHItemKeyLoaderFrameMixin = {}

local ITEM_KEY_INFO_EVENTS = {
  "ITEM_KEY_ITEM_INFO_RECEIVED"
}

function AuctionHouseHelperAHItemKeyLoaderFrameMixin:OnLoad()
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperItemKeyLoadingMixin")
  self.waiting = {}
  self.cache = {}
  self.callbackMap = {}
  self.waitingCount = 0
  self.registered = false
end

function AuctionHouseHelperAHItemKeyLoaderFrameMixin:Get(itemKey, callback)
  local itemKeyString = AuctionHouseHelper.Utilities.ItemKeyString(itemKey)

  local info = self.cache[itemKeyString]
  if info then
    callback(info, true)
    return
  end

  if self.callbackMap[itemKeyString] == nil then
    self.callbackMap[itemKeyString] = {}
  end
  if callback ~= nil then
    table.insert(self.callbackMap[itemKeyString], callback)
  end

  info = C_AuctionHouse.GetItemKeyInfo(itemKey)
  if info then
    self.cache[itemKeyString] = info
    for _, callback in ipairs(self.callbackMap[itemKeyString]) do
      callback(info, false)
    end
    self.callbackMap[itemKeyString] = nil
  else
    if self.waiting[itemKey.itemID] == nil then
      self.waiting[itemKey.itemID] = {}

      self.waitingCount = self.waitingCount + 1
    end

    if not self.registered then
      self.registered = true
      FrameUtil.RegisterFrameForEvents(self, ITEM_KEY_INFO_EVENTS)

      AuctionHouseHelper.Debug.Message("AuctionHouseHelperAHItemKeyLoaderFrameMixin", self.registered)
    end

    self:MergeRequests(itemKey)
  end
end

function AuctionHouseHelperAHItemKeyLoaderFrameMixin:MergeRequests(itemKey)
  local keyString = AuctionHouseHelper.Utilities.ItemKeyString(itemKey)
  for _, key in ipairs(self.waiting[itemKey.itemID]) do
    if keyString == AuctionHouseHelper.Utilities.ItemKeyString(key) then
      return
    end
  end

  table.insert(self.waiting[itemKey.itemID], itemKey)
end

function AuctionHouseHelperAHItemKeyLoaderFrameMixin:OnEvent(event, itemID)
  if (
    event == "ITEM_KEY_ITEM_INFO_RECEIVED" and
    self.waiting[itemID] ~= nil
  ) then

    local itemKeys = self.waiting[itemID]

    self.waitingCount = self.waitingCount -1
    self.waiting[itemID] = nil

    for _, key in ipairs(itemKeys) do
      self:Get(key)
    end
  end

  if self.waitingCount == 0 and self.registered then
    self.registered = false
    FrameUtil.UnregisterFrameForEvents(self, ITEM_KEY_INFO_EVENTS)

    AuctionHouseHelper.Debug.Message("AuctionHouseHelperAHItemKeyLoaderFrameMixin", self.registered)
  end
end
