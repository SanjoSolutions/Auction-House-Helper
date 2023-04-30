AuctionHouseHelperScrollListLineRecentsMixin = CreateFromMixins(AuctionHouseHelperScrollListLineMixin)

function AuctionHouseHelperScrollListLineRecentsMixin:InitLine()
  AuctionHouseHelper.EventBus:RegisterSource(self, "Recents List Line Item")

  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded,
    AuctionHouseHelper.Shopping.Tab.Events.DialogOpened,
    AuctionHouseHelper.Shopping.Tab.Events.DialogClosed,
  })

  self.shouldRemoveHighlight = true
end

function AuctionHouseHelperScrollListLineRecentsMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted then
    if self.shouldRemoveHighlight then
      self.LastSearchedHighlight:Hide()
    end
    self:Disable()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded then
    self.shouldRemoveHighlight = true
    self:Enable()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.DialogOpened then
    self:Disable()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.DialogClosed then
    self:Enable()
  end
end

function AuctionHouseHelperScrollListLineRecentsMixin:DeleteItem()
  if not self:IsEnabled() then
    return
  end

  AuctionHouseHelper.Shopping.Recents.DeleteEntry(self.searchTerm)
end

function AuctionHouseHelperScrollListLineRecentsMixin:CopyItem()
  if not self:IsEnabled() then
    return
  end

  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.CopyIntoList, self.searchTerm)
end

function AuctionHouseHelperScrollListLineRecentsMixin:OnClick()
  self.LastSearchedHighlight:Show()
  self.shouldRemoveHighlight = false
  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.OneItemSearch, self.searchTerm)
end
