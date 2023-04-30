AuctionHouseHelperConfigCheckboxMixin = {}

function AuctionHouseHelperConfigCheckboxMixin:OnLoad()
  if self.labelText ~= nil then
    self.CheckBox.Label:SetText(self.labelText)
  end
end

function AuctionHouseHelperConfigCheckboxMixin:SetText(text)
  self.labelText = text
  self.CheckBox.Label:SetText(self.labelText)
end

function AuctionHouseHelperConfigCheckboxMixin:GetText()
  return self.CheckBox.Label:GetText()
end

function AuctionHouseHelperConfigCheckboxMixin:SetChecked(value)
  self.CheckBox:SetChecked(value)
end

-- Makes clicking on the text flip the toggle
function AuctionHouseHelperConfigCheckboxMixin:OnMouseUp()
  self.CheckBox:Click()
end

function AuctionHouseHelperConfigCheckboxMixin:OnEnter()
  self.CheckBox:LockHighlight()

  AuctionHouseHelperConfigTooltipMixin.OnEnter(self)
end

function AuctionHouseHelperConfigCheckboxMixin:OnLeave()
  self.CheckBox:UnlockHighlight()

  AuctionHouseHelperConfigTooltipMixin.OnLeave(self)
end

function AuctionHouseHelperConfigCheckboxMixin:GetChecked()
  return self.CheckBox:GetChecked()
end
