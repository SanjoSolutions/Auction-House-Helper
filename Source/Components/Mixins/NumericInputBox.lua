AuctionHouseHelperConfigNumericInputMixin = {}

function AuctionHouseHelperConfigNumericInputMixin:OnLoad()
  if self.labelText ~= nil then
    self.InputBox.Label:SetText(self.labelText)
  end
end

function AuctionHouseHelperConfigNumericInputMixin:OnMouseUp()
  self.InputBox:SetFocus()
end

function AuctionHouseHelperConfigNumericInputMixin:SetNumber(value)
  self.InputBox:SetNumber(value)
  self.InputBox:SetCursorPosition(0)
end

function AuctionHouseHelperConfigNumericInputMixin:GetNumber(value)
  return self.InputBox:GetNumber(value)
end
