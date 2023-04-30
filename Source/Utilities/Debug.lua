function AuctionHouseHelper.Debug.IsOn()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.DEBUG)
end

function AuctionHouseHelper.Debug.Toggle()
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.DEBUG,
    not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.DEBUG))
end

function AuctionHouseHelper.Debug.Message(message, ...)
  if AuctionHouseHelper.Debug.IsOn() then
    print(GREEN_FONT_COLOR:WrapTextInColorCode(message), ...)
  end
end
