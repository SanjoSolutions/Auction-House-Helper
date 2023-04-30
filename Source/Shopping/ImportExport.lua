function AuctionHouseHelper.Shopping.Lists.GetBatchExportString(listName)
  local items = AuctionHouseHelper.Shopping.ListManager:GetByName(listName):GetAllItems()

  local result = listName
  for _, item in ipairs(items) do
    result = result .. "^" .. item
  end

  return result
end

--Import multiple instance of lists in the format
--  list name^item 1^item 2\n
function AuctionHouseHelper.Shopping.Lists.BatchImportFromString(importString)
  -- Remove blank lines
  importString = gsub(importString, "%s+\n", "\n")
  importString = gsub(importString, "\n+", "\n")

  local lists = {strsplit("\n", importString)}

  for index, list in ipairs(lists) do
    local name, items = strsplit("^", list, 2)

    if AuctionHouseHelper.Shopping.ListManager:GetIndexForName(name) == nil and name ~= nil and name:len() > 0 then
      AuctionHouseHelper.Shopping.ListManager:Create(name)
    end

    AuctionHouseHelper.Shopping.Lists.OneImportFromString(name, items)

    if name ~= nil and name:len() > 0 then
      AuctionHouseHelper.EventBus
        :RegisterSource(AuctionHouseHelper.Shopping.Lists.BatchImportFromString, "BatchImportFromString")
        :Fire(AuctionHouseHelper.Shopping.Lists.BatchImportFromString, AuctionHouseHelper.Shopping.Events.ListImportFinished, name)
        :UnregisterSource(AuctionHouseHelper.Shopping.Lists.BatchImportFromString)
    end
  end
end

function AuctionHouseHelper.Shopping.Lists.OneImportFromString(listName, importString)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelper.Shopping.Lists.OneImportFromString()", listName, importString)

  if importString == nil then
    -- Otherwise import throws when there are not items in a list
    return
  end

  local list = AuctionHouseHelper.Shopping.ListManager:GetByName(listName)

  for _, item in ipairs({strsplit("^", importString)}) do
    list:InsertItem(item)
  end
end

--Import multiple instances of lists in the format
-- **List Name\n
-- Item 1\n
-- Item 2\n
function AuctionHouseHelper.Shopping.Lists.OldBatchImportFromString(importString)
  -- Remove trailing and leading spaces
  importString = gsub(importString, "%s+\n", "\n")
  importString = gsub(importString, "\n%s+", "\n")
  -- Remove blank lines
  importString = gsub(importString, "\n\n", "\n")
  importString = gsub(importString, "^\n", "")
  -- Simplify *** to *
  importString = gsub(importString, "*+%s*", "*")
  -- Remove first *
  importString = gsub(importString, "^*", "")

  local lists = {strsplit("*", importString)}

  for index, list in ipairs(lists) do
    local name, items = strsplit("\n", list, 2)

    if AuctionHouseHelper.Shopping.Lists.ListIndex(name) == nil then
      AuctionHouseHelper.Shopping.Lists.Create(name)
    end

    AuctionHouseHelper.Shopping.Lists.OldOneImportFromString(name, items)

    AuctionHouseHelper.EventBus
      :RegisterSource(AuctionHouseHelper.Shopping.Lists.OldBatchImportFromString, "OldBatchImportFromString")
      :Fire(AuctionHouseHelper.Shopping.Lists.OldBatchImportFromString, AuctionHouseHelper.Shopping.Events.ListImportFinished, name)
      :UnregisterSource(AuctionHouseHelper.Shopping.Lists.OldBatchImportFromString)
  end
end

function AuctionHouseHelper.Shopping.Lists.OldOneImportFromString(listName, importString)
  local list = AuctionHouseHelper.Shopping.ListManager:GetByName(listName)

  importString = gsub(importString, "\n$", "")

  for _, item in ipairs({strsplit("\n", importString)}) do
    list:InsertItem(item)
  end
end

local TSMImportName = AUCTION_HOUSE_HELPER_L_IMPORTED .. " (" .. AUCTION_HOUSE_HELPER_L_TEMPORARY_LOWER_CASE .. ")"
local IMPORT_ERROR = "IMPORT ERROR"

--Import a TSM group in the format
--  i:itemID 1,i:itemID 2 OR
--  itemID 1,itemID 2
--
--Saves the result in a temporary list and fires a list creation event.
function AuctionHouseHelper.Shopping.Lists.TSMImportFromString(importString)
  -- Remove line breaks
  importString = gsub(importString, "\n", "")

  local itemStrings = {strsplit(",", importString)}
  local left = #itemStrings
  local items = {}

  local function OnFinish()
    if AuctionHouseHelper.Shopping.ListManager:GetIndexForName(TSMImportName) ~= nil then
      AuctionHouseHelper.Shopping.ListManager:Delete(TSMImportName)
    end

    AuctionHouseHelper.Shopping.ListManager:Create(TSMImportName, true)

    local list = AuctionHouseHelper.Shopping.ListManager:GetByName(TSMImportName)

    for _, i in ipairs(items) do
      list:InsertItem(i)
    end

    AuctionHouseHelper.EventBus
      :RegisterSource(AuctionHouseHelper.Shopping.Lists.TSMImportFromString, "TSMImportFromString")
      :Fire(AuctionHouseHelper.Shopping.Lists.TSMImportFromString, AuctionHouseHelper.Shopping.Events.ListImportFinished, list:GetName())
      :UnregisterSource(AuctionHouseHelper.Shopping.Lists.TSMImportFromString)
  end

  for index, itemString in ipairs(itemStrings) do
    --TSM uses the same format for normal items and pets, so we try to load an
    --item with the ID first, if that doesn't work, then we try loading a pet.
    local itemType, stringID = string.match(itemString, "^([ip]):(%d+)$")

    local id = tonumber(stringID) or tonumber(itemString)

    local item = Item:CreateFromItemID(id)

    if itemType == "p" or item:IsItemEmpty() then
      item = Item:CreateFromItemID(AuctionHouseHelper.Constants.PET_CAGE_ID)
    end
    if item:IsItemEmpty() then
      items[index] = IMPORT_ERROR
    else
      item:ContinueOnItemLoad(function()
        items[index] = GetItemInfo(id)
        if itemType == "p" or items[index] == nil then
          items[index] = C_PetJournal.GetPetInfoBySpeciesID(id)
          if type(items[index]) ~= "string" then
            items[index] = nil
          end
        end

        if items[index] == nil then
          items[index] = IMPORT_ERROR
        end

        left = left - 1
        if left == 0 then
          OnFinish()
        end
      end)
    end
  end
  -- Check for case when item data is missing from the Blizzard item database so
  -- that some kind of list is imported
  C_Timer.After(2, function()
    if left > 0 then
      left = 0
      for index in ipairs(itemStrings) do
        if items[index] == nil then
          items[index] = IMPORT_ERROR
        end
      end
      OnFinish()
    end
  end)
end
