AuctionHouseHelperScrollListLineButtonMixin = {}

function AuctionHouseHelperScrollListLineButtonMixin:OnShow()
  self.hoverTexture:Hide()
end
function AuctionHouseHelperScrollListLineButtonMixin:OnEnter()
  if self:GetParent():IsEnabled() then
    self.hoverTexture:Show()

    if self.tooltipTitleText ~= nil then
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(self.tooltipTitleText, 0.9, 1.0, 1.0)
      GameTooltip:Show()
    end
  end
end
function AuctionHouseHelperScrollListLineButtonMixin:OnLeave()
  self.hoverTexture:Hide()

  if self.tooltipTitleText ~= nil then
    GameTooltip:Hide()
  end
end
