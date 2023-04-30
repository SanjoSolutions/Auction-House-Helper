AuctionHouseHelperItemKeyCellTemplateMixin = CreateFromMixins(AuctionHouseHelperCellMixin, AuctionHouseHelperRetailImportTableBuilderCellMixin)

function AuctionHouseHelperItemKeyCellTemplateMixin:Init()
  self.Text:SetJustifyH("LEFT")
end

function AuctionHouseHelperItemKeyCellTemplateMixin:Populate(rowData, index)
  AuctionHouseHelperCellMixin.Populate(self, rowData, index)

  self.Text:SetText(rowData.itemName or "")

  if rowData.iconTexture ~= nil then
    self.Icon:SetTexture(rowData.iconTexture)
    self.Icon:Show()
  end

  self.Icon:SetAlpha(rowData.noneAvailable and 0.5 or 1.0)
end

function AuctionHouseHelperItemKeyCellTemplateMixin:OnEnter()
  if self.rowData.itemLink then
    GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(self.rowData.itemLink)
    GameTooltip:Show()
  end
  AuctionHouseHelperCellMixin.OnEnter(self)
end

function AuctionHouseHelperItemKeyCellTemplateMixin:OnLeave()
  if self.rowData.itemLink then
    GameTooltip:Hide()
  end
  AuctionHouseHelperCellMixin.OnLeave(self)
end
