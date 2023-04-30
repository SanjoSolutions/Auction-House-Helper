AuctionHouseHelperCancellingListResultsRowMixin = CreateFromMixins(AuctionHouseHelperResultsRowTemplateMixin)

function AuctionHouseHelperCancellingListResultsRowMixin:OnClick(button, ...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperCancellingListResultsRowMixin:OnClick", self.rowData and self.rowData.id)

  if IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);

  elseif IsModifiedClick("CHATLINK") then
    ChatEdit_InsertLink(self.rowData.itemLink)

  elseif button == "LeftButton" and AuctionHouseHelper.AH.IsNotThrottled() then
    self.rowData.cancelled = true
    self:ApplyFade()

    AuctionHouseHelper.EventBus
      :RegisterSource(self, "CancellingListResultRow")
      :Fire(self, AuctionHouseHelper.Cancelling.Events.RequestCancel, self.rowData)
      :UnregisterSource(self)
  elseif button == "RightButton" then
    AuctionHouseHelper.API.v1.MultiSearchExact(AUCTION_HOUSE_HELPER_L_CANCELLING_TAB, { AuctionHouseHelper.Utilities.GetNameFromLink(self.rowData.itemLink) })
  end
end

function AuctionHouseHelperCancellingListResultsRowMixin:OnEnter()
  if AuctionHouseHelper.AH.IsNotThrottled() then
    AuctionHouseHelperResultsRowTemplateMixin.OnEnter(self)
  end
end

function AuctionHouseHelperCancellingListResultsRowMixin:OnLeave()
  AuctionHouseHelperResultsRowTemplateMixin.OnLeave(self)
end

function AuctionHouseHelperCancellingListResultsRowMixin:Populate(rowData, dataIndex)
  AuctionHouseHelperResultsRowTemplateMixin.Populate(self, rowData, dataIndex)

  self:ApplyFade()
  self:ApplyHighlight()
end

function AuctionHouseHelperCancellingListResultsRowMixin:ApplyFade()
  --Fade while waiting for the cancel to take effect
  if self.rowData.cancelled then
    self:SetAlpha(0.5)
  else
    self:SetAlpha(1)
  end
end

function AuctionHouseHelperCancellingListResultsRowMixin:ApplyHighlight()
  if self.rowData.undercut == AUCTION_HOUSE_HELPER_L_UNDERCUT_YES then
    self.SelectedHighlight:Show()
  else
    self.SelectedHighlight:Hide()
  end
end
