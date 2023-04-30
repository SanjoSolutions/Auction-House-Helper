AuctionHouseHelperBuyingItemTooltipMixin = {}

function AuctionHouseHelperBuyingItemTooltipMixin:OnLoad()
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Buying.Events.ShowForShopping
  })
end

function AuctionHouseHelperBuyingItemTooltipMixin:OnEnter()
  GameTooltip:SetOwner(self, "ANCHOR_TOP")
  GameTooltip:SetHyperlink(self.itemLink)
  GameTooltip:Show()
end

function AuctionHouseHelperBuyingItemTooltipMixin:OnLeave()
  GameTooltip:Hide()
end

function AuctionHouseHelperBuyingItemTooltipMixin:OnMouseUp()
  if IsModifiedClick("CHATLINK") then
    if self.itemLink ~= nil then
      ChatEdit_InsertLink(self.itemLink)
    end
  else
    if self.itemLink ~= nil then
      -- Search for item in the browse tab (so that someone can check the bid
      -- prices)
      BrowseResetButton:Click()
      BrowseName:SetText(AuctionHouseHelper.Utilities.GetNameFromLink(self.itemLink))
      AuctionFrameTab1:Click()
      AuctionFrameBrowse_Search()
    end
  end
end

function AuctionHouseHelperBuyingItemTooltipMixin:ReceiveEvent(eventName, eventData)
  self.itemLink = eventData.itemLink
  self.Icon:SetTexture(eventData.iconTexture)
  self.Text:SetText(eventData.itemName)
end
