AuctionHouseHelperResetButtonMixin = {}

function AuctionHouseHelperResetButtonMixin:OnLoad()
  self.clickCallback = function() end
end

function AuctionHouseHelperResetButtonMixin:OnClick()
  self.clickCallback()
end

function AuctionHouseHelperResetButtonMixin:SetClickCallback(callback)
  self.clickCallback = callback
end
