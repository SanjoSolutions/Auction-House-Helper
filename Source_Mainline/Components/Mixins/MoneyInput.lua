AuctionHouseHelperConfigMoneyInputMixin = {}

function AuctionHouseHelperConfigMoneyInputMixin:OnLoad()
  if self.labelText ~= nil then
    self.Label:SetText(self.labelText)
  end

  self.MoneyInput.SilverBox:SetScript("OnEnter", function() self:OnEnter() end)
  self.MoneyInput.SilverBox:SetScript("OnLeave", function() self:OnLeave() end)
  self.MoneyInput.GoldBox:SetScript("OnEnter", function() self:OnEnter() end)
  self.MoneyInput.GoldBox:SetScript("OnLeave", function() self:OnLeave() end)

  self.MoneyInput.SilverBox:SetScript("OnEnterPressed", function()
    AuctionHouseHelper.Components.ReportEnterPressed()
  end)
  self.MoneyInput.GoldBox:SetScript("OnEnterPressed", function()
    AuctionHouseHelper.Components.ReportEnterPressed()
  end)
end

function AuctionHouseHelperConfigMoneyInputMixin:SetAmount(value)
  self.MoneyInput:SetAmount(value)
  self.MoneyInput.GoldBox:SetCursorPosition(0)
  self.MoneyInput.SilverBox:SetCursorPosition(0)
end

function AuctionHouseHelperConfigMoneyInputMixin:Clear()
  self.MoneyInput:Clear()
end

function AuctionHouseHelperConfigMoneyInputMixin:GetAmount()
  return self.MoneyInput:GetAmount()
end
