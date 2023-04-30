AuctionHouseHelperResultsRowTemplateMixin = {}

function AuctionHouseHelperResultsRowTemplateMixin:OnClick(...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperResultsRowTemplateMixin:OnClick()", ...)
end

function AuctionHouseHelperResultsRowTemplateMixin:OnEnter(...)
  self.HighlightTexture:Show()
end

function AuctionHouseHelperResultsRowTemplateMixin:OnLeave(...)
  self.HighlightTexture:Hide()
end

function AuctionHouseHelperResultsRowTemplateMixin:Populate(rowData, dataIndex)
  self.rowData = rowData
  self.dataIndex = dataIndex
end
