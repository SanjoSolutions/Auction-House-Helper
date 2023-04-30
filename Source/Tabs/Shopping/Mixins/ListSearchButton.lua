AuctionHouseHelperListSearchButtonMixin = {}

function AuctionHouseHelperListSearchButtonMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperListSearchButtonMixin:OnLoad()")

  DynamicResizeButton_Resize(self)
  self.listSelected = false
  self.searchRunning = false
  self:Disable()

  self:SetUpEvents()
end

function AuctionHouseHelperListSearchButtonMixin:SetUpEvents()
  -- AuctionHouseHelper Events
  AuctionHouseHelper.EventBus:RegisterSource(self, "List Search Button")

  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Shopping.Tab.Events.ListSelected,
    AuctionHouseHelper.Shopping.Tab.Events.ListCreated,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted,
    AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded
  })
end

function AuctionHouseHelperListSearchButtonMixin:OnClick()
  if not self.searchRunning then
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.ListSearchRequested)
  else
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Shopping.Tab.Events.CancelSearch)
  end
end

function AuctionHouseHelperListSearchButtonMixin:ReceiveEvent(eventName, eventData)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperListSearchButtonMixin:ReceiveEvent " .. eventName, eventData)

  if eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSelected then
    self.listSelected = true
    self:Enable()

  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListCreated then
    self:Enable()

  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchStarted then
    self.searchRunning = true

    self:SetText(AUCTION_HOUSE_HELPER_L_CANCEL_SEARCH)
    self:SetWidth(0)
    DynamicResizeButton_Resize(self)

  elseif eventName == AuctionHouseHelper.Shopping.Tab.Events.ListSearchEnded then
    self.searchRunning = false

    self:SetText(AUCTION_HOUSE_HELPER_L_SEARCH_ALL)
    self:SetWidth(0)
    DynamicResizeButton_Resize(self)

    if self.listSelected then
      self:Enable()
    end
  end
end
