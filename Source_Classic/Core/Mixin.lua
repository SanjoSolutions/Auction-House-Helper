AuctionHouseHelperAHFrameMixin = {}

local function InitializeAuctionHouseTabs()
  if AuctionHouseHelper.State.TabFrameRef == nil then
    AuctionHouseHelper.State.TabFrameRef = CreateFrame(
      "Frame",
      "AuctionHouseHelperAHTabsContainer",
      AuctionFrame,
      "AuctionHouseHelperAHTabsContainerTemplate"
    )
  end
end

local function InitializeBuyFrame()
  if AuctionHouseHelper.State.BuyFrameRef == nil then
    AuctionHouseHelper.State.BuyFrameRef = CreateFrame(
      "Frame",
      "AuctionHouseHelperBuyFrame",
      AuctionHouseHelperShoppingFrame,
      "AuctionHouseHelperBuyFrameTemplateForShopping"
    )
  end
end

local function InitializePageStatusDialog()
  if AuctionHouseHelper.State.PageStatusFrameRef == nil then
    AuctionHouseHelper.State.PageStatusFrameRef = CreateFrame(
      "Frame",
      "AuctionHouseHelperPageStatusDialogFrame",
      AuctionFrame,
      "AuctionHouseHelperPageStatusDialogTemplate"
    )
  end
end

local function InitializeThrottlingTimeoutDialog()
  if AuctionHouseHelper.State.ThrottlingTimeoutFrameRef == nil then
    AuctionHouseHelper.State.ThrottlingTimeoutFrameRef = CreateFrame(
      "Frame",
      "AuctionHouseHelperThrottlingTimeoutDialogFrame",
      AuctionFrame,
      "AuctionHouseHelperThrottlingTimeoutDialogTemplate"
    )
  end
end

local function ShowDefaultTab()
  local tabs = AuctionHouseHelperAHTabsContainer.Tabs

  local chosenTab = tabs[AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.DEFAULT_TAB)]

  if chosenTab then
    chosenTab:Click()
  end
end

local function InitializeSplashScreen()
  if AuctionHouseHelper.State.SplashScreenRef == nil then
    AuctionHouseHelper.State.SplashScreenRef = CreateFrame(
      "Frame",
      "AuctionHouseHelperSplashScreen",
      UIParent,
      "AuctionHouseHelperSplashScreenTemplate"
    )
  end
end

local function InitializeFullScanFrame()
  if AuctionHouseHelper.State.FullScanFrameRef == nil then
    AuctionHouseHelper.State.FullScanFrameRef = CreateFrame(
      "FRAME",
      "AuctionHouseHelperFullScanFrame",
      AuctionHouseFrame,
      "AuctionHouseHelperFullScanFrameTemplate"
    )
  end
end

local setupSearchCategories = false
local function InitializeSearchCategories()
  if setupSearchCategories then
    return
  end

  AuctionHouseHelper.Search.InitializeCategories()

  setupSearchCategories = true
end

function AuctionHouseHelperAHFrameMixin:OnShow()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperAHFrameMixin:OnShow()")

  InitializeSearchCategories()
  InitializeAuctionHouseTabs()
  InitializeBuyFrame()
  InitializePageStatusDialog()
  InitializeThrottlingTimeoutDialog()
  InitializeFullScanFrame()
  InitializeSplashScreen()

  ShowDefaultTab()
end

function AuctionHouseHelperAHFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_SHOW" then
    self:Show()
  elseif eventName == "AUCTION_HOUSE_CLOSED" then
    self:Hide()
  end
end
