AuctionHouseHelperScrollListShoppingListMixin = CreateFromMixins(AuctionHouseHelperScrollListMixin)

function AuctionHouseHelperScrollListShoppingListMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperScrollListMixin:OnLoad()")

  self:SetUpEvents()

  self:SetLineTemplate("AuctionHouseHelperScrollListLineShoppingListTemplate")
end

function AuctionHouseHelperScrollListShoppingListMixin:SetUpEvents()
  -- AuctionHouseHelper Events
  AuctionHouseHelper.EventBus:RegisterSource(self, "Shopping List Scroll Frame for Lists")

  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Shopping.Events.ListMetaChange,
    AuctionHouseHelper.Shopping.Events.ListItemChange,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchIncrementalUpdate,
    AuctionHouseHelper.Shopping.Tab.Events.ListSelected,
    AuctionHouseHelper.Shopping.Tab.Events.ListItemSelected,
    AuctionHouseHelper.Shopping.Tab.Events.ListItemAdded,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchRequested,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded,
    AuctionHouseHelper.Shopping.Tab.Events.OneItemSearch,
    AuctionHouseHelper.Shopping.Tab.Events.DragItemStart,
    AuctionHouseHelper.Shopping.Tab.Events.DragItemEnter,
    AuctionHouseHelper.Shopping.Tab.Events.DragItemStop,
  })
end

function AuctionHouseHelperScrollListShoppingListMixin:GetAllSearchTerms()
  return self.currentList:GetAllItems()
end

function AuctionHouseHelperScrollListShoppingListMixin:GetAppropriateName()
  if self.isSearchingForOneItem or self.currentList == nil then
    return AUCTION_HOUSE_HELPER_L_NO_LIST
  else
    return self.currentList:GetName()
  end
end

function AuctionHouseHelperScrollListShoppingListMixin:ReceiveEvent(eventName, eventData, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperScrollListShoppingListMixin:ReceiveEvent()", eventName, eventData)

  if eventName == AuctionHouseHelper.Shopping.Events.ListItemChange then
    if self.currentList and self.currentList:GetName() == eventData then
      self:RefreshScrollFrame(true)
    end
  elseif eventName == AuctionHouseHelper.Shopping.Events.ListMetaChange then
    if self.currentList and self.currentList:GetName() == eventData then
      if AuctionHouseHelper.Shopping.ListManager:GetIndexForName(eventData) == nil then
        self.currentList = nil
        self:RefreshScrollFrame()
      end
    end
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSelected then
    self.currentList = eventData

    if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUTO_LIST_SEARCH) then
      self:StartSearch(self:GetAllSearchTerms())
    end

    self:RefreshScrollFrame()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListItemSelected then
    self:StartSearch({ eventData })
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.OneItemSearch and self:IsShown() then
    self:StartSearch({ eventData }, true)
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListItemAdded then
    self:ScrollToBottom()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.DragItemStart then
    self.dragStartIndex = eventData
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.DragItemEnter then
    self.dragNewIndex = eventData
    self:UpdateForDrag()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.DragItemStop then
    self.dragStartIndex = nil
    self.dragNewIndex = nil
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchRequested then
    self:StartSearch(self:GetAllSearchTerms())
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted then
    self.ResultsText:SetText(AuctionHouseHelper.Locales.Apply("LIST_SEARCH_START", self:GetAppropriateName()))
    self.ResultsText:Show()

    self.SpinnerAnim:Play()
    self.LoadingSpinner:Show()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchIncrementalUpdate then
    local total, current = ...
    self.ResultsText:SetText(AuctionHouseHelper.Locales.Apply("LIST_SEARCH_STATUS", current, total, self:GetAppropriateName()))
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded then
    self:HideSpinner()
  end
end

function AuctionHouseHelperScrollListShoppingListMixin:InitLine(line)
  line:InitLine(self.currentList)
end

function AuctionHouseHelperScrollListShoppingListMixin:UpdateForDrag()
  if self.dragStartIndex ~= nil and self.dragNewIndex ~= nil and self.dragStartIndex ~= self.dragNewIndex then
    local toDrag = self.currentList:GetItemByIndex(self.dragStartIndex)

    self.currentList:DeleteItem(self.dragStartIndex)

    self.dragStartIndex = self.dragNewIndex
    self.currentList:InsertItem(toDrag, self.dragStartIndex)
  end
end

function AuctionHouseHelperScrollListShoppingListMixin:StartSearch(searchTerms, isSearchingForOneItem)
  self.isSearchingForOneItem = isSearchingForOneItem

  AuctionHouseHelper.EventBus:Fire(
    self,
    AuctionHouseHelper.Shopping.Tab.Events.SearchForTerms,
    searchTerms
  )
end

function AuctionHouseHelperScrollListShoppingListMixin:HideSpinner()
  self.LoadingSpinner:Hide()
  self.ResultsText:Hide()
end

function AuctionHouseHelperScrollListShoppingListMixin:OnHide()
  self:AbortRunningSearches()
end

function AuctionHouseHelperScrollListShoppingListMixin:GetNumEntries()
  if self.currentList == nil then
    return 0
  else
    return self.currentList:GetItemCount()
  end
end

function AuctionHouseHelperScrollListShoppingListMixin:GetEntry(index)
  if self.currentList == nil then
    error("No AuctionHouseHelper shopping list was selected.")
  elseif index > self.currentList:GetItemCount() then
    return ""
  else
    return self.currentList:GetItemByIndex(index)
  end
end

