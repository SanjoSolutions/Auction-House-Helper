AuctionHouseHelperCraftingInfoCustomerOrdersFrameMixin = {}

function AuctionHouseHelperCraftingInfoCustomerOrdersFrameMixin:OnLoad()
  local reagents = self:GetParent().ReagentContainer.Reagents
  self:SetPoint("LEFT", reagents, "LEFT", 0, -10)
  self:SetPoint("TOP", reagents, "BOTTOM")
end

function AuctionHouseHelperCraftingInfoCustomerOrdersFrameMixin:OnUpdate()
  self.Total:SetText(AuctionHouseHelper.CraftingInfo.GetCustomerOrdersInfoText(self:GetParent()))
end

function AuctionHouseHelperCraftingInfoCustomerOrdersFrameMixin:OnShow()
  if self:IsRelevant() then
    self:SetScript("OnUpdate", self.OnUpdate)
  else
    self:SetScript("OnUpdate", nil)
  end
end

function AuctionHouseHelperCraftingInfoCustomerOrdersFrameMixin:IsRelevant()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW) and self:GetParent().transaction ~= nil
end
