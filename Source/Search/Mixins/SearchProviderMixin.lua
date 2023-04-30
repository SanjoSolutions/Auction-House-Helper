AuctionHouseHelperSearchProviderMixin = {}

-- Derive
function AuctionHouseHelperSearchProviderMixin:OnSearchEventReceived(eventName, ...)
end

-- Derive
function AuctionHouseHelperSearchProviderMixin:CreateSearchTerm(term)
end

-- Derive
function AuctionHouseHelperSearchProviderMixin:GetSearchProvider()
end

-- Derive
function AuctionHouseHelperSearchProviderMixin:RegisterProviderEvents()
end

-- Derive
function AuctionHouseHelperSearchProviderMixin:UnregisterProviderEvents()
end

-- Derive
function AuctionHouseHelperSearchProviderMixin:HasCompleteTermResults()
end

-- Derive
function AuctionHouseHelperSearchProviderMixin:GetCurrentEmptyResult()
end

function AuctionHouseHelperSearchProviderMixin:RegisterEvents(events)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperSearchProviderMixin:RegisterEvents()", events)

  FrameUtil.RegisterFrameForEvents(self, events)
end

function AuctionHouseHelperSearchProviderMixin:UnregisterEvents(events)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperSearchProviderMixin:UnregisterEvents()", events)

  FrameUtil.UnregisterFrameForEvents(self, events)
end

function AuctionHouseHelperSearchProviderMixin:SetTerms(terms, config)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperSearchProviderMixin:SetTerms()", terms, config)

  self.terms = terms
  self.config = config or {}
  self.index = 1
end

function AuctionHouseHelperSearchProviderMixin:GetCurrentSearchIndex()
  return self.index
end

function AuctionHouseHelperSearchProviderMixin:GetSearchTermCount()
  return #self.terms
end

function AuctionHouseHelperSearchProviderMixin:HasMoreTerms()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperSearchProviderMixin:HasMoreTerms()")

  return
    self.terms ~= nil and
    #self.terms > 0 and
    self.index ~= nil and
    self.index <= #self.terms
end

function AuctionHouseHelperSearchProviderMixin:GetNextSearchParameter()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperSearchProviderMixin:GetNextSearchParameter()")

  if self:HasMoreTerms() then
    self.index = self.index + 1

    return self:CreateSearchTerm(self.terms[self.index - 1], self.config)
  else
    error("You requested a term that does not exist: " .. (self.index == nil and "nil" or self.index))
  end
end

function AuctionHouseHelperSearchProviderMixin:GetCurrentSearchParameter()
  return self.terms[self.index - 1]
end
