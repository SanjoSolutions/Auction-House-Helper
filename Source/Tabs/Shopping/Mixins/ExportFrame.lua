AuctionHouseHelperListExportFrameMixin = {}

function AuctionHouseHelperListExportFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperListExportFrameMixin:OnLoad()")

  -- Setup scrolling region
  local view = CreateScrollBoxLinearView()
  view:SetPadding(5, 5, 0, 0, 0)
  view:SetPanExtent(50)
  ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);

  self.ScrollBox.ListListingFrame.OnCleaned = function()
    self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
  end

  self.copyTextDialog = CreateFrame("Frame", nil, self:GetParent(), "AuctionHouseHelperExportTextFrame")
  self.copyTextDialog:SetPoint("CENTER")

  -- self.ExportOption:SetOnChange(function(selectedValue)
  --   if selectedValue == AuctionHouseHelper.Constants.EXPORT_TYPES.WHISPER then
  --     self.Recipient:Show()
  --     self.Recipient:SetFocus()
  --   else
  --     self.Recipient:Hide()
  --   end
  -- end)
  -- self.ExportOption:SetSelectedValue(AuctionHouseHelper.Constants.EXPORT_TYPES.STRING)

  self.checkBoxPool = CreateFramePool("Frame", self.ScrollBox.ListListingFrame, "AuctionHouseHelperConfigurationCheckbox")
end

function AuctionHouseHelperListExportFrameMixin:OnShow()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperListExportFrameMixin:OnShow()")

  AuctionHouseHelper.EventBus:Register(self, { AuctionHouseHelper.Shopping.Events.ListMetaChange })

  self:RefreshLists()

  AuctionHouseHelper.EventBus
    :RegisterSource(self, "lists export dialog 1")
    :Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionHouseHelperListExportFrameMixin:OnHide()
  self:Hide()

  AuctionHouseHelper.EventBus:Unregister(self, { AuctionHouseHelper.Shopping.Events.ListMetaChange })

  AuctionHouseHelper.EventBus
    :RegisterSource(self, "lists export dialog 1")
    :Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionHouseHelperListExportFrameMixin:ReceiveEvent(eventName, listName)
  if eventName == AuctionHouseHelper.Shopping.Events.ListMetaChange then
    if self:IsShown() then
      self:RefreshLists()
    end
  end
end

function AuctionHouseHelperListExportFrameMixin:RefreshLists()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperListExportFrameMixin:RefreshLists()")
  self.checkBoxPool:ReleaseAll()

  for index = 1, AuctionHouseHelper.Shopping.ListManager:GetCount() do
    local list = AuctionHouseHelper.Shopping.ListManager:GetByIndex(index)
    local checkBox = self.checkBoxPool:Acquire()
    checkBox:SetText(list:GetName())
    checkBox:SetHeight(25)
    checkBox:SetPoint("TOPRIGHT", self.ScrollBox.ListListingFrame, "TOPRIGHT", 0, -(checkBox:GetHeight()) * (index - 1))
    checkBox:SetPoint("TOPLEFT", self.ScrollBox.ListListingFrame, "TOPLEFT", 0, -(checkBox:GetHeight()) * (index - 1))
    checkBox:Show()
  end

  self.ScrollBox.ListListingFrame:MarkDirty()
end

function AuctionHouseHelperListExportFrameMixin:OnCloseDialogClicked()
  self:Hide()
end

function AuctionHouseHelperListExportFrameMixin:OnSelectAllClicked()
  for checkbox in self.checkBoxPool:EnumerateActive() do
    checkbox:SetChecked(true)
  end
end

function AuctionHouseHelperListExportFrameMixin:OnUnselectAllClicked()
  for checkbox in self.checkBoxPool:EnumerateActive() do
    checkbox:SetChecked(false)
  end
end

function AuctionHouseHelperListExportFrameMixin:OnExportClicked()
  local exportString = ""

  for checkbox in self.checkBoxPool:EnumerateActive() do
    if checkbox:GetChecked() then
      exportString = exportString .. AuctionHouseHelper.Shopping.Lists.GetBatchExportString(checkbox:GetText()) .. "\n"
    end
  end

  -- if self.ExportOption:GetValue() == 0 then
    self:Hide()
    self.copyTextDialog:SetExportString(exportString)
    self.copyTextDialog:Show()
  -- else
    -- Addon messages can not exceed 254 characters, so do lists one by one?
    -- for checkbox in self.checkBoxPool:EnumerateActive() do
    --   if checkbox:IsVisible() and checkbox:GetChecked() then
    --     C_ChatInfo.SendAddonMessage( "AuctionHouseHelper", AuctionHouseHelper.Shopping.Lists.GetBatchExportString(checkbox:GetText()), "WHISPER", self.Recipient:GetText())
    --   end
    -- end
    -- C_ChatInfo.SendAddonMessage( "AuctionHouseHelper", exportString, "WHISPER", self.Recipient:GetText())
  -- end

end
