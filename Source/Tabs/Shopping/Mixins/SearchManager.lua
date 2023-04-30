AuctionHouseHelperShoppingSearchManagerMixin = {}

local SearchForTerms = AuctionHouseHelper.Shopping.Tab.Events.SearchForTerms
local CancelSearch = AuctionHouseHelper.Shopping.Tab.Events.CancelSearch

function AuctionHouseHelperShoppingSearchManagerMixin:OnLoad()
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelper Shopping List Search Manager")
  AuctionHouseHelper.EventBus:Register(self, {
    SearchForTerms, CancelSearch, AuctionHouseHelper.Shopping.Events.ListItemChange, AuctionHouseHelper.Shopping.Events.ListMetaChange
  })

  self.searchProvider = CreateFrame("FRAME", nil, nil, "AuctionHouseHelperDirectSearchProviderTemplate")
  self.searchProvider:InitSearch(
    function(results)
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded, results)
    end,
    function(current, total, partialResults)
      AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.ListSearchIncrementalUpdate, partialResults, total, current)
    end
  )
end

function AuctionHouseHelperShoppingSearchManagerMixin:ReceiveEvent(eventName, ...)
  if eventName == SearchForTerms then
    local searchTerms, config = ...
    self:DoSearch(searchTerms, config)

  else
    self.searchProvider:AbortSearch()
  end
end

function AuctionHouseHelperShoppingSearchManagerMixin:OnHide()
  self.searchProvider:AbortSearch()
end

function AuctionHouseHelperShoppingSearchManagerMixin:DoSearch(searchTerms, config)
  self.searchProvider:AbortSearch()

  AuctionHouseHelper.EventBus:Fire(
    self,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted
  )

  self.searchProvider:Search(searchTerms, config)
end
