local AUCTION_HOUSE_HELPER_EVENTS = {
  -- Addon Initialization Events
  "PLAYER_LOGIN",
  -- Import list events
  -- "CHAT_MSG_ADDON"
}

AuctionHouseHelperInitializeMixin = {}

function AuctionHouseHelperInitializeMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelper.Events.CoreFrameLoaded")
  C_ChatInfo.RegisterAddonMessagePrefix("AuctionHouseHelper")

  FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_HELPER_EVENTS)
end

function AuctionHouseHelperInitializeMixin:OnEvent(event, ...)
  -- AuctionHouseHelper.Debug.Message("AuctionHouseHelperInitializeMixin", event, ...)
  if event == "PLAYER_LOGIN" then
    self:AddonDataLoaded()
  elseif event == "CHAT_MSG_ADDON" then
    -- For now, just drop the message - we
    -- need to aggregate the messages and provide a pop up
    -- asking people if they want to import
  end
end

function AuctionHouseHelperInitializeMixin:AddonDataLoaded(event, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperInitializeMixin:VariablesLoaded")
  AuctionHouseHelper.Variables.Initialize()

  AuctionHouseHelper.SlashCmd.Initialize()
end
