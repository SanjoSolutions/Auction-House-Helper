AuctionHouseHelperFullScanStatusMixin = {}

function AuctionHouseHelperFullScanStatusMixin:OnLoad()
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.FullScan.Events.ScanStart,
    AuctionHouseHelper.FullScan.Events.ScanProgress,
    AuctionHouseHelper.FullScan.Events.ScanComplete,
    AuctionHouseHelper.FullScan.Events.ScanFailed,
  })
end

function AuctionHouseHelperFullScanStatusMixin:OnShow()
  self.Text:SetText("")
end

function AuctionHouseHelperFullScanStatusMixin:ReceiveEvent(event, eventData)
  if event == AuctionHouseHelper.FullScan.Events.ScanStart then
    self.Text:SetText("0%")

  elseif event == AuctionHouseHelper.FullScan.Events.ScanProgress then
    self.Text:SetText(tostring(math.floor(eventData*100)) .. "%")

  elseif event == AuctionHouseHelper.FullScan.Events.ScanComplete then
    self.Text:SetText("100%")

  else
    self.Text:SetText("")
  end
end
