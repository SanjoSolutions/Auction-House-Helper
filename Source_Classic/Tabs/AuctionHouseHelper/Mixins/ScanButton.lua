AuctionHouseHelperScanButtonMixin = {}

function AuctionHouseHelperScanButtonMixin:OnClick()
  AuctionHouseHelper.State.FullScanFrameRef:InitiateScan()
end
