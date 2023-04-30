AuctionHouseHelperListImportFrameMixin = {}

function AuctionHouseHelperListImportFrameMixin:OnLoad()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperListImportFrameMixin:OnLoad()")

  ScrollUtil.RegisterScrollBoxWithScrollBar(self.EditBoxContainer:GetScrollBox(), self.ScrollBar)
  self.EditBoxContainer:GetScrollBox():GetView():SetPanExtent(50)
end

function AuctionHouseHelperListImportFrameMixin:OnShow()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperListImportFrameMixin:OnShow()")

  self.EditBoxContainer:GetEditBox():SetFocus()

  AuctionHouseHelper.EventBus
    :RegisterSource(self, "lists import dialog")
    :Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionHouseHelperListImportFrameMixin:OnHide()
  self.EditBoxContainer:GetEditBox():SetText("")
  self:Hide()
  AuctionHouseHelper.EventBus
    :RegisterSource(self, "lists import dialog")
    :Fire(self, AuctionHouseHelper.Shopping.Tab.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionHouseHelperListImportFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == AuctionHouseHelper.Shopping.Events.ListImportFinished then
    AuctionHouseHelper.EventBus:Unregister(self, { AuctionHouseHelper.Shopping.Events.ListImportFinished })
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "lists import dialog")
      :Fire(self, AuctionHouseHelper.Shopping.Tab.Events.ListCreated, AuctionHouseHelper.Shopping.ListManager:GetByName(eventData))
      :UnregisterSource(self)
  end
end

function AuctionHouseHelperListImportFrameMixin:OnCloseDialogClicked()
  self:Hide()
end

function AuctionHouseHelperListImportFrameMixin:OnImportClicked()
  -- register finished event early as sometimes it fires immediately
  AuctionHouseHelper.EventBus:Register(self, { AuctionHouseHelper.Shopping.Events.ListImportFinished })

  local importString = self.EditBoxContainer:GetEditBox():GetText()

  local waiting = true
  if string.match(importString, "%^") then
    AuctionHouseHelper.Debug.Message("Import shopping list with 8.3+ format")
    AuctionHouseHelper.Shopping.Lists.BatchImportFromString(importString)
  elseif string.match(importString, "%*") then
    AuctionHouseHelper.Debug.Message("Import shopping list from old format")
    AuctionHouseHelper.Shopping.Lists.OldBatchImportFromString(importString)
  elseif string.match(importString, "%,") then
    AuctionHouseHelper.Debug.Message("Import shopping list from TSM group")
    AuctionHouseHelper.Shopping.Lists.TSMImportFromString(importString)
  else
    waiting = false
  end

  -- Only listen for the import finished event if a valid format was detected
  if not waiting then
    AuctionHouseHelper.EventBus:Unregister(self, { AuctionHouseHelper.Shopping.Events.ListImportFinished })
  end

  self:Hide()
end
