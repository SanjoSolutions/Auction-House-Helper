AuctionHouseHelperKeywordSearchProviderMixin = CreateFromMixins(AuctionHouseHelperMultiSearchMixin, AuctionHouseHelperSearchProviderMixin)

local KEYWORD_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE"
}

function AuctionHouseHelperKeywordSearchProviderMixin:CreateSearchTerm(term)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperKeywordSearchProviderMixin:CreateSearchTerm()", term)

  return  {
    searchString = term,
    filters = {},
    itemClassFilters = {},
    sorts = {}
  }
end

function AuctionHouseHelperKeywordSearchProviderMixin:GetSearchProvider()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperKeywordSearchProviderMixin:GetSearchProvider()")

  return C_AuctionHouse.SendBrowseQuery
end

function AuctionHouseHelperKeywordSearchProviderMixin:HasCompleteTermResults()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperKeywordSearchProviderMixin:HasCompleteTermResults()")
  return C_AuctionHouse.HasFullBrowseResults()
end

function AuctionHouseHelperKeywordSearchProviderMixin:OnSearchEventReceived(eventName, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperKeywordSearchProviderMixin:OnSearchEventReceived()", eventName, ...)

  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:ProcessSearchResults(C_AuctionHouse.GetBrowseResults())
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:ProcessSearchResults(...)
  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" then
    AuctionHouseFrame.BrowseResultsFrame.ItemList:SetCustomError(
      RED_FONT_COLOR:WrapTextInColorCode(ERR_AUCTION_DATABASE_ERROR)
    )
  end
end

function AuctionHouseHelperKeywordSearchProviderMixin:ProcessSearchResults(addedResults)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperKeywordSearchProviderMixin:ProcessSearchResults()")

  self:AddResults(addedResults)
end

function AuctionHouseHelperKeywordSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(KEYWORD_SEARCH_EVENTS)
end

function AuctionHouseHelperKeywordSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(KEYWORD_SEARCH_EVENTS)
end
