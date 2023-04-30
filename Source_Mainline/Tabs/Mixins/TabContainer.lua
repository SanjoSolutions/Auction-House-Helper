AuctionHouseHelperTabContainerMixin = {}

local LibAHTab = LibStub("LibAHTab-1-0")

local padding = 0
local absoluteSize = nil
local minTabWidth = 36

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
    local frameRef = CreateFrame(
      "FRAME",
      details.tabFrameName,
      AuctionHouseFrame,
      details.tabTemplate
    )
    local buttonFrameName = "AuctionHouseHelperTabs_" .. details.name
    LibAHTab:CreateTab(buttonFrameName, frameRef, details.textLabel, details.tabHeader)
    _G[buttonFrameName] = LibAHTab:GetButton(buttonFrameName)
    table.insert(AuctionHouseHelperAHTabsContainer.Tabs, _G[buttonFrameName])

    -- Apply small tabs if enabled
    _G[buttonFrameName]:HookScript("OnShow", function(tab)
      if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SMALL_TABS) then
        PanelTemplates_TabResize(tab, padding, absoluteSize, minTabWidth)
      end
    end)
    if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SMALL_TABS) then
      PanelTemplates_TabResize(_G[buttonFrameName], padding, absoluteSize, minTabWidth)
    end
  end
end

function AuctionHouseHelperTabContainerMixin:OnShow()
  if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SMALL_TABS) then
    for _, tab in ipairs(AuctionHouseFrame.Tabs) do
      PanelTemplates_TabResize(tab, padding, absoluteSize, minTabWidth)
    end
  end
end
