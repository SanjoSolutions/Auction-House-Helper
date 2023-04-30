AuctionHouseHelper.Config.Options = {
  DEBUG = "debug",
  NO_PRICE_DATABASE = "no_price_database",
  MAILBOX_TOOLTIPS = "mailbox_tooltips",
  VENDOR_TOOLTIPS = "vendor_tooltips",
  AUCTION_TOOLTIPS = "auction_tooltips",
  SHIFT_STACK_TOOLTIPS = "shift_stack_tooltips",
  ENCHANT_TOOLTIPS = "enchant_tooltips",
  REPLICATE_SCAN = "replicate_scan_3",
  AUTO_LIST_SEARCH = "auto_list_search",
  DEFAULT_LIST = "default_list_2",

  DEFAULT_TAB = "default_tab",

  AUCTION_CHAT_LOG = "auction_chat_log",
  SELLING_BAG_COLLAPSED = "selling_bag_collapsed",
  SHOW_SELLING_BAG = "show_selling_bag",
  SELLING_BAG_SELECT_SHORTCUT = "selling_bag_select_shortcut",
  SELLING_ICON_SIZE = "selling_icon_size",
  SELLING_IGNORED_KEYS = "selling_ignored_keys",
  SELLING_FAVOURITE_KEYS = "selling_favourite_keys_2",
  SELLING_AUTO_SELECT_NEXT = "selling_auto_select_next",
  SELLING_MISSING_FAVOURITES = "selling_missing_favourites",
  SELLING_POST_SHORTCUT = "selling_post_shortcut",
  SELLING_SKIP_SHORTCUT = "selling_skip_shortcut",
  SHOW_SELLING_BID_PRICE = "show_selling_bid_price",
  SELLING_CONFIRM_LOW_PRICE = "selling_confirm_low_price",
  SAVE_LAST_DURATION_AS_DEFAULT = "save_last_duration_as_default",

  GEAR_PRICE_MULTIPLIER = "gear_vendor_price_multiplier",

  PRICE_HISTORY_DAYS = "price_history_days",
  POSTING_HISTORY_LENGTH = "auctions_history_length",

  SPLASH_SCREEN_VERSION = "splash_screen_version",
  HIDE_SPLASH_SCREEN = "hide_splash_screen",

  CANCEL_UNDERCUT_SHORTCUT = "cancel_undercut_shortcut",

  COLUMNS_SHOPPING = "columns_shopping",
  COLUMNS_SHOPPING_HISTORICAL_PRICES = "columns_shopping_historical_prices",
  COLUMNS_SELLING_SEARCH = "columns_selling_search_3",
  COLUMNS_HISTORICAL_PRICES = "historical_prices",
  COLUMNS_POSTING_HISTORY = "columns_posting_history",
  COLUMNS_CANCELLING = "columns_cancelling",

  CRAFTING_INFO_SHOW = "crafting_info_show",
  CRAFTING_INFO_SHOW_PROFIT = "crafting_info_show_profit",
  CRAFTING_INFO_SHOW_COST = "crafting_info_show_cost",

  SHOPPING_LIST_MISSING_TERMS = "shopping_list_missing_terms",
}

AuctionHouseHelper.Config.SalesTypes = {
  PERCENTAGE = "percentage",
  STATIC = "static"
}

AuctionHouseHelper.Config.Shortcuts = {
  LEFT_CLICK = "left click",
  RIGHT_CLICK = "right click",
  ALT_LEFT_CLICK = "alt left click",
  SHIFT_LEFT_CLICK = "shift left click",
  ALT_RIGHT_CLICK = "alt right click",
  SHIFT_RIGHT_CLICK = "shift right click",
  NONE = "none",
}

