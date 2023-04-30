AuctionHouseHelperShoppingOneItemSearchMixin = {}

local function GetAppropriateText(searchTerm)
  local search = AuctionHouseHelper.Search.SplitAdvancedSearch(searchTerm)
  local newSearch = search.searchString
  for key, value in pairs(search) do
    if key == "isExact" then
      if value then
        newSearch = "\"" .. newSearch .. "\""
      end
    elseif key == "categoryKey" then
      if value ~= "" then
        return AUCTION_HOUSE_HELPER_L_EXTENDED_SEARCH_ACTIVE_TEXT
      end
    elseif key ~= "searchString" then
      return AUCTION_HOUSE_HELPER_L_EXTENDED_SEARCH_ACTIVE_TEXT
    end
  end
  return newSearch
end

function AuctionHouseHelperShoppingOneItemSearchMixin:OnLoad()
  AuctionHouseHelper.EventBus:RegisterSource(self, "Shopping One Item Search")

  self.searchRunning = false
  DynamicResizeButton_Resize(self.SearchButton)

  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Shopping.Tab.Events.OneItemSearch,
    AuctionHouseHelper.Shopping.Tab.Events.ListItemSelected,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded,
    AuctionHouseHelper.Shopping.Tab.Events.DialogOpened,
    AuctionHouseHelper.Shopping.Tab.Events.DialogClosed,
  })
end

function AuctionHouseHelperShoppingOneItemSearchMixin:OnShow()
  self.SearchBox:SetFocus()
end

function AuctionHouseHelperShoppingOneItemSearchMixin:ReceiveEvent(eventName, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperShoppingOneItemSearchButtonMixin:ReceiveEvent " .. eventName, ...)

  if eventName == AuctionHouseHelper.Shopping.Tab.Events.OneItemSearch or
     eventName == AuctionHouseHelper.Shopping.Tab.Events.ListItemSelected then
    self.lastSearch = ...
    if self.lastSearch ~= self.SearchBox:GetText() then
      self.SearchBox:SetText(GetAppropriateText(self.lastSearch))
    end
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted then
    self.searchRunning = true

    self.SearchButton:SetText(AUCTION_HOUSE_HELPER_L_CANCEL)
    self.SearchButton:SetWidth(0)
    DynamicResizeButton_Resize(self.SearchButton)
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded then
    self.searchRunning = false

    self.SearchButton:SetText(AUCTION_HOUSE_HELPER_L_SEARCH)
    self.SearchButton:SetWidth(0)
    DynamicResizeButton_Resize(self.SearchButton)

  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.DialogOpened then
    self.ExtendedButton:Disable()

  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.DialogClosed then
    self.ExtendedButton:Enable()
  end
end

function AuctionHouseHelperShoppingOneItemSearchMixin:DoSearch(searchTerm)
  AuctionHouseHelper.Shopping.Recents.Save(searchTerm)

  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.OneItemSearch, searchTerm)
end

function AuctionHouseHelperShoppingOneItemSearchMixin:SearchButtonClicked()
  if not self.searchRunning then
    local searchTerm = self.SearchBox:GetText()
    if searchTerm == AUCTION_HOUSE_HELPER_L_EXTENDED_SEARCH_ACTIVE_TEXT then
      searchTerm = self.lastSearch
      if searchTerm == nil then
        searchTerm = ""
        self.SearchBox:SetText("")
      end
    end

    self.SearchBox:ClearFocus()
    self:DoSearch(searchTerm)
  else
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.CancelSearch)
  end
end

function AuctionHouseHelperShoppingOneItemSearchMixin:OpenExtendedOptions()
  local itemDialog = self:GetParent().itemDialog

  itemDialog:Init(AUCTION_HOUSE_HELPER_L_LIST_EXTENDED_SEARCH_HEADER, AUCTION_HOUSE_HELPER_L_SEARCH)
  itemDialog:SetOnFinishedClicked(function(newItemString)
    self.SearchBox:SetText(AUCTION_HOUSE_HELPER_L_EXTENDED_SEARCH_ACTIVE_TEXT)
    self:DoSearch(newItemString)
  end)

  itemDialog:Show()

  local searchTerm = self.SearchBox:GetText()
  if searchTerm == AUCTION_HOUSE_HELPER_L_EXTENDED_SEARCH_ACTIVE_TEXT then
    searchTerm = self.lastSearch
  end
  itemDialog:SetItemString(searchTerm)
end

function AuctionHouseHelperShoppingOneItemSearchMixin:GetLastSearch()
  return self.lastSearch
end
