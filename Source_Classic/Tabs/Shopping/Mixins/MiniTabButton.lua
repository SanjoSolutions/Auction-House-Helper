local MIN_TAB_WIDTH = 70;
local TAB_PADDING = 20;

AuctionHouseHelperShoppingListsMiniTabButtonMixinMixin = {}

function AuctionHouseHelperShoppingListsMiniTabButtonMixinMixin:OnLoad()
  self.LeftDisabled:SetPoint("TOPLEFT")
  self.deselectedTextY = 6
  self.selectedTextY = 2
end

function AuctionHouseHelperShoppingListsMiniTabButtonMixinMixin:OnShow()
  local absoluteSize = nil
  PanelTemplates_TabResize(self, TAB_PADDING, absoluteSize, MIN_TAB_WIDTH)
end

function AuctionHouseHelperShoppingListsMiniTabButtonMixinMixin:OnClick()
  self:GetParent():SetView(self:GetID())

  PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
end
