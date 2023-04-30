AuctionHouseHelperShoppingTabRecentsContainerMixin = {}
function AuctionHouseHelperShoppingTabRecentsContainerMixin:OnLoad()
  self.Tabs = {self.ListTab, self.RecentsTab}
  self.numTabs = #self.Tabs

  AuctionHouseHelper.EventBus:RegisterSource(self, "List Search Button")

  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Shopping.Tab.Events.ListSelected,
  })
end

function AuctionHouseHelperShoppingTabRecentsContainerMixin:ReceiveEvent(eventName)
  if eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSelected then
    self:SetView(AuctionHouseHelper.Constants.ShoppingListViews.Lists)
  end
end

function AuctionHouseHelperShoppingTabRecentsContainerMixin:SetView(viewIndex)
  PanelTemplates_SetTab(self, viewIndex)

  self:GetParent().ManualSearch:Hide()
  self:GetParent().AddItem:Hide()
  self:GetParent().SortItems:Hide()

  if viewIndex == AuctionHouseHelper.Constants.ShoppingListViews.Recents then
    self:GetParent().ScrollListShoppingList:Hide()
    self:GetParent().ScrollListRecents:Show()

  elseif viewIndex == AuctionHouseHelper.Constants.ShoppingListViews.Lists then
    self:GetParent().ScrollListRecents:Hide()
    self:GetParent().ScrollListShoppingList:Show()
    self:GetParent().ManualSearch:Show()
    self:GetParent().AddItem:Show()
    self:GetParent().SortItems:Show()
  end
end
