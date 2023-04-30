function AuctionHouseHelper.AH.Initialize()
  if AuctionHouseHelper.AH.Internals ~= nil then
    return
  end
  AuctionHouseHelper.AH.Internals = {}

  AuctionHouseHelper.AH.Internals.throttling = CreateFrame(
    "FRAME",
    "AuctionHouseHelperAHThrottlingFrame",
    AuctionFrame,
    "AuctionHouseHelperAHThrottlingFrameTemplate"
  )

  AuctionHouseHelper.AH.Internals.scan = CreateFrame(
    "FRAME",
    "AuctionHouseHelperAHScanFrame",
    AuctionFrame,
    "AuctionHouseHelperAHScanFrameTemplate"
  )

  AuctionHouseHelper.AH.Queue = CreateAndInitFromMixin(AuctionHouseHelper.AH.QueueMixin)
end
