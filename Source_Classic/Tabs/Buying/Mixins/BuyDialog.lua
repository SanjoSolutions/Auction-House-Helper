AuctionHouseHelperBuyDialogMixin = {}

local QUERY_EVENTS = {
  AuctionHouseHelper.AH.Events.ScanResultsUpdate,
  AuctionHouseHelper.AH.Events.ScanAborted,
}

local EVENTS = {
  AuctionHouseHelper.AH.Events.ThrottleUpdate,
}

local MONEY_EVENTS = {
  "PLAYER_MONEY",
  "UI_ERROR_MESSAGE",
  "CHAT_MSG_SYSTEM",
}

function AuctionHouseHelperBuyDialogMixin:OnLoad()
  self:RegisterForDrag("LeftButton")
  self.NumberPurchased:SetText(AUCTION_HOUSE_HELPER_L_ALREADY_PURCHASED_X:format(15))
  self.PurchaseDetails:SetText(AUCTION_HOUSE_HELPER_L_BUYING_X_FOR_X:format(BLUE_FONT_COLOR:WrapTextInColorCode("x20"), GetMoneyString(10998, true)))
  self.UnitPrice:SetText(AUCTION_HOUSE_HELPER_L_BRACKETS_X_EACH:format(GetMoneyString(550, true)))
  AuctionHouseHelper.EventBus:RegisterSource(self, "BuyDialogMixin")

  self:Reset()
end

function AuctionHouseHelperBuyDialogMixin:Reset()
  self.auctionData = nil
  self.buyInfo = nil
  self.blacklistedBefore = 0
  self.gotAllResults = true
  self.quantityPurchased = 0
  self.lastBuyStackSize = 0
end

function AuctionHouseHelperBuyDialogMixin:OnEvent(eventName, ...)
  if eventName == "PLAYER_MONEY" then
    self:UpdateButtons()
  elseif eventName == "UI_ERROR_MESSAGE" then
    local _, message = ...
    if message == ERR_ITEM_NOT_FOUND and self.buyInfo ~= nil then
      AuctionHouseHelper.Debug.Message("AuctionHouseHelperBuyDialogMixin", "failed purchase", self.buyInfo.index, self.lastBuyStackSize)
      self.lastBuyStackSize = 0
      self.blacklistedBefore = self.buyInfo.index
      self:SetDetails(self.auctionData, self.quantityPurchased, self.lastBuyStackSize, self.blacklistedBefore)
      self:LoadForPurchasing()
    end
  elseif eventName == "CHAT_MSG_SYSTEM" then
    local message = ...
    if message == ERR_AUCTION_BID_PLACED then
      self.quantityPurchased = self.quantityPurchased + self.lastBuyStackSize
      self:SetDetails(self.auctionData, self.quantityPurchased, self.lastBuyStackSize, self.blacklistedBefore)
      self:LoadForPurchasing()
    end
  end
end

function AuctionHouseHelperBuyDialogMixin:OnShow()
  AuctionHouseHelper.EventBus:Register(self, EVENTS)
  FrameUtil.RegisterFrameForEvents(self, MONEY_EVENTS)
  self.ChainBuy:SetChecked(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CHAIN_BUY_STACKS))
end

function AuctionHouseHelperBuyDialogMixin:OnHide()
  self:SetChainBuy()
  FrameUtil.UnregisterFrameForEvents(self, MONEY_EVENTS)
  if self.quantityPurchased > 0 and self.auctionData ~= nil then
    AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_PURCHASED_X_XX:format(self.auctionData.itemLink, self.quantityPurchased))
  end
  AuctionHouseHelper.EventBus:Unregister(self, EVENTS)
  AuctionHouseHelper.EventBus:Unregister(self, QUERY_EVENTS)
  self.auctionData = nil

  self.WarningDialog:Hide()
end

function AuctionHouseHelperBuyDialogMixin:UpdatePurchasedCount(newCount)
  self.NumberPurchased:SetShown(newCount ~= 0 and not self.priceWarningTimeout)
  self.NumberPurchased:SetText(AUCTION_HOUSE_HELPER_L_ALREADY_PURCHASED_X:format(newCount))
end

function AuctionHouseHelperBuyDialogMixin:SetDetails(auctionData, initialQuantityPurchased, lastBuyStackSize, blacklistedBefore)
  self:Reset()

  self.auctionData = auctionData
  self:Show()

  if self.auctionData == nil then
    self:Hide()
    return
  end

  self.quantityPurchased = initialQuantityPurchased or 0
  self.lastBuyStackSize = lastBuyStackSize or 0
  self.blacklistedBefore = blacklistedBefore or 0

  local stackText = BLUE_FONT_COLOR:WrapTextInColorCode("x" .. auctionData.stackSize)
  local priceText = GetMoneyString(auctionData.stackPrice, true)
  local unitPriceText = GetMoneyString(math.ceil(auctionData.stackPrice / auctionData.stackSize), true)
  self.PurchaseDetails:SetText(AUCTION_HOUSE_HELPER_L_BUYING_X_FOR_X:format(stackText, priceText))
  self.UnitPrice:SetText(AUCTION_HOUSE_HELPER_L_BRACKETS_X_EACH:format(unitPriceText))

  self:UpdatePurchasedCount(self.quantityPurchased)
  self:UpdateButtons()

  self:LoadForPurchasing()
