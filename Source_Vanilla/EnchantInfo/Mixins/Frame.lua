AuctionHouseHelperEnchantInfoFrameMixin = {}

function AuctionHouseHelperEnchantInfoFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
  })

  self.originalFirstLine = CraftDescription or CraftReagentLabel
  self.originalDescriptionPoint = {self.originalFirstLine:GetPoint(1)}

  hooksecurefunc(_G, "CraftFrame_SetSelection", function(ecipeID)
    self:ShowIfRelevant()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
  AuctionHouseHelper.API.v1.RegisterForDBUpdate(AUCTION_HOUSE_HELPER_L_REAGENT_SEARCH, function()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
  self:ShowIfRelevant()
  if self:IsVisible() then
    self:UpdateTotal()
  end
end

function AuctionHouseHelperEnchantInfoFrameMixin:ShowIfRelevant()
  self:SetShown(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW) and GetCraftSelectionIndex() ~= 0)
  if self:IsVisible() then
    self.SearchButton:SetShown(AuctionFrame ~= nil and AuctionFrame:IsShown())

    self:SetPoint(unpack(self.originalDescriptionPoint))
    self.originalFirstLine:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
  else
    self.originalFirstLine:SetPoint(unpack(self.originalDescriptionPoint))
  end
end

function AuctionHouseHelperEnchantInfoFrameMixin:UpdateTotal()
  self.Total:SetText(AuctionHouseHelper.EnchantInfo.GetInfoText())
end

function AuctionHouseHelperEnchantInfoFrameMixin:SearchButtonClicked()
  if AuctionFrame and AuctionFrame:IsShown() then
    AuctionHouseHelper.EnchantInfo.DoCraftReagentsSearch()
  end
end

function AuctionHouseHelperEnchantInfoFrameMixin:OnEvent(...)
  if self:IsVisible() then
    self:UpdateTotal()
  end
end
