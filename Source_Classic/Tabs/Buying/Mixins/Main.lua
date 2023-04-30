AuctionHouseHelperBuyFrameMixin = {}

function AuctionHouseHelperBuyFrameMixin:Init()
  AuctionHouseHelper.EventBus:RegisterSource(self, "AuctionHouseHelperBuyFrameMixin")
  self.CurrentPrices:Init()
  self.HistoryPrices:Init()
end

function AuctionHouseHelperBuyFrameMixin:Reset()
  if self.HistoryPrices:IsShown() then
    self:ToggleHistory()
  end

  self.HistoryPrices:Reset()
  self.CurrentPrices:Reset()
end

function AuctionHouseHelperBuyFrameMixin:ToggleHistory()
  self.HistoryPrices:SetShown(not self.HistoryPrices:IsShown())
  self.CurrentPrices:SetShown(not self.CurrentPrices:IsShown())

  if self.HistoryPrices:IsShown() then
    self.HistoryButton:SetText(AUCTION_HOUSE_HELPER_L_CURRENT)
  else
    self.HistoryButton:SetText(AUCTION_HOUSE_HELPER_L_HISTORY)
  end
end

AuctionHouseHelperBuyFrameMixinForShopping = CreateFromMixins(AuctionHouseHelperBuyFrameMixin)

function AuctionHouseHelperBuyFrameMixinForShopping:Init()
  AuctionHouseHelperBuyFrameMixin.Init(self)
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Buying.Events.ShowForShopping,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted,
  })
end

function AuctionHouseHelperBuyFrameMixinForShopping:OnShow()
  self:GetParent().ResultsListing:Hide()
  self:GetParent().ExportCSV:Hide()
  self:GetParent().ShoppingResultsInset:Hide()
  self.wasParentLoadAllPagesVisible = self:GetParent().LoadAllPagesButton:IsShown()
  self:GetParent().LoadAllPagesButton:Hide()
end

function AuctionHouseHelperBuyFrameMixinForShopping:OnHide()
  self:Hide()

  self:GetParent().ResultsListing:Show()
  self:GetParent().ExportCSV:Show()
  self:GetParent().ShoppingResultsInset:Show()
  self:GetParent().LoadAllPagesButton:SetShown(self.wasParentLoadAllPagesVisible)
end

function AuctionHouseHelperBuyFrameMixinForShopping:ReceiveEvent(eventName, eventData, ...)
  if eventName == AuctionHouseHelper.Buying.Events.ShowForShopping then
    self:Show()

    self:Reset()

    if #eventData.entries > 0 then
      self.CurrentPrices.SearchDataProvider:SetQuery(eventData.entries[1].itemLink)
      self.HistoryPrices.RealmHistoryDataProvider:SetItemLink(eventData.entries[1].itemLink)
      self.HistoryPrices.PostingHistoryDataProvider:SetItemLink(eventData.entries[1].itemLink)
    else
      self.CurrentPrices.SearchDataProvider:SetQuery(nil)
      self.HistoryPrices.RealmHistoryDataProvider:SetItemLink(nil)
      self.HistoryPrices.PostingHistoryDataProvider:SetItemLink(nil)
    end
    self.CurrentPrices.SearchDataProvider:SetAuctions(eventData.entries)

    self.CurrentPrices.SearchDataProvider:SetRequestAllResults(false)
    if not eventData.complete and #eventData.entries < AuctionHouseHelper.Constants.MaxResultsPerPage then
      self.CurrentPrices.SearchDataProvider:RefreshQuery()
    else
      self.CurrentPrices.gotCompleteResults = eventData.complete
      self.CurrentPrices:UpdateButtons()
    end
  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted then
    self:Hide()
  end
end

AuctionHouseHelperBuyFrameMixinForSelling = CreateFromMixins(AuctionHouseHelperBuyFrameMixin)
local AUCTION_EVENTS = {
  "AUCTION_OWNED_LIST_UPDATE",
}

function AuctionHouseHelperBuyFrameMixinForSelling:Init()
  AuctionHouseHelperBuyFrameMixin.Init(self)
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Selling.Events.RefreshBuying,
    AuctionHouseHelper.Selling.Events.RefreshHistoryOnly,
    AuctionHouseHelper.Selling.Events.StartFakeBuyLoading,
    AuctionHouseHelper.Selling.Events.StopFakeBuyLoading,
    AuctionHouseHelper.Selling.Events.AuctionCreated,
  })
end

function AuctionHouseHelperBuyFrameMixinForSelling:Reset()
  AuctionHouseHelperBuyFrameMixin.Reset(self)

  self.waitingOnNewAuction = false
end

function AuctionHouseHelperBuyFrameMixinForSelling:OnShow()
  FrameUtil.RegisterFrameForEvents(self, AUCTION_EVENTS)
  self:Reset()
end

function AuctionHouseHelperBuyFrameMixinForSelling:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, AUCTION_EVENTS)
end

function AuctionHouseHelperBuyFrameMixinForSelling:ReceiveEvent(eventName, eventData, ...)
  if eventName == AuctionHouseHelper.Selling.Events.RefreshBuying then
    self:Reset()

    self.HistoryPrices.RealmHistoryDataProvider:SetItemLink(eventData.itemLink)
    self.HistoryPrices.PostingHistoryDataProvider:SetItemLink(eventData.itemLink)
    self.CurrentPrices.SearchDataProvider:SetQuery(eventData.itemLink)
    self.CurrentPrices.SearchDataProvider:SetRequestAllResults(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_ALWAYS_LOAD_MORE))
    self.CurrentPrices.SearchDataProvider:RefreshQuery()

    self.CurrentPrices.RefreshButton:Enable()
    self.HistoryButton:Enable()
  elseif eventName == AuctionHouseHelper.Selling.Events.RefreshHistoryOnly then
    self.HistoryPrices.RealmHistoryDataProvider:SetItemLink(eventData.itemLink)
    self.HistoryPrices.PostingHistoryDataProvider:SetItemLink(eventData.itemLink)
  elseif eventName == AuctionHouseHelper.Selling.Events.StartFakeBuyLoading then
    -- Used so that it is clear something is loading, even if the search can't
    -- be sent yet.
    self.HistoryPrices.RealmHistoryDataProvider:SetItemLink(eventData.itemLink)
    self.HistoryPrices.PostingHistoryDataProvider:SetItemLink(eventData.itemLink)
    self.CurrentPrices.SearchDataProvider:SetQuery(eventData.itemLink)
    self.CurrentPrices.SearchDataProvider.onSearchStarted()
  elseif eventName == AuctionHouseHelper.Selling.Events.StopFakeBuyLoading then
    self.CurrentPrices.SearchDataProvider.onSearchEnded()
    self:Reset()
    self.CurrentPrices.RefreshButton:Disable()
    self.HistoryButton:Disable()
  elseif eventName == AuctionHouseHelper.Selling.Events.AuctionCreated then
    self.waitingOnNewAuction = true
  end
end

function AuctionHouseHelperBuyFrameMixinForSelling:OnEvent(eventName, ...)
  if eventName == "AUCTION_OWNED_LIST_UPDATE" and self.waitingOnNewAuction then
    self.waitingOnNewAuction = false
    self.CurrentPrices.SearchDataProvider:PurgeAndReplaceOwnedAuctions(AuctionHouseHelper.AH.DumpAuctions("owner"))
  end
end
