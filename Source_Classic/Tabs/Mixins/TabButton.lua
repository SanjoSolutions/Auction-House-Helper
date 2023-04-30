AuctionHouseHelperTabMixin = {}

function AuctionHouseHelperTabMixin:Initialize(name, tabTemplate, tabHeader, displayMode)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperTabMixin:Initialize()")

  self.ahTitle = tabHeader
  self.displayMode = displayMode

  self.wrapperFrame = CreateFrame("FRAME", nil, AuctionFrame, "AuctionHouseHelperTabWrapperTemplate")
  self.wrapperFrame.Title:SetText(self.ahTitle)
  -- Create this tab's frame
  self.frameRef = CreateFrame(
    "FRAME",
    displayMode[1],
    self.wrapperFrame,
    tabTemplate
  )
  self.frameRef:Hide()

  local index = AuctionFrame.numTabs + 1
  self:SetID(index)

  self:SetPoint("LEFT", _G["AuctionFrameTab" .. (index - 1)], "RIGHT", -15, 0)

  PanelTemplates_SetNumTabs(AuctionFrame, index)
  PanelTemplates_EnableTab(AuctionFrame, index)
  --PanelTemplates_DeselectTab(self)
end

function AuctionHouseHelperTabMixin:Selected()
  PanelTemplates_SetTab(AuctionFrame, self)
  PanelTemplates_SelectTab(self)
  self.wrapperFrame:Show()
  self.frameRef:Show()

  --AuctionHouseFrame:SetTitle(self.ahTitle)
  AuctionFrameTopLeft:SetTexture("Interface\\AddOns\\AuctionHouseHelper\\Images_Classic\\topleft");
  AuctionFrameTop:SetTexture("Interface\\AddOns\\AuctionHouseHelper\\Images_Classic\\top");
  AuctionFrameTopRight:SetTexture("Interface\\AddOns\\AuctionHouseHelper\\Images_Classic\\topright");
  AuctionFrameBotLeft:SetTexture("Interface\\AddOns\\AuctionHouseHelper\\Images_Classic\\botleft");
  AuctionFrameBot:SetTexture("Interface\\AddOns\\AuctionHouseHelper\\Images_Classic\\bot");
  AuctionFrameBotRight:SetTexture("Interface\\AddOns\\AuctionHouseHelper\\Images_Classic\\botright");
end

function AuctionHouseHelperTabMixin:DeselectTab()
  PanelTemplates_DeselectTab(self)
  self.wrapperFrame:Hide()
end
