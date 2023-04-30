AuctionHouseHelper.Tabs = {}

AuctionHouseHelper.Tabs.State = {
  knownTabs = {}
}

-- details = {
--  name, -> string
--  textLabel, -> string
--  tabTemplate, -> string
--  tabHeader, -> string
--  displayModeKey, -> string
--  tabOrder -> number
-- }
function AuctionHouseHelper.Tabs.Register(details)
  table.insert(AuctionHouseHelper.Tabs.State.knownTabs, details)
end

AuctionHouseHelper.Tabs.Register( {
  name = "Shopping",
  textLabel = AUCTION_HOUSE_HELPER_L_SHOPPING_TAB,
  tabTemplate = "AuctionHouseHelperShoppingClassicTabFrameTemplate",
  tabHeader = AUCTION_HOUSE_HELPER_L_SHOPPING_TAB_HEADER_2,
  tabFrameName = "AuctionHouseHelperShoppingFrame",
  tabOrder = 1,
})
AuctionHouseHelper.Tabs.Register( {
  name = "AuctionHouseHelper",
  textLabel = AUCTION_HOUSE_HELPER_L_AUCTION_HOUSE_HELPER,
  tabTemplate = "AuctionHouseHelperConfigurationTabFrameTemplate",
  tabHeader = AUCTION_HOUSE_HELPER_L_INFO_TAB_HEADER,
  tabFrameName = "AuctionHouseHelperConfigFrame",
  tabOrder = 4,
})
AuctionHouseHelper.Tabs.Register( {
  name = "Cancelling",
  textLabel = AUCTION_HOUSE_HELPER_L_CANCELLING_TAB,
  tabTemplate = "AuctionHouseHelperCancellingTabFrameNoRefreshTemplate",
  tabHeader = AUCTION_HOUSE_HELPER_L_CANCELLING_TAB_HEADER,
  tabFrameName = "AuctionHouseHelperCancellingFrame",
  tabOrder = 3,
})
AuctionHouseHelper.Tabs.Register( {
  name = "Selling",
  textLabel = AUCTION_HOUSE_HELPER_L_SELLING_TAB,
  tabTemplate = "AuctionHouseHelperSellingTabFrameTemplate",
  tabHeader = AUCTION_HOUSE_HELPER_L_SELLING_TAB_HEADER,
  tabFrameName = "AuctionHouseHelperSellingFrame",
  tabOrder = 2,
})
