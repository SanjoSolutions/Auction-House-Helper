AuctionHouseHelperConfigurationSubHeadingMixin = {}

function AuctionHouseHelperConfigurationSubHeadingMixin:InitializeSubHeading()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperConfigurationSubHeadingMixin:InitializeSubHeading()")

  if self.subHeadingText ~= nil then
    self.HeadingText:SetText(self.subHeadingText)
  end
end

function AuctionHouseHelperConfigurationSubHeadingMixin:SetText(newHeading)
  self.subHeadingText = newHeading
  self:OnLoad()
end
