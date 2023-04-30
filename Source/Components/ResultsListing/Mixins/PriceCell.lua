AuctionHouseHelperPriceCellTemplateMixin = CreateFromMixins(AuctionHouseHelperCellMixin, AuctionHouseHelperRetailImportTableBuilderCellMixin)

function AuctionHouseHelperPriceCellTemplateMixin:Init(columnName)
  self.columnName = columnName
end

function AuctionHouseHelperPriceCellTemplateMixin:Populate(rowData, index)
  AuctionHouseHelperCellMixin.Populate(self, rowData, index)

  if rowData[self.columnName] ~= nil then
    self.MoneyDisplay:SetAmount(rowData[self.columnName])
    self.MoneyDisplay:Show()
  else
    self.MoneyDisplay:Hide()
  end
end
