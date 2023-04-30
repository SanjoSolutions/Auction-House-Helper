-- Call the appropriate method before doing the action to ensure the throttle
-- state is set correctly
-- :SearchQueried()
AuctionHouseHelperAHThrottlingFrameMixin = {}

local THROTTLING_EVENTS = {
  "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED",
  "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
  "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
  "AUCTION_HOUSE_BROWSE_FAILURE"
}

function AuctionHouseHelperAHThrottlingFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperAHThrottlingFrameMixin:OnLoad")
  self.oldReady = false

  FrameUtil.RegisterFrameForEvents(self, THROTTLING_EVENTS)

  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperAHThrottlingFrameMixin")
end

function AuctionHouseHelperAHThrottlingFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_THROTTLED_SYSTEM_READY" then
    AuctionHouseHelper.Debug.Message("normal ready")

  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" or
         eventName == "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED" then
    AuctionHouseHelper.Debug.Message("fail", eventName)

  else
    AuctionHouseHelper.Debug.Message("not ready", eventName)
  end

  local ready = self:IsReady()

  if self.oldReady ~= ready then
    if ready then
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.Ready)
    end
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.AH.Events.ThrottleUpdate, ready)
  end

  self.oldReady = ready
end

function AuctionHouseHelperAHThrottlingFrameMixin:SearchQueried()
end

function AuctionHouseHelperAHThrottlingFrameMixin:IsReady()
  return C_AuctionHouse.IsThrottledMessageSystemReady()
end
