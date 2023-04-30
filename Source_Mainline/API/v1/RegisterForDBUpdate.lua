function AuctionHouseHelper.API.v1.RegisterForDBUpdate(callerID, callback)
  AuctionHouseHelper.API.InternalVerifyID(callerID)

  if type(callback) ~= "function" then
    AuctionHouseHelper.API.ComposeError(
      callerID,
      "Usage AuctionHouseHelper.API.v1.RegisterForDBUpdate(string, function)"
    )
  end

  AuctionHouseHelper.EventBus:Register({
    ReceiveEvent = function()
      callback()
    end
  }, {
    AuctionHouseHelper.IncrementalScan.Events.PricesProcessed,
    AuctionHouseHelper.FullScan.Events.ScanComplete,
  })
end
