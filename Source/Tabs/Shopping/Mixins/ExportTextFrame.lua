AuctionHouseHelperExportTextFrameMixin = {}

function AuctionHouseHelperExportTextFrameMixin:OnLoad()
  ScrollUtil.RegisterScrollBoxWithScrollBar(self.EditBoxContainer:GetScrollBox(), self.ScrollBar)
  self.EditBoxContainer:GetScrollBox():GetView():SetPanExtent(50)
end

function AuctionHouseHelperExportTextFrameMixin:SetOpeningEvents(open, close)
  self.openEvent = open
  self.closeEvent = close
end

function AuctionHouseHelperExportTextFrameMixin:OnShow()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperExportTextFrameMixin:OnShow()")

  self.EditBoxContainer:GetEditBox():SetFocus()
  self.EditBoxContainer:GetEditBox():HighlightText()

  if self.openEvent then
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "lists export text dialog 2")
      :Fire(self, self.openEvent)
      :UnregisterSource(self)
  end
end

function AuctionHouseHelperExportTextFrameMixin:OnHide()
  self:Hide()

  if self.closeEvent then
    AuctionHouseHelper.EventBus
      :RegisterSource(self, "lists export text dialog 2")
      :Fire(self, self.closeEvent)
      :UnregisterSource(self)
  end
end

function AuctionHouseHelperExportTextFrameMixin:SetExportString(exportString)
  self.EditBoxContainer:GetEditBox():SetText(exportString)
  self.EditBoxContainer:GetEditBox():HighlightText()
end

function AuctionHouseHelperExportTextFrameMixin:OnCloseClicked()
  self.EditBoxContainer:GetEditBox():SetText("")
  self:Hide()
end
