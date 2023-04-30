AuctionHouseHelperBagListResultsRowMixin = CreateFromMixins(AuctionHouseHelperResultsRowTemplateMixin)

function AuctionHouseHelperBagListResultsRowMixin:OnClick(...)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperBagListResultsRowMixin:OnClick()")
  AuctionHouseHelper.Utilities.TablePrint(self.rowData)

end
