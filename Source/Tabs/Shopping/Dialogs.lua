local function CreateList(self, listName)
  listName = AuctionHouseHelper.Shopping.ListManager:GetUnusedName(listName)

  AuctionHouseHelper.Shopping.ListManager:Create(listName)

  AuctionHouseHelper.EventBus:Fire(
    self,
    AuctionHouseHelper.Shopping.Tab.Events.ListCreated,
    AuctionHouseHelper.Shopping.ListManager:GetByName(listName)
  )
end

StaticPopupDialogs[AuctionHouseHelper.Constants.DialogNames.CreateShoppingList] = {
  text = AUCTION_HOUSE_HELPER_L_CREATE_LIST_DIALOG,
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 32,
  OnShow = function(self)
    AuctionHouseHelper.EventBus:RegisterSource(self, "Create Shopping List Dialog")

    self.editBox:SetText("")
    self.editBox:SetFocus()
  end,
  OnHide = function(self)
    AuctionHouseHelper.EventBus:UnregisterSource(self)
  end,
  OnAccept = function(self)
    CreateList(self, self.editBox:GetText())
  end,
  EditBoxOnEnterPressed = function(self)
    CreateList(self:GetParent(), self:GetText())
    self:GetParent():Hide()
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}

local function DeleteList(self, listName)
  AuctionHouseHelper.Shopping.ListManager:Delete(listName)
end

StaticPopupDialogs[AuctionHouseHelper.Constants.DialogNames.DeleteShoppingList] = {
  text = "",
  button1 = ACCEPT,
  button2 = CANCEL,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1,
  OnShow = function(self)
    AuctionHouseHelper.EventBus:RegisterSource(self, "Delete Shopping List Dialog")
  end,
  OnHide = function(self)
    AuctionHouseHelper.EventBus:UnregisterSource(self)
  end,
  OnAccept = function(self)
    DeleteList(self, self.data)
  end
}

local function RenameList(self, newListName)
  local currentList = AuctionHouseHelper.Shopping.ListManager:GetByName(self.data)
  if newListName ~= currentList:GetName() then
    newListName = AuctionHouseHelper.Shopping.ListManager:GetUnusedName(newListName)

    currentList:Rename(newListName)
  end

  if currentList.isTemporary then
    currentList:MakePermanent()
  end

  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.ListRenamed, currentList)
end

StaticPopupDialogs[AuctionHouseHelper.Constants.DialogNames.RenameShoppingList] = {
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 32,
  OnShow = function(self)
    AuctionHouseHelper.EventBus:RegisterSource(self, "Rename Shopping List Dialog")

    self.editBox:SetText("")
    self.editBox:SetFocus()
  end,
  OnHide = function(self)
    AuctionHouseHelper.EventBus:UnregisterSource(self)
  end,
  OnAccept = function(self)
    RenameList(self, self.editBox:GetText())
  end,
  EditBoxOnEnterPressed = function(self)
    RenameList(self:GetParent(), self:GetText())
    self:GetParent():Hide()
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}
