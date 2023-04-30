AuctionHouseHelperCellMixin = {}

function AuctionHouseHelperCellMixin:Populate(rowData, index)
  self.rowData = rowData
  self.index = index
end

function AuctionHouseHelperCellMixin:OnEnter()
  if self:GetParent().OnEnter ~= nil then
    self:GetParent():OnEnter()
  end
end

function AuctionHouseHelperCellMixin:OnLeave()
  if self:GetParent().OnLeave ~= nil then
    self:GetParent():OnLeave()
  end
end

function AuctionHouseHelperCellMixin:OnClick(...)
  if self:GetParent().OnClick ~= nil then
    self:GetParent():OnClick(...)

    AuctionHouseHelper.Debug.Message("index", self.index)

  end
end
