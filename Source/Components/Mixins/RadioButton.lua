AuctionHouseHelperConfigRadioButtonMixin = {}

function AuctionHouseHelperConfigRadioButtonMixin:OnLoad()
  -- This field is used by the RadioButtonGroup to ensure that the UI child it is positioning
  -- is an Auction House Helper radio button
  self.isAuctionHouseHelperRadio = true

  if self.value == nil then
    error("A value is required for the radio button.")
  end

  if self.labelText ~= nil then
    self.RadioButton.Label:SetText(self.labelText)
  end
end

function AuctionHouseHelperConfigRadioButtonMixin:OnMouseUp()
  self.RadioButton:Click()
end

function AuctionHouseHelperConfigRadioButtonMixin:OnEnter()
  self.RadioButton:LockHighlight()
end

function AuctionHouseHelperConfigRadioButtonMixin:OnLeave()
  self.RadioButton:UnlockHighlight()
end

function AuctionHouseHelperConfigRadioButtonMixin:SetChecked(value)
  self.RadioButton:SetChecked(value)
end

function AuctionHouseHelperConfigRadioButtonMixin:GetChecked()
  return self.RadioButton:GetChecked()
end

function AuctionHouseHelperConfigRadioButtonMixin:GetValue()
  return self.value
end

function AuctionHouseHelperConfigRadioButtonMixin:OnClick()
  if self.onSelectedCallback ~= nil then
    self.onSelectedCallback()
  end
end
