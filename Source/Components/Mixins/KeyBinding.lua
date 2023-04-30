AuctionHouseHelperKeyBindingConfigMixin = CreateFromMixins(AuctionHouseHelperConfigTooltipMixin)

function AuctionHouseHelperKeyBindingConfigMixin:OnLoad()
  self.isListening = false
  self.Description:SetText(self.labelText)
  self.shortcut = ""
end

function AuctionHouseHelperKeyBindingConfigMixin:SetShortcut(shortcut)
  self.shortcut = shortcut
  if self.shortcut == "" then
    self.Button:SetText(GRAY_FONT_COLOR:WrapTextInColorCode(NOT_BOUND))
  else
    self.Button:SetText(GetBindingText(self.shortcut))
  end
end

function AuctionHouseHelperKeyBindingConfigMixin:GetShortcut(shortcut)
  return self.shortcut
end

function AuctionHouseHelperKeyBindingConfigMixin:OnHide()
  self:StopListening()
end

function AuctionHouseHelperKeyBindingConfigMixin:StartListening()
  self.isListening = true
  self:SetScript("OnMouseWheel", self.OnMouseWheel)
  self:SetScript("OnKeyDown", self.OnKeyDown)
  self.Button:SetScript("OnMouseWheel", function(button, ...)
    self:OnMouseWheel(...)
  end)
  self.Button.selectedHighlight:Show()
end
function AuctionHouseHelperKeyBindingConfigMixin:StopListening()
  self.isListening = false
  self:SetScript("OnMouseWheel", nil)
  self:SetScript("OnKeyDown", nil)
  self.Button:SetScript("OnMouseWheel", nil)
  self.Button.selectedHighlight:Hide()
end

function AuctionHouseHelperKeyBindingConfigMixin:OnClick(button)
  if button == "LeftButton" or button == "RightButton" then
    if self.isListening then
      self:StopListening()
    else
      self:StartListening()
    end
  else
    self:OnKeyDown(button)
  end
end

function AuctionHouseHelperKeyBindingConfigMixin:OnEnter()
  AuctionHouseHelperConfigTooltipMixin.OnEnter(self)
  self.Button:LockHighlight()
end
function AuctionHouseHelperKeyBindingConfigMixin:OnLeave()
  AuctionHouseHelperConfigTooltipMixin.OnLeave(self)
  self.Button:UnlockHighlight()
end

function AuctionHouseHelperKeyBindingConfigMixin:OnMouseWheel(delta)
  if delta > 0 then
    self:OnKeyDown("MOUSEWHEELUP")
  else
    self:OnKeyDown("MOUSEWHEELDOWN")
  end
end

function AuctionHouseHelperKeyBindingConfigMixin:OnKeyDown(keyOrButton)
  if GetBindingFromClick(keyOrButton) == "SCREENSHOT" then
    self:SetPropagateKeyboardInput(true)
    return
  elseif keyOrButton == "ESCAPE" then
    self:SetShortcut("")
    self:StopListening()
    return
  end

  local keyPressed = GetConvertedKeyOrButton(keyOrButton)
  self:SetPropagateKeyboardInput(false)
  if not IsKeyPressIgnoredForBinding(keyPressed) then
    if CreateKeyChordStringUsingMetaKeyState then
      keyPressed = CreateKeyChordStringUsingMetaKeyState(keyPressed)
    else --if AuctionHouseHelper.Constants.IsClassic
      keyPressed = CreateKeyChordString(keyPressed)
    end
    self:SetShortcut(keyPressed)
    self:StopListening()
  end
end
