AuctionHouseHelperConfigTextInputMixin = {}

function AuctionHouseHelperConfigTextInputMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("HERE HERE HERE HERE HERE HERE HERE")
end

function AuctionHouseHelperConfigTextInputMixin:OnMouseUp()
  self.InputBox:SetFocus()
end

function AuctionHouseHelperConfigTextInputMixin:SetFocus()
  self.InputBox:SetFocus()
end

function AuctionHouseHelperConfigTextInputMixin:SetText(value)
  self.InputBox:SetText(value)
  self.InputBox:SetCursorPosition(0)
end

function AuctionHouseHelperConfigTextInputMixin:GetText()
  return self.InputBox:GetText()
end
