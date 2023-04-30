AuctionHouseHelperShoppingListMixin = {}

function AuctionHouseHelperShoppingListMixin:Init(data, manager)
  assert(data)
  self.data = data
  self.manager = manager
end

function AuctionHouseHelperShoppingListMixin:GetName()
  return self.data.name
end

function AuctionHouseHelperShoppingListMixin:Rename(newName)
  assert(type(newName) == "string")
  assert(self.manager:GetIndexForName(newName) == nil, "New name already in use")

  self.data.name = newName

  self.manager:FireMetaChangeEvent(self:GetName())
end

function AuctionHouseHelperShoppingListMixin:IsTemporary()
  return self.data.isTemporary
end

function AuctionHouseHelperShoppingListMixin:MakePermanent()
  self.data.isTemporary = false

  self.manager:FireMetaChangeEvent(self:GetName())
end

function AuctionHouseHelperShoppingListMixin:GetItemCount()
  return #self.data.items
end

function AuctionHouseHelperShoppingListMixin:GetItemByIndex(index)
  return self.data.items[index]
end

function AuctionHouseHelperShoppingListMixin:GetIndexForItem(item)
  return tIndexOf(self.data.items, item)
end

function AuctionHouseHelperShoppingListMixin:GetAllItems()
  return CopyTable(self.data.items)
end

function AuctionHouseHelperShoppingListMixin:DeleteItem(index)
  assert(self.data.items[index], "Nonexistent item")
  table.remove(self.data.items, index)

  self.manager:FireItemChangeEvent(self:GetName())
end

function AuctionHouseHelperShoppingListMixin:AlterItem(index, newItem)
  assert(self.data.items[index], "Nonexistent item")
  assert(type(newItem) == "string")

  self.data.items[index] = newItem

  self.manager:FireItemChangeEvent(self:GetName())
end

function AuctionHouseHelperShoppingListMixin:InsertItem(newItem, index)
  assert(type(newItem) == "string")
  if index ~= nil then
    table.insert(self.data.items, index, newItem)
  else
    table.insert(self.data.items, newItem)
  end

  self.manager:FireItemChangeEvent(self:GetName())
end

function AuctionHouseHelperShoppingListMixin:Sort()
  table.sort(self.data.items, function(a, b)
    return a:lower():gsub("\"", "") < b:lower():gsub("\"", "")
  end)
  self.manager:FireItemChangeEvent(self:GetName())
end
