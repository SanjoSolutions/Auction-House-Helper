AuctionHouseHelperShoppingClassicLoadAllButtonMixin = {}

function AuctionHouseHelperShoppingClassicLoadAllButtonMixin:OnLoad()
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Shopping.Tab.Events.SearchForTerms,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded,
  })
end

function AuctionHouseHelperShoppingClassicLoadAllButtonMixin:ReceiveEvent(eventName, eventData)
  if eventName == AuctionHouseHelper.Shopping.Tab.Events.SearchForTerms then
    self.lastTerms = eventData
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted then
    self:Hide()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded then
    if eventData and #eventData > 0 then
      local anyIncomplete = false
      for _, entry in ipairs(eventData) do
        if not entry.complete then
          anyIncomplete = true
          break
        end
      end
      self:SetShown(anyIncomplete)
    end
   end
end

function AuctionHouseHelperShoppingClassicLoadAllButtonMixin:OnClick()
  if self.lastTerms ~= nil then
    AuctionHouseHelper.EventBus:Fire(self:GetParent(), AuctionHouseHelper.Shopping.Tab.Events.SearchForTerms, self.lastTerms, { searchAllPages = true })
  end
end
