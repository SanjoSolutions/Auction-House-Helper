AuctionHouseHelperScrollListLineShoppingListMixin = CreateFromMixins(AuctionHouseHelperScrollListLineMixin)

function AuctionHouseHelperScrollListLineShoppingListMixin:InitLine(currentList)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperScrollListLineShoppingListShoppingListMixin:InitLine()")

  AuctionHouseHelper.EventBus:RegisterSource(self, "Shopping List Line Item")

  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Shopping.Tab.Events.ListSelected,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded,
    AuctionHouseHelper.Shopping.Tab.Events.DialogOpened,
    AuctionHouseHelper.Shopping.Tab.Events.DialogClosed,
  })

  self.currentList = currentList
end

function AuctionHouseHelperScrollListLineShoppingListMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSelected then
    self.currentList = eventData
    self.LastSearchedHighlight:Hide()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted then
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

function AuctionHouseHelperScrollListLineShoppingListMixin:GetListIndex()
  return self.currentList:GetIndexForItem(self.searchTerm)
end

function AuctionHouseHelperScrollListLineShoppingListMixin:DeleteItem()
  if not self:IsEnabled() then
    return
  end

  self.currentList:DeleteItem(self:GetListIndex())
end

function AuctionHouseHelperScrollListLineShoppingListMixin:EditItem()
  if not self:IsEnabled() then
    return
  end

  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.EditListItem, self:GetListIndex())
end

function AuctionHouseHelperScrollListLineShoppingListMixin:OnMouseDown()
  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DragItemStart, self:GetListIndex())
end

function AuctionHouseHelperScrollListLineShoppingListMixin:OnMouseUp()
  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DragItemStop)
end

function AuctionHouseHelperScrollListLineShoppingListMixin:OnEnter()
  AuctionHouseHelperScrollListLineMixin.OnEnter(self)

  if IsMouseButtonDown("LeftButton") then
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DragItemEnter, self:GetListIndex())
  end
end

function AuctionHouseHelperScrollListLineShoppingListMixin:OnClick()
  self.LastSearchedHighlight:Show()
  self.shouldRemoveHighlight = false
  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.ListItemSelected, self.searchTerm)
end
