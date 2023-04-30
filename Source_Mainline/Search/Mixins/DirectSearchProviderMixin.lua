AuctionHouseHelperDirectSearchProviderMixin = CreateFromMixins(AuctionHouseHelperMultiSearchMixin, AuctionHouseHelperSearchProviderMixin)

local ADVANCED_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE",
  "GET_ITEM_INFO_RECEIVED",
  "EXTRA_BROWSE_INFO_RECEIVED",
}

local INTERNAL_SEARCH_EVENTS = {
  AuctionHouseHelper.Search.Events.SearchResultsReady
}

local QUALITY_TO_FILTER = {
  [Enum.ItemQuality.Poor] = Enum.AuctionHouseFilter.PoorQuality,
  [Enum.ItemQuality.Common] = Enum.AuctionHouseFilter.CommonQuality,
  [Enum.ItemQuality.Uncommon] = Enum.AuctionHouseFilter.UncommonQuality,
  [Enum.ItemQuality.Rare] = Enum.AuctionHouseFilter.RareQuality,
  [Enum.ItemQuality.Epic] = Enum.AuctionHouseFilter.EpicQuality,
  [Enum.ItemQuality.Legendary] = Enum.AuctionHouseFilter.LegendaryQuality,
  [Enum.ItemQuality.Artifact] = Enum.AuctionHouseFilter.ArtifactQuality,
}

local function GetQualityFilters(quality)
  if QUALITY_TO_FILTER[quality] ~= nil then
    return { QUALITY_TO_FILTER[quality] }
  else
    return {}
  end
end

function AuctionHouseHelperDirectSearchProviderMixin:CreateSearchTerm(term)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperDirectSearchProviderMixin:CreateSearchTerm()", term)

  local parsed = AuctionHouseHelper.Search.SplitAdvancedSearch(term)

  return {
    query = {
      searchString = parsed.searchString,
      minLevel = parsed.minLevel,
      maxLevel = parsed.maxLevel,
      filters = GetQualityFilters(parsed.quality),
      itemClassFilters = AuctionHouseHelper.Search.GetItemClassCategories(parsed.categoryKey),
      sorts = AuctionHouseHelper.Constants.ShoppingSorts,
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
      exactSearch = (parsed.isExact and parsed.searchString) or nil,
      expansion = parsed.expansion,
      tier = parsed.tier,
    }
  }
end

function AuctionHouseHelperDirectSearchProviderMixin:GetSearchProvider()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperDirectSearchProviderMixin:GetSearchProvider()")

  --Run the query, and save extra filter data for processing
  return function(searchTerm)
    AuctionHouseHelper.AH.SendBrowseQuery(searchTerm.query)
    self.currentFilter = searchTerm.extraFilters
    self.waiting = 0
  end
end

function AuctionHouseHelperDirectSearchProviderMixin:HasCompleteTermResults()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperDirectSearchProviderMixin:HasCompleteTermResults()")

  --Loaded all the terms from API, and we have filtered every item
  return AuctionHouseHelper.AH.HasFullBrowseResults() and self.waiting == 0
end

function AuctionHouseHelperDirectSearchProviderMixin:GetCurrentEmptyResult()
  return AuctionHouseHelper.Search.GetEmptyResult(self:GetCurrentSearchParameter(), self:GetCurrentSearchIndex())
end

function AuctionHouseHelperDirectSearchProviderMixin:OnSearchEventReceived(eventName, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperDirectSearchProviderMixin:OnSearchEventReceived()", eventName, ...)

  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:ProcessSearchResults(C_AuctionHouse.GetBrowseResults())
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:ProcessSearchResults(...)
  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" then
    AuctionHouseFrame.BrowseResultsFrame.ItemList:SetCustomError(
      RED_FONT_COLOR:WrapTextInColorCode(ERR_AUCTION_DATABASE_ERROR)
    )
  else
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "AuctionHouseHelperDirectSearchProviderMixin")
      :Fire(self, AuctionHouseHelper.Search.Events.BlizzardInfo, eventName, ...)
      :UnregisterSource(self)
  end
end

function AuctionHouseHelperDirectSearchProviderMixin:ProcessSearchResults(addedResults)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperDirectSearchProviderMixin:ProcessSearchResults()")
  
  if not self.registeredForEvents then
    self.registeredForEvents = true
    AuctionHouseHelper.EventBus:Register(self, INTERNAL_SEARCH_EVENTS)
  end

  if not AuctionHouseHelper.AH.HasFullBrowseResults() then
    AuctionHouseHelper.AH.RequestMoreBrowseResults()
  end

  self.waiting = self.waiting + #addedResults
  for index = 1, #addedResults do
    local filterTracker = CreateAndInitFromMixin(
      AuctionHouseHelper.Search.Filters.FilterTrackerMixin,
      addedResults[index]
    )
    local filters = AuctionHouseHelper.Search.Filters.Create(addedResults[index], self.currentFilter, filterTracker)

    filterTracker:SetWaiting(#filters)
  end

  if #addedResults == 0 then
    self:AddResults({})
  end
end

function AuctionHouseHelperDirectSearchProviderMixin:ReceiveEvent(eventName, results)
  if eventName == AuctionHouseHelper.Search.Events.SearchResultsReady then
    self.waiting = self.waiting - 1
    if self:HasCompleteTermResults() then
      self.registeredForEvents = false
      AuctionHouseHelper.EventBus:Unregister(self, INTERNAL_SEARCH_EVENTS)
    end
    self:AddResults(results)
  end
end


function AuctionHouseHelperDirectSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(ADVANCED_SEARCH_EVENTS)
end

function AuctionHouseHelperDirectSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(ADVANCED_SEARCH_EVENTS)
  if self.registeredForEvents then
    self.registeredForEvents = false
    AuctionHouseHelper.EventBus:Unregister(self, INTERNAL_SEARCH_EVENTS)
  end
end
