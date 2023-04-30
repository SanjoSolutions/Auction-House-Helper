local AUCTION_HOUSE_HELPER_EVENTS = {
  -- AH Window Initialization Events
  "AUCTION_HOUSE_SHOW",
  -- Trade Window Initialization Events
  "TRADE_SKILL_SHOW",
  -- Cache vendor prices event
  "MERCHANT_SHOW",
}

AuctionHouseHelperInitializeClassicMixin = {}

function AuctionHouseHelperInitializeClassicMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_HELPER_EVENTS)
end

function AuctionHouseHelperInitializeClassicMixin:OnEvent(event, ...)
  if event == "AUCTION_HOUSE_SHOW" then
    self:AuctionHouseShown()
  elseif event == "TRADE_SKILL_SHOW" then
    AuctionHouseHelper.CraftingInfo.Initialize()
  elseif event == "MERCHANT_SHOW" then
    AuctionHouseHelper.CraftingInfo.CacheVendorPrices()
  end
end

function AuctionHouseHelperInitializeClassicMixin:AuctionHouseShown()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperInitializeClassicMixin:AuctionHouseShown()")

  -- Prevents a lot of errors if loaded in retail
  if AuctionFrame == nil then
    return
  end

  AuctionHouseHelper.AH.Initialize()

  if AuctionHouseHelper.State.AuctionHouseHelperFrame == nil then
    AuctionHouseHelper.State.AuctionHouseHelperFrame = CreateFrame("FRAME", "AuctionHouseHelperAHFrame", AuctionFrame, "AuctionHouseHelperAHFrameTemplate")
  end

  FrameUtil.RegisterFrameForEvents(AuctionHouseHelper.State.AuctionHouseHelperFrame, { "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED" })
end
