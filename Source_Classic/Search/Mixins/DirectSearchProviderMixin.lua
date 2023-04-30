AuctionHouseHelperDirectSearchProviderMixin = CreateFromMixins(AuctionHouseHelperMultiSearchMixin, AuctionHouseHelperSearchProviderMixin)

local SEARCH_EVENTS = {
  AuctionHouseHelper.AH.Events.ScanResultsUpdate,
  AuctionHouseHelper.AH.Events.ScanAborted,
}

local function GetPrice(entry)
  return entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.Buyout] / entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity]
end

local function GetMinPrice(entries)
  local minPrice = nil
  for _, entry in ipairs(entries) do
    local buyout = GetPrice(entry)
    if buyout ~= 0 then
      if minPrice == nil then
        minPrice = buyout
      else
        minPrice = math.min(minPrice, buyout)
      end
    end
  end
  return math.ceil(minPrice or 0)
end

local function GetQuantity(entries)
  local total = 0
  for _, entry in ipairs(entries) do
    total = total + entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity]
  end
  return total
end

local function GetOwned(entries)
  for _, entry in ipairs(entries) do
    if entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.Owner] == (GetUnitName("player")) then
      return true
    end
  end
  return false
end

local function GetIsTop(entries, minPrice)
  for _, entry in ipairs(entries) do
    if entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.Owner] == (GetUnitName("player")) and minPrice == GetPrice(entry) then
      return true
    end
  end
  return false
end

function AuctionHouseHelperDirectSearchProviderMixin:CreateSearchTerm(term, config)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperDirectSearchProviderMixin:CreateSearchTerm()", term)

  local parsed = AuctionHouseHelper.Search.SplitAdvancedSearch(term)

  return {
    query = {
      searchString = parsed.searchString,
      minLevel = parsed.minLevel,
      maxLevel = parsed.maxLevel,
      itemClassFilters = AuctionHouseHelper.Search.GetItemClassCategories(parsed.categoryKey),
      isExact = parsed.isExact,
      quality = parsed.quality, -- Blizzard API ignores this parameter, but kept in case it works again
    },
    extraFilters = {
      itemLevel = {
        min = parsed.minItemLevel,
        max = parsed.maxItemLevel,
      },
      craftedLevel = {
        min = parsed.minCraftedLevel,
        max = parsed.maxCraftedLevel,
      },
      price = {
        min = parsed.minPrice,
        max = parsed.maxPrice,
      },
      quality = parsed.quality, -- Check the quality locally because the Blizzard search API ignores quality
    },
    -- Force searchAllPages when the config UI forces it
    searchAllPages = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SHOPPING_ALWAYS_LOAD_MORE) or config.searchAllPages or false,
  }
end

function AuctionHouseHelperDirectSearchProviderMixin:GetSearchProvider()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperDirectSearchProviderMixin:GetSearchProvider()")

  --Run the query, and save extra filter data for processing
  return function(searchTerm)
    self.gotAllResults = false
    self.aborted = false
    self.searchAllPages = searchTerm.searchAllPages
    self.currentFilter = searchTerm.extraFilters
    self.resultsByKey = {}
    self.individualResults = {}

    AuctionHouseHelper.AH.QueryAuctionItems(searchTerm.query)
  end
end

function AuctionHouseHelperDirectSearchProviderMixin:HasCompleteTermResults()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperDirectSearchProviderMixin:HasCompleteTermResults()")

  return self.gotAllResults
end

function AuctionHouseHelperDirectSearchProviderMixin:GetCurrentEmptyResult()
  local r = AuctionHouseHelper.Search.GetEmptyResult(self:GetCurrentSearchParameter(), self:GetCurrentSearchIndex())
  r.complete = not self.aborted
  return r
end

function AuctionHouseHelperDirectSearchProviderMixin:AddFinalResults()
  local results = {}
  local waiting = #(AuctionHouseHelper.Utilities.TableKeys(self.resultsByKey))
  local completed = false
  local function DoComplete()
    table.sort(results, function(a, b)
      return a.minPrice > b.minPrice
    end)
    -- Handle case when no results on the first page after filters have been
    -- applied.
    if #results == 0 and self.aborted then
      table.insert(results, self:GetCurrentEmptyResult())
    end
    AuctionHouseHelper.Search.GroupResultsForDB(self.individualResults)
    self:AddResults(results)
  end

  for key, entries in pairs(self.resultsByKey) do
    local minPrice = GetMinPrice(entries)
    local possibleResult = {
      itemString = key,
      minPrice = GetMinPrice(entries),
      totalQuantity = GetQuantity(entries),
      containsOwnerItem = GetOwned(entries),
      isTopItem = GetIsTop(entries, minPrice),
      entries = entries,
      complete = not self.aborted,
    }
    local item = Item:CreateFromItemID(GetItemInfoInstant(key))
    item:ContinueOnItemLoad(function()
      waiting = waiting - 1
      if AuctionHouseHelper.Search.CheckFilters(possibleResult, self.currentFilter) then
        table.insert(results, possibleResult)
      end
      if waiting == 0 then
        completed = true
        DoComplete()
      end
    end)
  end
  if waiting == 0 and not completed then
    DoComplete()
  end
end

function AuctionHouseHelperDirectSearchProviderMixin:ProcessSearchResults(pageResults)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperDirectSearchProviderMixin:ProcessSearchResults()")
  
  for _, entry in ipairs(pageResults) do

    local itemID = entry.info[AuctionHouseHelper.Constants.AuctionItemInfo.ItemID]
    local itemString = AuctionHouseHelper.Search.GetCleanItemLink(entry.itemLink)

    if self.resultsByKey[itemString] == nil then
      self.resultsByKey[itemString] = {}
    end

    table.insert(self.resultsByKey[itemString], entry)
    table.insert(self.individualResults, entry)
  end

  if self:HasCompleteTermResults() then
    self:AddFinalResults()
  elseif not self.searchAllPages then
    self.aborted = true
    AuctionHouseHelper.AH.AbortQuery()
  end

end

function AuctionHouseHelperDirectSearchProviderMixin:ReceiveEvent(eventName, results, gotAllResults)
  if eventName == AuctionHouseHelper.AH.Events.ScanResultsUpdate then
    self.gotAllResults = gotAllResults
    self:ProcessSearchResults(results)
  elseif eventName == AuctionHouseHelper.AH.Events.ScanAborted then
    self.gotAllResults = true
    self:ProcessSearchResults({})
  end
end


function AuctionHouseHelperDirectSearchProviderMixin:RegisterProviderEvents()
  if not self.registeredOnEventBus then
    self.registeredOnEventBus = true
    AuctionHouseHelper.EventBus:Register(self, SEARCH_EVENTS)
  end
end

function AuctionHouseHelperDirectSearchProviderMixin:UnregisterProviderEvents()
  if self.registeredOnEventBus then
    self.registeredOnEventBus = false
    AuctionHouseHelper.EventBus:Unregister(self, SEARCH_EVENTS)
  end

  if not self.gotAllResults then
    AuctionHouseHelper.AH.AbortQuery()
  end
end
