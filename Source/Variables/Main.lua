local VERSION_8_3 = 6
local POSTING_HISTORY_DB_VERSION = 1
local VENDOR_PRICE_CACHE_DB_VERSION = 1

function AuctionHouseHelper.Variables.Initialize()
  AuctionHouseHelper.Variables.InitializeSavedState()

  AuctionHouseHelper.Config.InitializeData()
  AuctionHouseHelper.Config.InitializeFrames()

  local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
  AuctionHouseHelper.State.CurrentVersion = GetAddOnMetadata("AuctionHouseHelper", "Version")

  AuctionHouseHelper.Variables.InitializeDatabase()
  AuctionHouseHelper.Variables.InitializeShoppingLists()
  AuctionHouseHelper.Variables.InitializePostingHistory()
  AuctionHouseHelper.Variables.InitializeVendorPriceCache()

  AuctionHouseHelper.State.Loaded = true
end

function AuctionHouseHelper.Variables.InitializeSavedState()
  if AUCTION_HOUSE_HELPER_SAVEDVARS == nil then
    AUCTION_HOUSE_HELPER_SAVEDVARS = {}
  end
  AuctionHouseHelper.SavedState = AUCTION_HOUSE_HELPER_SAVEDVARS
end

-- Attempt to import from other connected realms (this may happen if another
-- realm was connected or the databases are not currently shared)
--
-- Assumes rootRealm has no active database
local function ImportFromConnectedRealm(rootRealm)
  local connections = GetAutoCompleteRealms()

  if #connections == 0 then
    return false
  end

  for _, altRealm in ipairs(connections) do

    if AUCTION_HOUSE_HELPER_PRICE_DATABASE[altRealm] ~= nil then

      AUCTION_HOUSE_HELPER_PRICE_DATABASE[rootRealm] = AUCTION_HOUSE_HELPER_PRICE_DATABASE[altRealm]
      -- Remove old database (no longer needed)
      AUCTION_HOUSE_HELPER_PRICE_DATABASE[altRealm] = nil
      return true
    end
  end

  return false
end

local function ImportFromNotNormalizedName(target)
  local unwantedName = GetRealmName()

  if AUCTION_HOUSE_HELPER_PRICE_DATABASE[unwantedName] ~= nil then

    AUCTION_HOUSE_HELPER_PRICE_DATABASE[target] = AUCTION_HOUSE_HELPER_PRICE_DATABASE[unwantedName]
    -- Remove old database (no longer needed)
    AUCTION_HOUSE_HELPER_PRICE_DATABASE[unwantedName] = nil
    return true
  end

  return false
end

function AuctionHouseHelper.Variables.InitializeDatabase()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelper.Database.Initialize()")
  -- AuctionHouseHelper.Utilities.TablePrint(AUCTION_HOUSE_HELPER_PRICE_DATABASE, "AUCTION_HOUSE_HELPER_PRICE_DATABASE")

  -- First time users need the price database initialized
  if AUCTION_HOUSE_HELPER_PRICE_DATABASE == nil then
    AUCTION_HOUSE_HELPER_PRICE_DATABASE = {
      ["__dbversion"] = VERSION_8_3
    }
  end

  -- If we changed how we record item info we need to reset the DB
  if AUCTION_HOUSE_HELPER_PRICE_DATABASE["__dbversion"] ~= VERSION_8_3 then
    AUCTION_HOUSE_HELPER_PRICE_DATABASE = {
      ["__dbversion"] = VERSION_8_3
    }
  end

  local realm = AuctionHouseHelper.Variables.GetConnectedRealmRoot()

  -- Check for current realm and initialize if not present
  if AUCTION_HOUSE_HELPER_PRICE_DATABASE[realm] == nil then
    if not ImportFromNotNormalizedName(realm) and not ImportFromConnectedRealm(realm) then
      AUCTION_HOUSE_HELPER_PRICE_DATABASE[realm] = {}
    end
  end

  AuctionHouseHelper.Database = CreateAndInitFromMixin(AuctionHouseHelper.DatabaseMixin, AUCTION_HOUSE_HELPER_PRICE_DATABASE[realm])
  AuctionHouseHelper.Database:Prune()
end

function AuctionHouseHelper.Variables.InitializePostingHistory()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelper.Variables.InitializePostingHistory()")

  if AUCTION_HOUSE_HELPER_POSTING_HISTORY == nil  or
     AUCTION_HOUSE_HELPER_POSTING_HISTORY["__dbversion"] ~= POSTING_HISTORY_DB_VERSION then
    AUCTION_HOUSE_HELPER_POSTING_HISTORY = {
      ["__dbversion"] = POSTING_HISTORY_DB_VERSION
    }
  end

  AuctionHouseHelper.PostingHistory = CreateAndInitFromMixin(AuctionHouseHelper.PostingHistoryMixin, AUCTION_HOUSE_HELPER_POSTING_HISTORY)
end

function AuctionHouseHelper.Variables.InitializeShoppingLists()
  AuctionHouseHelper.Shopping.ListManager = CreateAndInitFromMixin(
    AuctionHouseHelperShoppingListManagerMixin,
    function() return AUCTION_HOUSE_HELPER_SHOPPING_LISTS end,
    function(newVal) AUCTION_HOUSE_HELPER_SHOPPING_LISTS = newVal end
  )

  AUCTION_HOUSE_HELPER_RECENT_SEARCHES = AUCTION_HOUSE_HELPER_RECENT_SEARCHES or {}
end

function AuctionHouseHelper.Variables.InitializeVendorPriceCache()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelper.Variables.InitializeVendorPriceCache()")

  if AUCTION_HOUSE_HELPER_VENDOR_PRICE_CACHE == nil  or
     AUCTION_HOUSE_HELPER_VENDOR_PRICE_CACHE["__dbversion"] ~= VENDOR_PRICE_CACHE_DB_VERSION then
    AUCTION_HOUSE_HELPER_VENDOR_PRICE_CACHE = {
      ["__dbversion"] = VENDOR_PRICE_CACHE_DB_VERSION
    }
  end
end
