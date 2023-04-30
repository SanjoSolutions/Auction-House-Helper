AuctionHouseHelperShoppingTabMixin = {}

local ListSelected = AuctionHouseHelper.Shopping.Tab.Events.ListSelected
local ListItemSelected = AuctionHouseHelper.Shopping.Tab.Events.ListItemSelected
local EditListItem = AuctionHouseHelper.Shopping.Tab.Events.EditListItem
local DialogOpened = AuctionHouseHelper.Shopping.Tab.Events.DialogOpened
local DialogClosed = AuctionHouseHelper.Shopping.Tab.Events.DialogClosed
local ShowHistoricalPrices = AuctionHouseHelper.Shopping.Tab.Events.ShowHistoricalPrices
local ListItemAdded = AuctionHouseHelper.Shopping.Tab.Events.ListItemAdded
local CopyIntoList = AuctionHouseHelper.Shopping.Tab.Events.CopyIntoList

function AuctionHouseHelperShoppingTabMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperShoppingTabMixin:OnLoad()")

  self:SetUpEvents()
  self:SetUpItemDialog()
  self:SetUpExportDialog()
  self:SetUpImportDialog()
  self:SetUpExportCSVDialog()
  self:SetUpItemHistoryDialog()

  -- Add Item button starts in the default state until a list is selected
  self.AddItem:Disable()
  self.SortItems:Disable()

  self.ResultsListing:Init(self.DataProvider)

  self.RecentsTabsContainer:SetView(AuctionHouseHelper.Constants.ShoppingListViews.Recents)
end

function AuctionHouseHelperShoppingTabMixin:SetUpEvents()
  -- System Events
  self:RegisterEvent("AUCTION_HOUSE_CLOSED")

  -- AuctionHouseHelper Events
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelper Shopping List Tab")
  AuctionHouseHelper.EventBus:Register(self, { ListSelected, ListItemSelected, EditListItem, DialogOpened, DialogClosed, ShowHistoricalPrices, CopyIntoList })
end

function AuctionHouseHelperShoppingTabMixin:SetUpItemDialog()
  self.itemDialog = CreateFrame("Frame", "AuctionHouseHelperShoppingItemFrame", self, "AuctionHouseHelperShoppingItemTemplate")
  self.itemDialog:SetPoint("CENTER")
end

function AuctionHouseHelperShoppingTabMixin:SetUpExportDialog()
  self.exportDialog = CreateFrame("Frame", "AuctionHouseHelperExportListFrame", self, "AuctionHouseHelperExportListTemplate")
  self.exportDialog:SetPoint("CENTER")
end

function AuctionHouseHelperShoppingTabMixin:SetUpImportDialog()
  self.importDialog = CreateFrame("Frame", "AuctionHouseHelperImportListFrame", self, "AuctionHouseHelperImportListTemplate")
  self.importDialog:SetPoint("CENTER")
end

function AuctionHouseHelperShoppingTabMixin:SetUpExportCSVDialog()
  self.exportCSVDialog = CreateFrame("Frame", nil, self, "AuctionHouseHelperExportTextFrame")
  self.exportCSVDialog:SetPoint("CENTER")
  self.exportCSVDialog:SetOpeningEvents(DialogOpened, DialogClosed)
end

function AuctionHouseHelperShoppingTabMixin:SetUpItemHistoryDialog()
  self.itemHistoryDialog = CreateFrame("Frame", "AuctionHouseHelperItemHistoryFrame", self, "AuctionHouseHelperItemHistoryTemplate")
  self.itemHistoryDialog:SetPoint("CENTER")
  self.itemHistoryDialog:Init()
end

function AuctionHouseHelperShoppingTabMixin:OnShow()
  if self.selectedList ~= nil then
    self.AddItem:Enable()
  end
end

function AuctionHouseHelperShoppingTabMixin:OnEvent(event, ...)
  self.itemDialog:ResetAll()
  self.itemDialog:Hide()
end

