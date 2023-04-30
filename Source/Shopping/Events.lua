AuctionHouseHelper.Shopping.Events = {
  -- Changes to list meta data (including renames, deletes and pruning)
  ListMetaChange = "shopping list meta change",
  -- Changes to individual items in a list (edit, delete, add, etc.)
  ListItemChange = "shopping list item change",
  -- The list import code finished importing whatever data was supplied
  ListImportFinished = "shopping list import finished",

  RecentSearchesUpdate = "shopping tab recent searches update",
}

AuctionHouseHelper.Shopping.Tab.Events = {
  ListSelected = "AUCTION_HOUSE_HELPER_LIST_SELECTED",
  ListCreated = "AUCTION_HOUSE_HELPER_LIST_CREATED",
  ListRenamed = "AUCTION_HOUSE_HELPER_LIST_RENAMED",

  ListItemAdded = "AUCTION_HOUSE_HELPER_LIST_ITEM_ADDED",
  ListItemSelected = "AUCTION_HOUSE_HELPER_LIST_ITEM_SELECTED",
  DeleteFromList = "AUCTION_HOUSE_HELPER_DELETE_FROM_CURRENT_LIST",
  EditListItem = "AUCTION_HOUSE_HELPER_EDIT_LIST_ITEM",
  CopyIntoList = "AUCTION_HOUSE_HELPER_COPY_INTO_LIST",

  DragItemStart = "shopping tab list drag item start",
  DragItemEnter = "shopping tab list drag item enter",
  DragItemStop = "shopping tab list drag item stop",

  OneItemSearch = "shopping tab one item search",
  RecentSearchesUpdate = "shopping tab recent searches update",

  SearchForTerms = "AUCTION_HOUSE_HELPER_SEARCH_FOR_TERMS",
  CancelSearch = "AUCTION_HOUSE_HELPER_CANCEL_SEARCH",

  ListSearchStarted = "AUCTION_HOUSE_HELPER_LIST_SEARCH_STARTED",
  ListSearchIncrementalUpdate = "AUCTION_HOUSE_HELPER_LIST_SEARCH_INCREMENTAL_UPDATE",
  ListSearchEnded = "AUCTION_HOUSE_HELPER_LIST_SEARCH_ENDED",
  ListSearchRequested = "AUCTION_HOUSE_HELPER_LIST_SEARCH_REQUESTED",
  ListAbortSearch = "AUCTION_HOUSE_HELPER_LIST_ABORT_SEARCH",

  DialogOpened = "SHOPPING_DIALOG_OPENED",
  DialogClosed = "SHOPPING_DIALOG_CLOSED",

  ShowHistoricalPrices = "SHOPPING_SHOW_HISTORICAL_PRICES",
}
