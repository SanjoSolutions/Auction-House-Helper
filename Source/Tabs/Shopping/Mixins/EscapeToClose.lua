AuctionHouseHelperEscapeToCloseMixin = {}

function AuctionHouseHelperEscapeToCloseMixin:OnKeyDown(key)
  self:SetPropagateKeyboardInput(key ~= "ESCAPE")
end

function AuctionHouseHelperEscapeToCloseMixin:OnKeyUp(key)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperEscapeToCloseMixin:OnKeyUp()", key)

  if key == "ESCAPE" then
    self:Hide()
  end
end
