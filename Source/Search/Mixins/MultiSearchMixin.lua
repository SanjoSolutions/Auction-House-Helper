AuctionHouseHelperMultiSearchMixin = {}

function AuctionHouseHelperMultiSearchMixin:InitSearch(completionCallback, incrementCallback)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperMultiSearchMixin:InitSearch()")

  self.complete = true
  self.onSearchComplete = completionCallback or function()
    AuctionHouseHelper.Debug.Message("Search completed.")
  end
  self.onNextSearch = incrementCallback or function()
    AuctionHouseHelper.Debug.Message("Next search.")
  end
end

function AuctionHouseHelperMultiSearchMixin:OnEvent(event, ...)
  self:OnSearchEventReceived(event, ...)
end

function AuctionHouseHelperMultiSearchMixin:Search(terms, config)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperMultiSearchMixin:Search()", terms)

  self.complete = false
  self.partialResults = {}
  self.fullResults = {}
  self.anyResultsForThisTerm = false

  self:RegisterProviderEvents()

  self:SetTerms(terms, config)
  self:NextSearch()
end

function AuctionHouseHelperMultiSearchMixin:AbortSearch()
  self:UnregisterProviderEvents()
  local isComplete = self.complete
  self.complete = true
  if not isComplete then
    self.onSearchComplete(self.fullResults)
  end
end

function AuctionHouseHelperMultiSearchMixin:AddResults(results)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperSearchProviderMixin:AddResults()")

  if #results > 0 then
    self.anyResultsForThisTerm = true
  end

  for index = 1, #results do
    table.insert(self.partialResults, results[index])
    table.insert(self.fullResults, results[index])
  end

  if self:HasCompleteTermResults() then
    self:NextSearch()
  end
end

function AuctionHouseHelperMultiSearchMixin:NoResultsForTermCheck()
  if not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SHOPPING_LIST_MISSING_TERMS) then
    return
  end

  if self:GetCurrentSearchParameter() and not self.anyResultsForThisTerm then
    local emptyResult = self:GetCurrentEmptyResult()
    table.insert(self.partialResults, emptyResult)
    table.insert(self.fullResults, emptyResult)
  end
end

function AuctionHouseHelperMultiSearchMixin:NextSearch()
  if self:HasMoreTerms() then
    self:NoResultsForTermCheck()
    self.anyResultsForThisTerm = false

    self.onNextSearch(
      self:GetCurrentSearchIndex(),
      self:GetSearchTermCount(),
      self.partialResults
    )
    self.partialResults = {}
    self:GetSearchProvider()(self:GetNextSearchParameter())
  else
    AuctionHouseHelper.Debug.Message("AuctionHouseHelperMultiSearchMixin:NextSearch Complete")

    self:NoResultsForTermCheck()

    self:UnregisterProviderEvents()

    self.complete = true
    self.onSearchComplete(self.fullResults)
  end
end
