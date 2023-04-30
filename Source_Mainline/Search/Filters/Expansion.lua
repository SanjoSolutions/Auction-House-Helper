AuctionHouseHelper.Search.Filters.ExpansionMixin = {}

function AuctionHouseHelper.Search.Filters.ExpansionMixin:Init(filterTracker, browseResult, expansion)
  self.expansion = expansion
  self.completed = false

  if not C_Item.DoesItemExistByID(browseResult.itemKey.itemID) then
    filterTracker:ReportFilterComplete(false)
  else
    local item = Item:CreateFromItemID(browseResult.itemKey.itemID)
    item:ContinueOnItemLoad(function()
      filterTracker:ReportFilterComplete(self:FilterCheck(browseResult.itemKey))
    end)
  end
end

function AuctionHouseHelper.Search.Filters.ExpansionMixin:FilterCheck(itemKey)
  return self:ExpansionCheck(itemKey)
end

function AuctionHouseHelper.Search.Filters.ExpansionMixin:ExpansionCheck(itemKey)
  return (select(AuctionHouseHelper.Constants.ITEM_INFO.XPAC, GetItemInfo(itemKey.itemID))) == self.expansion
end