AuctionHouseHelper.Config.Defaults = {
  [AuctionHouseHelper.Config.Options.DEBUG] = false,
  [AuctionHouseHelper.Config.Options.NO_PRICE_DATABASE] = false,
  [AuctionHouseHelper.Config.Options.MAILBOX_TOOLTIPS] = true,
  [AuctionHouseHelper.Config.Options.VENDOR_TOOLTIPS] = true,
  [AuctionHouseHelper.Config.Options.AUCTION_TOOLTIPS] = true,
  [AuctionHouseHelper.Config.Options.SHIFT_STACK_TOOLTIPS] = true,
  [AuctionHouseHelper.Config.Options.ENCHANT_TOOLTIPS] = false,
  [AuctionHouseHelper.Config.Options.REPLICATE_SCAN] = false,
  [AuctionHouseHelper.Config.Options.AUTO_LIST_SEARCH] = true,
  [AuctionHouseHelper.Config.Options.DEFAULT_LIST] = AuctionHouseHelper.Constants.NO_LIST,
  [AuctionHouseHelper.Config.Options.AUCTION_CHAT_LOG] = true,
  [AuctionHouseHelper.Config.Options.SELLING_BAG_COLLAPSED] = false,
  [AuctionHouseHelper.Config.Options.SHOW_SELLING_BAG] = true,
  [AuctionHouseHelper.Config.Options.SELLING_BAG_SELECT_SHORTCUT] = AuctionHouseHelper.Config.Shortcuts.ALT_LEFT_CLICK,
  [AuctionHouseHelper.Config.Options.SELLING_ICON_SIZE] = 42,
  [AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS] = {},
  [AuctionHouseHelper.Config.Options.SELLING_FAVOURITE_KEYS] = {},
  [AuctionHouseHelper.Config.Options.SELLING_AUTO_SELECT_NEXT] = false,
  [AuctionHouseHelper.Config.Options.SELLING_MISSING_FAVOURITES] = true,
  [AuctionHouseHelper.Config.Options.SELLING_POST_SHORTCUT] = "SPACE",
  [AuctionHouseHelper.Config.Options.SELLING_SKIP_SHORTCUT] = "SHIFT-SPACE",
  [AuctionHouseHelper.Config.Options.SHOW_SELLING_BID_PRICE] = false,
  [AuctionHouseHelper.Config.Options.SELLING_CONFIRM_LOW_PRICE] = true,
  [AuctionHouseHelper.Config.Options.SAVE_LAST_DURATION_AS_DEFAULT] = false,

  [AuctionHouseHelper.Config.Options.GEAR_PRICE_MULTIPLIER] = 0,

  [AuctionHouseHelper.Config.Options.PRICE_HISTORY_DAYS] = 21,
  [AuctionHouseHelper.Config.Options.POSTING_HISTORY_LENGTH] = 10,

  [AuctionHouseHelper.Config.Options.SPLASH_SCREEN_VERSION] = "anything",
  [AuctionHouseHelper.Config.Options.HIDE_SPLASH_SCREEN] = false,

  [AuctionHouseHelper.Config.Options.CANCEL_UNDERCUT_SHORTCUT] = "SPACE",

  [AuctionHouseHelper.Config.Options.DEFAULT_TAB] = 0,

  [AuctionHouseHelper.Config.Options.COLUMNS_SHOPPING] = {},
  [AuctionHouseHelper.Config.Options.COLUMNS_SHOPPING_HISTORICAL_PRICES] = {},
  [AuctionHouseHelper.Config.Options.COLUMNS_CANCELLING] = {},
  [AuctionHouseHelper.Config.Options.COLUMNS_SELLING_SEARCH] = {},
  [AuctionHouseHelper.Config.Options.COLUMNS_HISTORICAL_PRICES] = {},
  [AuctionHouseHelper.Config.Options.COLUMNS_POSTING_HISTORY] = {},

  [AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW] = true,
  [AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW_PROFIT] = true,
  [AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW_COST] = true,

  [AuctionHouseHelper.Config.Options.SHOPPING_LIST_MISSING_TERMS] = false,
}

function AuctionHouseHelper.Config.IsValidOption(name)
  for _, option in pairs(AuctionHouseHelper.Config.Options) do
    if option == name then
      return true
    end
  end
  return false
