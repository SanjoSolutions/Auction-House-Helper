SYSTEM_EVENTS = {
  "CHAT_MSG_SYSTEM", --ERR_AUCTION_STARTED "Auction created"
  "UI_ERROR_MESSAGE", --ERR_AUCTION_DATABASE_ERROR "Internal auction error"
}

AuctionHouseHelperPostWatchMixin = {}

function AuctionHouseHelperPostWatchMixin:StopWatching()
  self.details = nil
  if self.waitingForConfirmation then
    FrameUtil.UnregisterFrameForEvents(self, SYSTEM_EVENTS)
  end
  self.waitingForConfirmation = false
end

function AuctionHouseHelperPostWatchMixin:ReceiveEvent(eventName, details)
  if eventName == AuctionHouseHelper.Selling.Events.PostAttempt then
    self.details = details
    self.details.numStacksReached = 0
    AuctionHouseHelper.Debug.Message("post attempt", self.details.itemInfo.itemLink)
    if not self.waitingForConfirmation then
      self.waitingForConfirmation = true
      FrameUtil.RegisterFrameForEvents(self, SYSTEM_EVENTS)
    end
  end
end

function AuctionHouseHelperPostWatchMixin:OnEvent(eventName, eventData1, eventData2)
  if eventName == "CHAT_MSG_SYSTEM" and eventData1 == ERR_AUCTION_STARTED then
    self.details.numStacksReached = self.details.numStacksReached + 1

    if self.details.numStacksReached == self.details.numStacks then
      AuctionHouseHelper.Debug.Message("pass", self.details.itemInfo.itemLink)
      local details = self.details
      self:StopWatching()
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Selling.Events.PostSuccessful, details)
    end
  elseif eventName == "UI_ERROR_MESSAGE" and eventData2 == ERR_AUCTION_DATABASE_ERROR then
    AuctionHouseHelper.Debug.Message("fail blizz internal auction error", self.details.itemInfo.itemLink)
    local details = self.details
    self:StopWatching()
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Selling.Events.PostFailed, details)
  end
end

function AuctionHouseHelperPostWatchMixin:OnShow()
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Selling.Events.PostAttempt,
  })
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperPostWatchMixin")
end

function AuctionHouseHelperPostWatchMixin:OnHide()
  self:StopWatching()
  AuctionHouseHelper.EventBus:Unregister(self, {
    AuctionHouseHelper.Selling.Events.PostAttempt,
  })
end
