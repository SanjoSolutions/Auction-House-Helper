local tabPadding = 0
local tabAbsoluteSize = nil
local minTabWidth = 36

AuctionHouseHelperTabContainerMixin = {}

local function InitializeFromDetails(details)
  local frame = CreateFrame(
    "BUTTON",
    "AuctionFrameTab" .. (AuctionFrame.numTabs + 1),
    AuctionFrame,
    "AuctionHouseHelperTabButtonTemplate"
  )
  local frameName = "AuctionHouseHelperTabs_" .. details.name
  _G[frameName] = frame

  frame:SetText(details.textLabel)

  frame:Initialize(details.name, details.tabTemplate, details.tabHeader, {details.tabFrameName})
  PanelTemplates_TabResize(frame, tabPadding, tabAbsoluteSize, minTabWidth)

  return frame
end

function AuctionHouseHelperTabContainerMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperTabContainerMixin:OnLoad()")

  -- Tabs are sorted to avoid inconsistent ordering based on the addon loading
  -- order
  table.sort(
    AuctionHouseHelper.Tabs.State.knownTabs,
    function(left, right)
      return left.tabOrder < right.tabOrder
    end
  )

  self.Tabs = {}

  for _, details in ipairs(AuctionHouseHelper.Tabs.State.knownTabs) do
    table.insert(self.Tabs, InitializeFromDetails(details))
  end

  self:HookTabs()
end

function AuctionHouseHelperTabContainerMixin:OnShow()
end

function AuctionHouseHelperTabContainerMixin:OnHide()
  for _, auctionHouseHelperTab in pairs(self.Tabs) do
    auctionHouseHelperTab:DeselectTab()
  end
end

function AuctionHouseHelperTabContainerMixin:IsAuctionHouseHelperFrame(tab)
  for _, frame in pairs(self.Tabs) do
    if frame == tab then
      return true
    end
  end

  return false
end

function AuctionHouseHelperTabContainerMixin:HookTabs()
  hooksecurefunc(_G, "AuctionFrameTab_OnClick", function(tabButton, ...)
    for _, tab in ipairs(self.Tabs) do
      tab:DeselectTab()
    end

    local isAuctionHouseHelperFrame = self:IsAuctionHouseHelperFrame(tabButton)
    if isAuctionHouseHelperFrame then
      tabButton:Selected()
    end
  end)
end
