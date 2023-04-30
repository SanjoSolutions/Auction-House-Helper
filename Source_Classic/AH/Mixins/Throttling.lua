-- Call the appropriate method before doing the action to ensure the throttle
-- state is set correctly
-- :SearchQueried()
-- :AuctionsPosted()
-- :AuctionCancelled()
-- :BidPlaced()
AuctionHouseHelperAHThrottlingFrameMixin = {}

local THROTTLING_EVENTS = {
  "AUCTION_HOUSE_CLOSED",
  "UI_ERROR_MESSAGE",
}
local NEW_AUCTION_EVENTS = {
  "NEW_AUCTION_UPDATE",
  "AUCTION_MULTISELL_START",
  "AUCTION_MULTISELL_UPDATE",
  "AUCTION_MULTISELL_FAILURE",
}
-- If we don't wait for the owned list to update before doing the next query it
-- sometimes never updates and requires that the AH is reopened to update again.
-- Includes alternate check for when the owned list doesn't update
local AUCTIONS_UPDATED_EVENTS = {
  "CHAT_MSG_SYSTEM",
}
local BID_PLACED_EVENTS = {
  "AUCTION_ITEM_LIST_UPDATE",
}
local TIMEOUT = 10

function AuctionHouseHelperAHThrottlingFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperAHThrottlingFrameMixin:OnLoad")

  FrameUtil.RegisterFrameForEvents(self, THROTTLING_EVENTS)

  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperAHThrottlingFrameMixin")

  self.oldReady = false
  self:ResetTimeout()
end

function AuctionHouseHelperAHThrottlingFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_CLOSED" then
    self:ResetWaiting()

  elseif eventName == "AUCTION_MULTISELL_START" then
    self:ResetTimeout()
    self.multisellInProgress = true

  elseif eventName == "NEW_AUCTION_UPDATE" then
    self:ResetTimeout()
    if not self.multisellInProgress then
      FrameUtil.UnregisterFrameForEvents(self, NEW_AUCTION_EVENTS)
      FrameUtil.RegisterFrameForEvents(self, AUCTIONS_UPDATED_EVENTS)
      self.waitingForNewAuction = false
      self.waitingForOwnerUpdate = true
    end

  elseif eventName == "AUCTION_MULTISELL_UPDATE" then
    self:ResetTimeout()
    local progress, total = ...
    if progress == total then
      self.multisellInProgress = false
    end

  elseif eventName == "AUCTION_MULTISELL_FAILURE" then
    self:ResetTimeout()
    FrameUtil.UnregisterFrameForEvents(self, NEW_AUCTION_EVENTS)
    self.multisellInProgress = false
    self.waitingForNewAuction = false

  elseif eventName == "CHAT_MSG_SYSTEM" then
    local msg = ...
    -- Use "Auction ..." message to confirm the post/cancel went through
    if msg == ERR_AUCTION_STARTED or msg == ERR_AUCTION_REMOVED then
      self:ResetTimeout()
      FrameUtil.UnregisterFrameForEvents(self, AUCTIONS_UPDATED_EVENTS)
      self.waitingForOwnerUpdate = false
    end

  elseif eventName == "AUCTION_ITEM_LIST_UPDATE" then
    self:ComparePages()

  elseif eventName == "UI_ERROR_MESSAGE" then
    if AuctionFrame:IsShown() and self:AnyWaiting() then
      self:ResetWaiting()
    end
  end
end

function AuctionHouseHelperAHThrottlingFrameMixin:OnUpdate(elapsed)
  if self:AnyWaiting() then
    self.timeout = self.timeout - elapsed
    if self.timeout <= 0 then
      self:ResetWaiting()
      self:ResetTimeout()
    end
  else
    self.timeout = TIMEOUT
  end
  if self.timeout ~= TIMEOUT then
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.CurrentThrottleTimeout, self.timeout)
  end

  local ready = self:IsReady()

  if ready and not self.oldReady then
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.Ready)
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.ThrottleUpdate, true)
  elseif self.oldReady ~= ready then
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.ThrottleUpdate, false)
  end

  self.oldReady = ready
end

function AuctionHouseHelperAHThrottlingFrameMixin:SearchQueried()
end

function AuctionHouseHelperAHThrottlingFrameMixin:IsReady()
  return (CanSendAuctionQuery()) and not self:AnyWaiting()
end

function AuctionHouseHelperAHThrottlingFrameMixin:AnyWaiting()
  return self.waitingForNewAuction or self.multisellInProgress or self.waitingOnBid or self.waitingForOwnerUpdate
end

function AuctionHouseHelperAHThrottlingFrameMixin:ResetTimeout()
  self.timeout = TIMEOUT
  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.CurrentThrottleTimeout, self.timeout)
end

function AuctionHouseHelperAHThrottlingFrameMixin:ResetWaiting()
  self.waitingForNewAuction = false
  self.multisellInProgress = false
  self.waitingOnBid = false
  self.waitingForOwnerUpdate = false
  FrameUtil.UnregisterFrameForEvents(self, BID_PLACED_EVENTS)
  FrameUtil.UnregisterFrameForEvents(self, NEW_AUCTION_EVENTS)
  FrameUtil.UnregisterFrameForEvents(self, AUCTIONS_UPDATED_EVENTS)
end

function AuctionHouseHelperAHThrottlingFrameMixin:AuctionsPosted()
  self:ResetTimeout()
  FrameUtil.RegisterFrameForEvents(self, NEW_AUCTION_EVENTS)
  self.waitingForNewAuction = true
  self.oldReady = false
end

function AuctionHouseHelperAHThrottlingFrameMixin:AuctionCancelled()
  self:ResetTimeout()
  self.waitingForOwnerUpdate = true
  self.oldReady = false
  FrameUtil.RegisterFrameForEvents(self, AUCTIONS_UPDATED_EVENTS)
end

function AuctionHouseHelperAHThrottlingFrameMixin:BidPlaced()
  self:ResetTimeout()
  FrameUtil.RegisterFrameForEvents(self, BID_PLACED_EVENTS)
  self.currentPage = AuctionHouseHelper.AH.GetCurrentPage()
  self.waitingOnBid = true
  self.oldReady = false
end

function AuctionHouseHelperAHThrottlingFrameMixin:ComparePages()
  local newPage = AuctionHouseHelper.AH.GetCurrentPage()
  if #newPage ~= #self.currentPage then
    self.waitingOnBid = false
    FrameUtil.UnregisterFrameForEvents(self, BID_PLACED_EVENTS)
    return
  end

  for index, auction in ipairs(self.currentPage) do
    local stackPrice = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Buyout]
    local stackSize = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity]
    local minBid = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.MinBid]
    local bidAmount = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.BidAmount]
    local newStackPrice = newPage[index].info[AuctionHouseHelper.Constants.AuctionItemInfo.Buyout]
    local newStackSize = newPage[index].info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity]
    local newMinBid = newPage[index].info[AuctionHouseHelper.Constants.AuctionItemInfo.MinBid]
    local newBidAmount = newPage[index].info[AuctionHouseHelper.Constants.AuctionItemInfo.BidAmount]
    if stackPrice ~= newStackPrice or stackSize ~= newStackSize or
       minBid ~= newMinBid or bidAmount ~= newMinBidAmount or
       newPage[index].itemLink ~= auction.itemLink then
      self.waitingOnBid = false
      FrameUtil.UnregisterFrameForEvents(self, BID_PLACED_EVENTS)
      return
    end
  end
end
