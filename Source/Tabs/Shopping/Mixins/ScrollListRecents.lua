AuctionHouseHelperScrollListRecentsMixin = CreateFromMixins(AuctionHouseHelperScrollListMixin)

function AuctionHouseHelperScrollListRecentsMixin:OnLoad()
  self:SetLineTemplate("AuctionHouseHelperScrollListLineRecentsTemplate")

  self:SetUpEvents()
end

function AuctionHouseHelperScrollListRecentsMixin:SetUpEvents()
  -- AuctionHouseHelper Events
  AuctionHouseHelper.EventBus:RegisterSource(self, "Shopping List Recents Scroll Frame")

  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded,
    AuctionHouseHelper.Shopping.Tab.Events.RecentSearchesUpdate,
    AuctionHouseHelper.Shopping.Tab.Events.OneItemSearch,
  })
end

function AuctionHouseHelperScrollListRecentsMixin:ReceiveEvent(eventName, eventData)
  if eventName == AuctionHouseHelper.Shopping.Tab.Events.OneItemSearch and self:IsShown() then
    self:StartSearch({ eventData }, true)
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.RecentSearchesUpdate then
    self:RefreshScrollFrame(true)
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted then
    self.SpinnerAnim:Play()
    self.LoadingSpinner:Show()
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded then
    self.LoadingSpinner:Hide()
  end
end

function AuctionHouseHelperScrollListRecentsMixin:StartSearch(searchTerms)
  AuctionHouseHelper.EventBus:Fire(
    self,
    AuctionHouseHelper.Shopping.Tab.Events.SearchForTerms,
    searchTerms
  )
end

function AuctionHouseHelperScrollListRecentsMixin:GetNumEntries()
  return #AuctionHouseHelper.Shopping.Recents.GetAll()
end

function AuctionHouseHelperScrollListRecentsMixin:GetEntry(index)
  return AuctionHouseHelper.Shopping.Recents.GetAll()[index]
end
