function AuctionHouseHelper.Components.ReportEnterPressed()
  AuctionHouseHelper.EventBus
    :RegisterSource(AuctionHouseHelper.Components.ReportEnterPressed, "ReportEnterPressed")
    :Fire(AuctionHouseHelper.Components.ReportEnterPressed, AuctionHouseHelper.Components.Events.EnterPressed)
    :UnregisterSource(AuctionHouseHelper.Components.ReportEnterPressed)
end
