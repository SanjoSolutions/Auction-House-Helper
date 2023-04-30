local function ValidateState(callerID, searchTerms)
  AuctionHouseHelper.API.InternalVerifyID(callerID)

  --Validate arguments
  local cloned = AuctionHouseHelper.Utilities.VerifyListTypes(searchTerms, "string")
  if not cloned then
    AuctionHouseHelper.API.ComposeError(
      callerID, "Usage AuctionHouseHelper.API.v1.MultiSearch(string, string[])"
    )
  end

  for _, term in ipairs(cloned) do
    if string.match(term, "^%s*\".*\"%s*$") or string.match(term, ";") then
      AuctionHouseHelper.API.ComposeError(
        callerID, "Search term contains ; or is wrapped in \""
      )
    end
  end

  -- Validate state
  if (not AuctionHouseFrame or not AuctionHouseFrame:IsShown()) and
     (not AuctionFrame      or not AuctionFrame:IsShown()) then
    AuctionHouseHelper.API.ComposeError(callerID, "Auction house is not open")
  end

  return cloned
end

local function StartSearch(callerID, cloned)
  -- Show the shopping list tab for results
  AuctionHouseHelperTabs_Shopping:Click()

  local listName = callerID .. " (" .. AUCTION_HOUSE_HELPER_L_TEMPORARY_LOWER_CASE .. ")"

  -- Remove any old searches
  if AuctionHouseHelper.Shopping.ListManager:GetIndexForName(listName) ~= nil then
    AuctionHouseHelper.Shopping.ListManager:Delete(listName)
  end

  AuctionHouseHelper.Shopping.ListManager:Create(listName, true)

  local list = AuctionHouseHelper.Shopping.ListManager:GetByName(listName)

  for _, item in ipairs(cloned) do
    list:InsertItem(item)
  end

  AuctionHouseHelper.EventBus:RegisterSource(StartSearch, "API v1 Multi search start")
    :Fire(StartSearch, AuctionHouseHelper.Shopping.Tab.Events.ListCreated, list)
    :Fire(StartSearch, AuctionHouseHelper.Shopping.Tab.Events.ListSearchRequested, list)
    :UnregisterSource(StartSearch)
end

function AuctionHouseHelper.API.v1.MultiSearch(callerID, searchTerms)
  local cloned = ValidateState(callerID, searchTerms)
  StartSearch(callerID, cloned)
end

function AuctionHouseHelper.API.v1.MultiSearchExact(callerID, searchTerms)
  local cloned = ValidateState(callerID, searchTerms)
  -- Make all the terms advanced search terms  which are exact
  for index, term in ipairs(cloned) do
    cloned[index] = '"' .. term .. '"'
  end

  StartSearch(callerID, cloned)
end