end

function AuctionHouseHelper.Config.Create(constant, name, defaultValue)
  AuctionHouseHelper.Config.Options[constant] = name

  AuctionHouseHelper.Config.Defaults[AuctionHouseHelper.Config.Options[constant]] = defaultValue

  if AUCTION_HOUSE_HELPER_CONFIG ~= nil and AUCTION_HOUSE_HELPER_CONFIG[name] == nil then
    AUCTION_HOUSE_HELPER_CONFIG[name] = defaultValue
  end
  if AUCTION_HOUSE_HELPER_CHARACTER_CONFIG ~= nil and AUCTION_HOUSE_HELPER_CHARACTER_CONFIG[name] == nil then
    AUCTION_HOUSE_HELPER_CHARACTER_CONFIG[name] = defaultValue
  end
end

function AuctionHouseHelper.Config.Set(name, value)
  if AUCTION_HOUSE_HELPER_CONFIG == nil then
    error("AUCTION_HOUSE_HELPER_CONFIG not initialized")
  elseif not AuctionHouseHelper.Config.IsValidOption(name) then
    error("Invalid option '" .. name .. "'")
  elseif AUCTION_HOUSE_HELPER_CHARACTER_CONFIG ~= nil then
    AUCTION_HOUSE_HELPER_CHARACTER_CONFIG[name] = value
  else
    AUCTION_HOUSE_HELPER_CONFIG[name] = value
  end
end

function AuctionHouseHelper.Config.SetCharacterConfig(enabled)
  if enabled then
    if AUCTION_HOUSE_HELPER_CHARACTER_CONFIG == nil then
      AUCTION_HOUSE_HELPER_CHARACTER_CONFIG = {}
    end

    AuctionHouseHelper.Config.InitializeCharacterConfig()
  else
    AUCTION_HOUSE_HELPER_CHARACTER_CONFIG = nil
  end
end

function AuctionHouseHelper.Config.IsCharacterConfig()
  return AUCTION_HOUSE_HELPER_CHARACTER_CONFIG ~= nil
end

function AuctionHouseHelper.Config.Reset()
  AUCTION_HOUSE_HELPER_CONFIG = {}
  AUCTION_HOUSE_HELPER_CHARACTER_CONFIG = nil
  for option, value in pairs(AuctionHouseHelper.Config.Defaults) do
    AUCTION_HOUSE_HELPER_CONFIG[option] = value
  end
end

function AuctionHouseHelper.Config.InitializeData()
  if AUCTION_HOUSE_HELPER_CONFIG == nil then
    AuctionHouseHelper.Config.Reset()
  else
    for option, value in pairs(AuctionHouseHelper.Config.Defaults) do
      if AUCTION_HOUSE_HELPER_CONFIG[option] == nil then
        AuctionHouseHelper.Debug.Message("Setting default config for "..option)
        AUCTION_HOUSE_HELPER_CONFIG[option] = value
      end
    end
    AuctionHouseHelper.Config.InitializeCharacterConfig()
  end
end

function AuctionHouseHelper.Config.InitializeCharacterConfig()
  if AuctionHouseHelper.Config.IsCharacterConfig() then
    for key, value in pairs(AUCTION_HOUSE_HELPER_CONFIG) do
      if AUCTION_HOUSE_HELPER_CHARACTER_CONFIG[key] == nil then
        AUCTION_HOUSE_HELPER_CHARACTER_CONFIG[key] = value
      end
    end
  end
end

function AuctionHouseHelper.Config.Get(name)
  -- This is ONLY if a config is asked for before variables are loaded
  if AUCTION_HOUSE_HELPER_CONFIG == nil then
    return AuctionHouseHelper.Config.Defaults[name]
  elseif AUCTION_HOUSE_HELPER_CHARACTER_CONFIG ~= nil then
    return AUCTION_HOUSE_HELPER_CHARACTER_CONFIG[name]
  else
    return AUCTION_HOUSE_HELPER_CONFIG[name]
  end
end
