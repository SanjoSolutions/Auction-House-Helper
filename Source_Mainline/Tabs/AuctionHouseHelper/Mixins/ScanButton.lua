AuctionHouseHelperScanButtonMixin = {}

function AuctionHouseHelperScanButtonMixin:OnClick()
  if AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.REPLICATE_SCAN) then
    if not IsControlKeyDown() then
      AuctionHouseHelper.State.FullScanFrameRef:InitiateScan()
    else
      AuctionHouseHelper.State.IncrementalScanFrameRef:InitiateScan()
    end
  else
    if not IsControlKeyDown() then
      AuctionHouseHelper.State.IncrementalScanFrameRef:InitiateScan()
    else
      AuctionHouseHelper.State.FullScanFrameRef:InitiateScan()
    end
  end
end
