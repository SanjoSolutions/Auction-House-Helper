-- Permits a decimal point in the edit box
function AuctionHouseHelper_EditBox_OnTextChanged(self, ...)
  -- Only one decimal point and all numbers
  if string.match(self:GetText(), "[^1234567890.]") == nil and
     string.match(self:GetText(), "[.].*[.]") == nil then
    return
  end

  self:SetText(self.auctionHouseHelperPrevText or "")
end

function AuctionHouseHelper_EditBox_OnKeyDown(self, key)
  self.auctionHouseHelperPrevText = self:GetText()
end
