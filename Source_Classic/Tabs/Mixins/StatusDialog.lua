AuctionHouseHelperPageStatusDialogMixin = {}

function AuctionHouseHelperPageStatusDialogMixin:OnLoad()
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.AH.Events.ScanResultsUpdate,
    AuctionHouseHelper.AH.Events.ScanAborted,
    AuctionHouseHelper.AH.Events.ScanPageStart,
  })
  self:Hide()
end

function AuctionHouseHelperPageStatusDialogMixin:OnHide()
  self:Hide()
end

function AuctionHouseHelperPageStatusDialogMixin:ReceiveEvent(eventName, ...)
  if eventName == AuctionHouseHelper.AH.Events.ScanPageStart then
    local page = ...
    self:Show()
    self.StatusText:SetText(AUCTION_HOUSE_HELPER_L_SCANNING_PAGE_X:format(page + 1))

  elseif eventName == AuctionHouseHelper.AH.Events.ScanResultsUpdate then
    local _, isComplete = ...
    if isComplete then
      self:Hide()
    end

  elseif eventName == AuctionHouseHelper.AH.Events.ScanAborted then
    self:Hide()
  end
end

AuctionHouseHelperThrottlingTimeoutDialogMixin = {}

function AuctionHouseHelperThrottlingTimeoutDialogMixin:OnLoad()
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.AH.Events.CurrentThrottleTimeout,
  })
  self:Hide()
end

function AuctionHouseHelperThrottlingTimeoutDialogMixin:OnHide()
  self:Hide()
end

function AuctionHouseHelperThrottlingTimeoutDialogMixin:ReceiveEvent(eventName, ...)
  if eventName == AuctionHouseHelper.AH.Events.CurrentThrottleTimeout then
    local timeout = ...
    if timeout < 8 then
      self:Show()
      self.StatusText:SetText(AUCTION_HOUSE_HELPER_L_WAITING_AT_MOST_X_LONGER:format(math.ceil(timeout)))
    else
      if self:IsShown() then
        AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_SERVER_TOOK_TOO_LONG)
      end
      self:Hide()
    end
  end
end
