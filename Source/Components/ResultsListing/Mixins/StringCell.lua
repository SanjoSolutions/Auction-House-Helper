AuctionHouseHelperStringCellTemplateMixin = CreateFromMixins(AuctionHouseHelperCellMixin, AuctionHouseHelperRetailImportTableBuilderCellMixin)

function AuctionHouseHelperStringCellTemplateMixin:Init(columnName)
  self.columnName = columnName

  self.text:SetJustifyH("LEFT")
end

function AuctionHouseHelperStringCellTemplateMixin:Populate(rowData, index)
  AuctionHouseHelperCellMixin.Populate(self, rowData, index)

  self.text:SetText(rowData[self.columnName])
end

function AuctionHouseHelperStringCellTemplateMixin:OnHide()
  self.text:Hide()
end

function AuctionHouseHelperStringCellTemplateMixin:OnShow()
  self.text:Show()
end
