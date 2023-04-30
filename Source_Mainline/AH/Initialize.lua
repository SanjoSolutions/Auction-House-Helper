function AuctionHouseHelper.AH.Initialize()
  if AuctionHouseHelper.AH.Internals ~= nil then
    return
  end
  AuctionHouseHelper.AH.Internals = {}

  AuctionHouseHelper.AH.Internals.throttling = CreateFrame(
    "FRAME",
    "AuctionHouseHelperAHThrottlingFrame",
    AuctionHouseFrame,
    "AuctionHouseHelperAHThrottlingFrameTemplate"
  )

  AuctionHouseHelper.AH.Internals.itemKeyLoader = CreateFrame(
    "FRAME",
    "AuctionHouseHelperAHItemKeyLoaderFrame",
    AuctionHouseFrame,
    "AuctionHouseHelperAHItemKeyLoaderFrameTemplate"
  )

  AuctionHouseHelper.AH.Internals.searchScan = CreateFrame(
    "FRAME",
    "AuctionHouseHelperAHSearchScanFrame",
    AuctionHouseFrame,
    "AuctionHouseHelperAHSearchScanFrameTemplate"
  )

  AuctionHouseHelper.AH.Queue = CreateAndInitFromMixin(AuctionHouseHelper.AH.QueueMixin)
end
