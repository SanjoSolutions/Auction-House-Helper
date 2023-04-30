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
  -- Process itemLink directly (as bug in Blizz code prevents potions with a
  -- quality rating having their tooltip show)
  if self.rowData.itemLink and not AuctionHouseHelper.Utilities.IsPetLink(self.rowData.itemLink) then
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(self.rowData.itemLink)
    GameTooltip:Show()
  else
    AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  end
  AuctionHouseHelperCellMixin.OnEnter(self)
end

function AuctionHouseHelperItemKeyCellTemplateMixin:OnLeave()
  if self.rowData.itemLink ~= nil and not AuctionHouseHelper.Utilities.IsPetLink(self.rowData.itemLink) then
    GameTooltip:Hide()
  else
    AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  end
  AuctionHouseHelperCellMixin.OnLeave(self)
end
