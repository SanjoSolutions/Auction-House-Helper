AuctionHouseHelper.Config.ItemMatching = {
  ITEM_ID_AND_LEVEL = "item level only",
  ITEM_ID = "item id",
  ITEM_NAME_AND_LEVEL = "item name and level",
  ITEM_NAME_ONLY = "item name only",
}

AuctionHouseHelper.Config.Options.SMALL_TABS = "small_tabs"
AuctionHouseHelper.Config.Options.PET_TOOLTIPS = "pet_tooltips"
AuctionHouseHelper.Config.Options.AUTOSCAN = "autoscan_2"
AuctionHouseHelper.Config.Options.AUTOSCAN_INTERVAL = "autoscan_interval"
AuctionHouseHelper.Config.Options.SELLING_CANCEL_SHORTCUT = "selling_cancel_shortcut"
AuctionHouseHelper.Config.Options.SELLING_BUY_SHORTCUT = "selling_buy_shortcut"
AuctionHouseHelper.Config.Options.SELLING_SPLIT_PANELS = "selling_split_panels"

AuctionHouseHelper.Config.Options.AUCTION_DURATION = "auction_duration"
AuctionHouseHelper.Config.Options.AUCTION_SALES_PREFERENCE = "auction_sales_preference"
AuctionHouseHelper.Config.Options.UNDERCUT_PERCENTAGE = "undercut_percentage"
AuctionHouseHelper.Config.Options.UNDERCUT_STATIC_VALUE = "undercut_static_value"
AuctionHouseHelper.Config.Options.SELLING_ITEM_MATCHING = "selling_item_matching"

AuctionHouseHelper.Config.Options.DEFAULT_QUANTITIES = "default_quantities"
AuctionHouseHelper.Config.Options.UNDERCUT_SCAN_NOT_LIFO = "undercut_scan_not_lifo"
AuctionHouseHelper.Config.Options.UNDERCUT_SCAN_GEAR_MATCH_ILVL_VARIANTS = "undercut_scan_gear_use_ilvl_variants"

AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.SMALL_TABS] = false
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.PET_TOOLTIPS] = true
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.AUTOSCAN] = false
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.AUTOSCAN_INTERVAL] = 15
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.UNDERCUT_SCAN_NOT_LIFO] = true
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.UNDERCUT_SCAN_GEAR_MATCH_ILVL_VARIANTS] = true
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.SELLING_CANCEL_SHORTCUT] = AuctionHouseHelper.Config.Shortcuts.RIGHT_CLICK
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.SELLING_BUY_SHORTCUT] = AuctionHouseHelper.Config.Shortcuts.ALT_RIGHT_CLICK
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.SELLING_SPLIT_PANELS] = false

AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.AUCTION_DURATION] = 24
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.AUCTION_SALES_PREFERENCE] = AuctionHouseHelper.Config.SalesTypes.PERCENTAGE
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.UNDERCUT_PERCENTAGE] = 0
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.UNDERCUT_STATIC_VALUE] = 0
AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.SELLING_ITEM_MATCHING] = AuctionHouseHelper.Config.ItemMatching.ITEM_NAME_AND_LEVEL

AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options.DEFAULT_QUANTITIES] = {
  [Enum.ItemClass.Weapon]           = 1,
  [Enum.ItemClass.Armor]            = 1,
  [Enum.ItemClass.Container]        = 0,
  [Enum.ItemClass.Gem]              = 0,
  [Enum.ItemClass.ItemEnhancement]  = 0,
  [Enum.ItemClass.Consumable]       = 0,
  [Enum.ItemClass.Glyph]            = 0,
  [Enum.ItemClass.Tradegoods]       = 0,
  [Enum.ItemClass.Profession]       = 0,
  [Enum.ItemClass.Recipe]           = 0,
  [Enum.ItemClass.Battlepet]        = 1,
  [Enum.ItemClass.Questitem]        = 0,
  [Enum.ItemClass.Miscellaneous]    = 0,
}
