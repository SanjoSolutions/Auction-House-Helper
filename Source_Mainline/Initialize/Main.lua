local AUCTION_HOUSE_HELPER_EVENTS = {
  "PLAYER_LOGIN",
  "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
  "TRADE_SKILL_SHOW",
}

AuctionHouseHelperInitializeMainlineMixin = {}

function AuctionHouseHelperInitializeMainlineMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_HELPER_EVENTS)
end

function AuctionHouseHelperInitializeMainlineMixin:OnEvent(event, ...)
  if event == "PLAYER_LOGIN" then
    AuctionHouseHelper.CraftingInfo.InitializeObjectiveTrackerFrame()
  elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
    local showType = ...
    -- Cache vendor prices events
    if showType == Enum.PlayerInteractionType.Merchant then
      -- Tournament realms have vendors for stuff that is only on the AH for
      -- other realms, breaking crafting info prices, this prevents it happening
      -- again.
      if not IsOnTournamentRealm() then
        AuctionHouseHelper.CraftingInfo.CacheVendorPrices()
      end
     -- AH Window Initialization Events
    elseif showType == Enum.PlayerInteractionType.Auctioneer then
      self:AuctionHouseShown()
    elseif showType == Enum.PlayerInteractionType.ProfessionsCustomerOrder then
      AuctionHouseHelper.CraftingInfo.InitializeCustomerOrdersFrame()
    end
  elseif event == "TRADE_SKILL_SHOW" then
    AuctionHouseHelper.CraftingInfo.InitializeProfessionsFrame()
  end
end

function AuctionHouseHelperInitializeMainlineMixin:AuctionHouseShown()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperInitializeMainlineMixin:AuctionHouseShown()")

  -- Avoids a lot of errors if this is loaded in a classic client
  if AuctionHouseFrame == nil then
    return
  end

  AuctionHouseHelper.AH.Initialize()

  if AuctionHouseHelper.State.AuctionHouseHelperFrame == nil then
    AuctionHouseHelper.State.AuctionHouseHelperFrame = CreateFrame("FRAME", "AuctionHouseHelperAHFrame", AuctionHouseFrame, "AuctionHouseHelperAHFrameTemplate")
  end
end
