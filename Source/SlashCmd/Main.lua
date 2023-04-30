function AuctionHouseHelper.SlashCmd.Initialize()
  SlashCmdList["AuctionHouseHelper"] = AuctionHouseHelper.SlashCmd.Handler
  SLASH_AuctionHouseHelper1 = "/auctionhousehelper"
  SLASH_AuctionHouseHelper2 = "/ahh"
end

--Update SLASH_COMMAND_DESCRIPTIONS in Commands.lua for new commands
local SLASH_COMMANDS = {
  ["p"] = AuctionHouseHelper.SlashCmd.Post,
  ["post"] = AuctionHouseHelper.SlashCmd.Post,
  ["cu"] = AuctionHouseHelper.SlashCmd.CancelUndercut,
  ["cancelundercut"] = AuctionHouseHelper.SlashCmd.CancelUndercut,
  ["ra"] = AuctionHouseHelper.SlashCmd.CleanReset,
  ["resetall"] = AuctionHouseHelper.SlashCmd.CleanReset,
  ["rt"] = AuctionHouseHelper.SlashCmd.ResetTimer,
  ["resettimer"] = AuctionHouseHelper.SlashCmd.ResetTimer,
  ["rdb"] = AuctionHouseHelper.SlashCmd.ResetDatabase,
  ["resetdatabase"] = AuctionHouseHelper.SlashCmd.ResetDatabase,
  ["rc"] = AuctionHouseHelper.SlashCmd.ResetConfig,
  ["resetconfig"] = AuctionHouseHelper.SlashCmd.ResetConfig,
  ["d"] = AuctionHouseHelper.SlashCmd.ToggleDebug,
  ["debug"] = AuctionHouseHelper.SlashCmd.ToggleDebug,
  ["config"] = AuctionHouseHelper.SlashCmd.Config,
  ["c"] = AuctionHouseHelper.SlashCmd.Config,
  ["v"] = AuctionHouseHelper.SlashCmd.Version,
  ["version"] = AuctionHouseHelper.SlashCmd.Version,
  ["nopricedb"] = AuctionHouseHelper.SlashCmd.NoPriceDB,
  ["npd"] = AuctionHouseHelper.SlashCmd.NoPriceDB,
  ["h"] = AuctionHouseHelper.SlashCmd.Help,
  ["help"] = AuctionHouseHelper.SlashCmd.Help,
}

function AuctionHouseHelper.SlashCmd.Handler(input)
  AuctionHouseHelper.Debug.Message( 'AuctionHouseHelper.SlashCmd.Handler', input )

  if #input == 0 then
    AuctionHouseHelper.SlashCmd.Help()
  else
    local command = AuctionHouseHelper.Utilities.SplitCommand(input);
    local handler = SLASH_COMMANDS[command[1]]
    if handler == nil then
      AuctionHouseHelper.Utilities.Message("Unrecognized command '" .. command[1] .. "'")
      AuctionHouseHelper.SlashCmd.Help()
    else
      handler(command[2], command[3])
    end
  end
end
