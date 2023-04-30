AuctionHouseHelperShoppingListManagerMixin = {}

-- getData: function() -> table. Returns raw shopping list data storage
-- setData: function(newVal) newVal: table -> nil. Used to overwrite the
--  shopping list data storage with new data
function AuctionHouseHelperShoppingListManagerMixin:Init(getData, setData)
  assert(type(getData) == "function" and type(setData) == "function")
  self.getData = getData
  self.setData = setData

  if self.getData() == nil then
    self.setData({})
  end

  AuctionHouseHelper.EventBus:RegisterSource(self, "shopping list manager")

  self:Prune()
  self:Sort()
end

function AuctionHouseHelperShoppingListManagerMixin:Create(listName, isTemporary)
  isTemporary = isTemporary or false

  assert(type(listName) == "string")
  assert(type(isTemporary) == "boolean")

  table.insert(self.getData(), {
    name = listName,
    items = {},
    isTemporary = isTemporary,
  })

  self:Sort()

  self:FireMetaChangeEvent(listName)
end

function AuctionHouseHelperShoppingListManagerMixin:Sort()
  table.sort(self.getData(), function(left, right)
    local lowerLeft = string.lower(left.name)
    local lowerRight = string.lower(right.name)

    -- Handle case where names are the same, when ignoring lettercase
    if lowerLeft == lowerRight then
      return left.name < right.name
    else
      return lowerLeft < lowerRight
    end
  end)

  self:FireMetaChangeEvent()
end

function AuctionHouseHelperShoppingListManagerMixin:Prune()
  local lists = {}

  for _, list in ipairs(self.getData()) do
    if not list.isTemporary then
      table.insert(lists, list)
    end
  end

  self.setData(lists)

  self:FireMetaChangeEvent()
end

function AuctionHouseHelperShoppingListManagerMixin:GetIndexForName(listName)
  for index, list in ipairs(self.getData()) do
    if list.name == listName then
      return index
    end
  end

  return nil
end

function AuctionHouseHelperShoppingListManagerMixin:GetCount()
  return #self.getData()
end

function AuctionHouseHelperShoppingListManagerMixin:GetByIndex(listIndex)
  local data =  self.getData()[listIndex]
  assert(data, "List index doesn't exist")

  return CreateAndInitFromMixin(AuctionHouseHelperShoppingListMixin, data, self)
end

function AuctionHouseHelperShoppingListManagerMixin:GetByName(listName)
  return self:GetByIndex(self:GetIndexForName(listName))
end

function AuctionHouseHelperShoppingListManagerMixin:Delete(listName)
  local listIndex = self:GetIndexForName(listName)
  assert(listIndex ~= nil, "List doesn't exist")

  table.remove(self.getData(), listIndex)

  self:FireMetaChangeEvent(listName)
end

function AuctionHouseHelperShoppingListManagerMixin:GetUnusedName(prefix)
  local currentIndex = 1
  local newName = prefix

  while self:GetIndexForName(newName) ~= nil do
    currentIndex = currentIndex + 1
    newName = prefix .. " " .. currentIndex
  end

  return newName
end

function AuctionHouseHelperShoppingListManagerMixin:FireItemChangeEvent(listName)
  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Events.ListItemChange, listName)
end

function AuctionHouseHelperShoppingListManagerMixin:FireMetaChangeEvent(listName)
  AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Events.ListMetaChange, listName)
end
