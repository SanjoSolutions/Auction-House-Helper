AuctionHouseHelperAHFrameMixin = {}

local function InitializeIncrementalScanFrame()
  local frame
  if AuctionHouseHelper.State.IncrementalScanFrameRef == nil then
    frame = CreateFrame(
      "FRAME",
      "AuctionHouseHelperIncrementalScanFrame",
      AuctionHouseFrame,
      "AuctionHouseHelperIncrementalScanFrameTemplate"
    )

    AuctionHouseHelper.State.IncrementalScanFrameRef = frame
  else
    frame = AuctionHouseHelper.State.IncrementalScanFrameRef
  end

  if not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.REPLICATE_SCAN) and
     AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUTOSCAN) and
     frame:IsAutoscanReady() then
    frame:InitiateScan()
  end
end

local function InitializeFullScanFrame()
  local frame
  if AuctionHouseHelper.State.FullScanFrameRef == nil then
    frame = CreateFrame(
      "FRAME",
      "AuctionHouseHelperFullScanFrame",
      AuctionHouseFrame,
      "AuctionHouseHelperFullScanFrameTemplate"
    )

    AuctionHouseHelper.State.FullScanFrameRef = frame
  else
    frame = AuctionHouseHelper.State.FullScanFrameRef
  end

  if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.REPLICATE_SCAN) and
     AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUTOSCAN) and
     frame:IsAutoscanReady() then
    frame:InitiateScan()
  end
end

local function InitializeAuctionHouseTabs()
  if AuctionHouseHelper.State.TabFrameRef == nil then
    AuctionHouseHelper.State.TabFrameRef = CreateFrame(
      "Frame",
      "AuctionHouseHelperAHTabsContainer",
      AuctionHouseFrame,
      "AuctionHouseHelperAHTabsContainerTemplate"
    )
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

local setupSearchCategories = false
local function InitializeSearchCategories()
  if setupSearchCategories then
    return
  end

  AuctionHouseHelper.Search.InitializeCategories()

  setupSearchCategories = true
end

local function ShowDefaultTab()
  local tabs = AuctionHouseHelperAHTabsContainer.Tabs

  local chosenTab = tabs[AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.DEFAULT_TAB)]

  if chosenTab then
    chosenTab:Click()
  end
end

function AuctionHouseHelperAHFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
    "PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
  })
end

function AuctionHouseHelperAHFrameMixin:OnShow()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperAHFrameMixin:OnShow()")

  InitializeIncrementalScanFrame()
  InitializeFullScanFrame()
  InitializeSearchCategories()

  InitializeAuctionHouseTabs()
  InitializeSplashScreen()

  ShowDefaultTab()
end

function AuctionHouseHelperAHFrameMixin:OnEvent(eventName, ...)
  local paneType = ...
  if eventName == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" and paneType == Enum.PlayerInteractionType.Auctioneer then
    self:Show()
  elseif eventName == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" and paneType == Enum.PlayerInteractionType.Auctioneer then
    self:Hide()
  end
end