function AuctionHouseHelperShoppingTabMixin:ReceiveEvent(eventName, eventData)
  if eventName == ListSelected then
    self.selectedList = eventData
    self.AddItem:Enable()
    self.SortItems:Enable()
  elseif eventName == AuctionHouseHelper.Shopping.Events.ListMetaChange and self.selectedList ~= nil and eventData == self.selectedList:GetName() and AuctionHouseHelper.Shopping.ListManager:GetIndexForName(eventData) == nil then
    self.selectedList = nil
    self.AddItem:Disable()
    self.ManualSearch:Disable()
    self.SortItems:Disable()

  elseif eventName == DialogOpened then
    self.isDialogOpen = true
    self.AddItem:Disable()
    self.Export:Disable()
    self.Import:Disable()
    self.ExportCSV:Disable()
  elseif eventName == DialogClosed then
    self.isDialogOpen = false
    if self.selectedList ~= nil then
      self.AddItem:Enable()
    end
    self.Export:Enable()
    self.Import:Enable()
    self.ExportCSV:Enable()

  elseif eventName == ShowHistoricalPrices and not self.isDialogOpen then
    self.itemHistoryDialog:Show()

  elseif eventName == EditListItem then
    self.editingItemIndex = eventData
    self:EditItemClicked()

  elseif eventName == CopyIntoList then
    local newItem = eventData
    self:CopyIntoList(newItem)
  end
end

function AuctionHouseHelperShoppingTabMixin:AddItemToList(newItemString)
  if self.selectedList == nil then
    AuctionHouseHelper.Utilities.Message(
      AuctionHouseHelper.Locales.Apply("LIST_ADD_ERROR")
    )
    return
  end

  self.selectedList:InsertItem(newItemString)

  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.ListItemAdded, self.selectedList)
end

function AuctionHouseHelperShoppingTabMixin:CopyIntoList(searchTerm)
  if self.selectedList == nil then
    AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_COPY_NO_LIST_SELECTED)
  else
    self:AddItemToList(searchTerm)
    AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_COPY_ITEM_ADDED:format(
      GREEN_FONT_COLOR:WrapTextInColorCode(AuctionHouseHelper.Search.PrettifySearchString(searchTerm)),
      GREEN_FONT_COLOR:WrapTextInColorCode(self.selectedList:GetName())
    ))
  end
end

function AuctionHouseHelperShoppingTabMixin:ReplaceItemInList(newItemString)
  if self.selectedList == nil then
    AuctionHouseHelper.Utilities.Message(
      AuctionHouseHelper.Locales.Apply("LIST_ADD_ERROR")
    )
    return
  end

  self.selectedList:AlterItem(self.editingItemIndex, newItemString)
end

function AuctionHouseHelperShoppingTabMixin:AddItemClicked()
  if IsShiftKeyDown() then
    self:AddItemToList(self.OneItemSearch:GetLastSearch() or "")
  else
    self.itemDialog:Init(AUCTION_HOUSE_HELPER_L_LIST_ADD_ITEM_HEADER, AUCTION_HOUSE_HELPER_L_ADD_ITEM)
    self.itemDialog:SetOnFinishedClicked(function(newItemString)
      self:AddItemToList(newItemString)
    end)

    self.itemDialog:Show()
  end
end

function AuctionHouseHelperShoppingTabMixin:EditItemClicked()
  self.itemDialog:Init(AUCTION_HOUSE_HELPER_L_LIST_EDIT_ITEM_HEADER, AUCTION_HOUSE_HELPER_L_EDIT_ITEM)
  self.itemDialog:SetOnFinishedClicked(function(newItemString)
    self:ReplaceItemInList(newItemString)
  end)

  self.itemDialog:Show()
  self.itemDialog:SetItemString(self.selectedList:GetItemByIndex(self.editingItemIndex))
end

function AuctionHouseHelperShoppingTabMixin:ImportListsClicked()
  self.importDialog:Show()
end

function AuctionHouseHelperShoppingTabMixin:ExportListsClicked()
  self.exportDialog:Show()
end

function AuctionHouseHelperShoppingTabMixin:ExportCSVClicked()
  self.DataProvider:GetCSV(function(result)
    self.exportCSVDialog:SetExportString(result)
    self.exportCSVDialog:Show()
  end)
end

function AuctionHouseHelperShoppingTabMixin:SortItemsClicked()
  self.selectedList:Sort()
end
