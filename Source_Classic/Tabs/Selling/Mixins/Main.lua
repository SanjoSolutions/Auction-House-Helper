AuctionHouseHelperSellingTabMixin = {}

function AuctionHouseHelperSellingTabMixin:OnLoad()
  self:ApplyHiding()

  self.BagListing:Init(self.BagDataProvider)
  self.BuyFrame:Init()
end

function AuctionHouseHelperSellingTabMixin:ApplyHiding()
  if not AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SHOW_SELLING_BAG) then
    self.BagListing:Hide()
    self.BagInset:Hide()
    self.BuyFrame:SetPoint("TOPLEFT", self.BagListing, "TOPLEFT", 10, 10)
    self.BuyFrame.HistoryButton:SetPoint("LEFT", AuctionFrameMoneyFrame, "RIGHT")
  end
end