end

function AuctionHouseHelperBuyDialogMixin:LoadForPurchasing()
  if self.auctionData.numStacks < 1 then
    self:UpdateButtons()
    if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CHAIN_BUY_STACKS) and self.auctionData.nextEntry ~= nil then
      local nextEntry = self.auctionData.nextEntry

      -- Show warning if the price increases a lot
      local oldUnitPrice = self.auctionData.stackPrice / self.auctionData.stackSize
      local newUnitPrice = nextEntry.stackPrice / nextEntry.stackSize
      local priceIncrease = math.floor((newUnitPrice - oldUnitPrice) / oldUnitPrice * 100)
      if priceIncrease > AuctionHouseHelper.Constants.PriceIncreaseWarningThreshold then
        self.WarningDialog:Show()
        self.WarningDialog.Text:SetText(AUCTION_HOUSE_HELPER_L_PRICE_INCREASE_WARNING_2:format(FormatLargeNumber(priceIncrease) .. "%"))
        self:UpdateButtons()
      end

      self:SetDetails(self.auctionData.nextEntry, self.quantityPurchased, self.lastBuyStackSize, self.blacklistedBefore)
    end
    return
  end

  AuctionHouseHelper.AH.AbortQuery()
  self:FindAuctionOnCurrentPage()
  if self.buyInfo == nil then
    self.blacklistedBefore = 0
    AuctionHouseHelper.EventBus:Register(self, QUERY_EVENTS)
    self.gotAllResults = false
    AuctionHouseHelper.AH.QueryAndFocusPage(self.auctionData.query, self.auctionData.page)
  end

  self:UpdateButtons()
end

function AuctionHouseHelperBuyDialogMixin:ContinueAfterWarning()
  self.WarningDialog:Hide()
  self:UpdateButtons()
end

function AuctionHouseHelperBuyDialogMixin:ReceiveEvent(eventName, ...)
  if eventName == AuctionHouseHelper.AH.Events.ThrottleUpdate then
    self:UpdateButtons()
  elseif eventName == AuctionHouseHelper.AH.Events.ScanResultsUpdate then
    self.gotAllResults = ...
    if self.gotAllResults then
      AuctionHouseHelper.EventBus:Unregister(self, QUERY_EVENTS)
    end
    if self.auctionData and self.auctionData.numStacks > 0 then
      self:FindAuctionOnCurrentPage()
      if self.buyInfo == nil then
        self:Hide()
        self:GetParent():DoRefresh()
      end
      self:UpdateButtons()
    end
  elseif eventName == AuctionHouseHelper.AH.Events.ScanAborted then
    AuctionHouseHelper.EventBus:Unregister(self, QUERY_EVENTS)
  end
end

function AuctionHouseHelperBuyDialogMixin:FindAuctionOnCurrentPage()
  self.buyInfo = nil

  local page = AuctionHouseHelper.AH.GetCurrentPage()
  for index, auction in ipairs(page) do
    if index > self.blacklistedBefore then
      local stackPrice = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Buyout]
      local stackSize = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity]
      local bidAmount = auction.info[AuctionHouseHelper.Constants.AuctionItemInfo.BidAmount]
      if auction.itemLink == self.auctionData.itemLink and
         stackPrice == self.auctionData.stackPrice and
         stackSize == self.auctionData.stackSize and
         bidAmount ~= stackPrice then
        self.buyInfo = {index = index}
        break
      end
    end
  end
end

function AuctionHouseHelperBuyDialogMixin:UpdateButtons()
  self.BuyStack:SetEnabled(self.auctionData ~= nil and AuctionHouseHelper.AH.IsNotThrottled() and self.buyInfo ~= nil and self.auctionData.numStacks > 0 and GetMoney() >= self.auctionData.stackPrice and not self.WarningDialog:IsShown())
  if self.auctionData and self.auctionData.numStacks > 0 then
    self.BuyStack:SetText(AUCTION_HOUSE_HELPER_L_BUY_STACK)
  else
    self.BuyStack:SetText(AUCTION_HOUSE_HELPER_L_NONE_LEFT)
  end
end

function AuctionHouseHelperBuyDialogMixin:SetChainBuy()
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.CHAIN_BUY_STACKS, self.ChainBuy:GetChecked())
end

function AuctionHouseHelperBuyDialogMixin:BuyStackClicked()
  if self.auctionData.stackPrice > GetMoney() then
    self:UpdateButtons()
    return
  end

  self:SetChainBuy()
  self:FindAuctionOnCurrentPage()
  if self.buyInfo ~= nil then
    AuctionHouseHelper.AH.PlaceAuctionBid(self.buyInfo.index, self.auctionData.stackPrice)
    self.auctionData.numStacks = self.auctionData.numStacks - 1
    AuctionHouseHelper.Utilities.SetStacksText(self.auctionData)
    self.lastBuyStackSize = self.auctionData.stackSize
    self:UpdatePurchasedCount(self.quantityPurchased)
    AuctionHouseHelper.EventBus:Fire(self, AuctionHouseHelper.Buying.Events.StacksUpdated)
  end
  self:LoadForPurchasing()
end
