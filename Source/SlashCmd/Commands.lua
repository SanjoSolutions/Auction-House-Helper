local SLASH_COMMAND_DESCRIPTIONS = {
  {commands = "p, post", message = "Posts the chosen item from the \"Selling\" tab." },
  {commands = "cu, cancelundercut", message = "Cancels the next undercut auction in the \"Cancelling\" tab." },
  {commands = "ra, resetall", message = "Reset database and full scan timer." },
  {commands = "rdb, resetdatabase", message = "Reset AuctionHouseHelper database."},
  {commands = "rt, resettimer", message = "Reset full scan timer."},
  {commands = "rc, resetconfig", message = "Reset configuration to defaults."},
  {commands = "npd, nopricedb", message = "Disable recording auction prices."},
  {commands = "d, debug", message = "Toggle debug mode."},
  {commands = "c, config", message = "Show current configuration values."},
  {commands = "c [toggle-name], config [toggle-name]", message = "Toggle the value of the configuration value [toggle-name]."},
  {commands = "v, version", message = "Show current version."},
  {commands = "h, help", message = "Show this help message."},
}

function AuctionHouseHelper.SlashCmd.Post()
  AuctionHouseHelper.EventBus
    :RegisterSource(AuctionHouseHelper.SlashCmd.Post, "AuctionHouseHelper.SlashCmd.Post")
    :Fire(AuctionHouseHelper.SlashCmd.Post, AuctionHouseHelper.Selling.Events.RequestPost)
    :UnregisterSource(AuctionHouseHelper.SlashCmd.Post)
end

function AuctionHouseHelper.SlashCmd.CancelUndercut()
  AuctionHouseHelper.EventBus
    :RegisterSource(AuctionHouseHelper.SlashCmd.CancelUndercut, "AuctionHouseHelper.SlashCmd.CancelUndercut")
    :Fire(AuctionHouseHelper.SlashCmd.CancelUndercut, AuctionHouseHelper.Cancelling.Events.RequestCancelUndercut)
    :UnregisterSource(AuctionHouseHelper.SlashCmd.CancelUndercut)
end

function AuctionHouseHelper.SlashCmd.ToggleDebug()
  AuctionHouseHelper.Debug.Toggle()
  if AuctionHouseHelper.Debug.IsOn() then
    AuctionHouseHelper.Utilities.Message("Debug mode on")
  else
    AuctionHouseHelper.Utilities.Message("Debug mode off")
  end
end

function AuctionHouseHelper.SlashCmd.ResetDatabase()
  if AuctionHouseHelper.Debug.IsOn() then
    -- See Source/Variables/Main.lua for variable usage
    AUCTION_HOUSE_HELPER_PRICE_DATABASE = nil
    AuctionHouseHelper.Utilities.Message("Price database reset")
    AuctionHouseHelper.Variables.InitializeDatabase()
  else
    AuctionHouseHelper.Utilities.Message("Requires debug mode.")
  end
end

function AuctionHouseHelper.SlashCmd.ResetTimer()
  if AuctionHouseHelper.Debug.IsOn() then
    AuctionHouseHelper.SavedState.TimeOfLastReplicateScan = nil
    AuctionHouseHelper.SavedState.TimeOfLastGetAllScan = nil
    AuctionHouseHelper.Utilities.Message("Scan timer reset.")
  else
    AuctionHouseHelper.Utilities.Message("Requires debug mode.")
  end
end

function AuctionHouseHelper.SlashCmd.CleanReset()
  AuctionHouseHelper.SlashCmd.ResetTimer()
  AuctionHouseHelper.SlashCmd.ResetDatabase()
end

function AuctionHouseHelper.SlashCmd.NoPriceDB()
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.NO_PRICE_DATABASE, true)

  AUCTION_HOUSE_HELPER_PRICE_DATABASE = nil
  AuctionHouseHelper.Variables.InitializeDatabase()

  AuctionHouseHelper.Utilities.Message("Disabled recording auction prices in the price database.")
end

function AuctionHouseHelper.SlashCmd.ResetConfig()
  if AuctionHouseHelper.Debug.IsOn() then
    AuctionHouseHelper.Config.Reset()
    AuctionHouseHelper.Utilities.Message("Config reset.")
  else
    AuctionHouseHelper.Utilities.Message("Requires debug mode.")
  end
end

function AuctionHouseHelper.SlashCmd.Config(name, value)
  if name == nil then
    AuctionHouseHelper.Utilities.Message("Current config:")
    for _, name in pairs(AuctionHouseHelper.Config.Options) do
      if AuctionHouseHelper.Config.IsValidOption(name) then
        AuctionHouseHelper.Utilities.Message(name .. "=" .. tostring(AuctionHouseHelper.Config.Get(name)) .. " (" .. type(AuctionHouseHelper.Config.Get(name)) .. ")")
      end
    end
  elseif not AuctionHouseHelper.Config.IsValidOption(name) then
    AuctionHouseHelper.Utilities.Message("Unknown config " .. name)
  elseif type(AuctionHouseHelper.Config.Get(name)) == "boolean" then
    AuctionHouseHelper.Config.Set(name, not AuctionHouseHelper.Config.Get(name))
    AuctionHouseHelper.Utilities.Message("Config set " .. name .. " = " .. tostring(AuctionHouseHelper.Config.Get(name)))
  elseif type(AuctionHouseHelper.Config.Get(name)) == "number" then
    if tonumber(value) == nil then
      AuctionHouseHelper.Utilities.Message("Config " .. name .. " not modified; Numerical value required")
    else
      AuctionHouseHelper.Config.Set(name, tonumber(value))
    end
    AuctionHouseHelper.Utilities.Message("Config set " .. name .. " = " .. tostring(AuctionHouseHelper.Config.Get(name)))
  else
    AuctionHouseHelper.Utilities.Message("Unable to modify " .. name .. " at this time")
  end
end

function AuctionHouseHelper.SlashCmd.Version()
  AuctionHouseHelper.Utilities.Message(AUCTION_HOUSE_HELPER_L_VERSION_HEADER .. " " .. AuctionHouseHelper.State.CurrentVersion)
end

function AuctionHouseHelper.SlashCmd.Help()
  for index = 1, #SLASH_COMMAND_DESCRIPTIONS do
    local description = SLASH_COMMAND_DESCRIPTIONS[index]
    AuctionHouseHelper.Utilities.Message(description.commands .. ": " .. description.message)
  end
end
