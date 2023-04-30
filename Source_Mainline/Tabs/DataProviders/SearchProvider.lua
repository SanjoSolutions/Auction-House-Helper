local SEARCH_PROVIDER_LAYOUT = {
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "price" },
    headerText = AUCTION_HOUSE_HELPER_L_BUYOUT_PRICE,
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "price" },
    width = 145
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "bidPrice" },
    headerText = AUCTION_HOUSE_HELPER_L_BID_PRICE,
    cellTemplate = "AuctionHouseHelperPriceCellTemplate",
    cellParameters = { "bidPrice" },
    width = 145
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "quantityFormatted" },
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerText = AUCTION_HOUSE_HELPER_L_ITEM_LEVEL_COLUMN,
    headerParameters = { "level" },
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "levelPretty" },
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "timeLeft" },
    headerText = AUCTION_HOUSE_HELPER_L_TIME_LEFT,
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "timeLeftPretty" },
    defaultHide = true,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "otherSellers" },
    headerText = AUCTION_HOUSE_HELPER_L_SELLERS_COLUMN,
    cellTemplate = "AuctionHouseHelperTooltipStringCellTemplate",
    cellParameters = { "otherSellers" },
    defaultHide = true,
  },
  {
    headerTemplate = "AuctionHouseHelperStringColumnHeaderTemplate",
    headerParameters = { "owned" },
    headerText = AUCTION_HOUSE_HELPER_L_OWNED_COLUMN,
    cellTemplate = "AuctionHouseHelperStringCellTemplate",
    cellParameters = { "owned" },
    width = 70
  },
}

local SEARCH_EVENTS = {
  "COMMODITY_SEARCH_RESULTS_UPDATED",
  "COMMODITY_PURCHASE_SUCCEEDED",
  "ITEM_SEARCH_RESULTS_UPDATED",
}

AuctionHouseHelperSearchDataProviderMixin = CreateFromMixins(AuctionHouseHelperDataProviderMixin)

function AuctionHouseHelperSearchDataProviderMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, SEARCH_EVENTS)
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Selling.Events.SellSearchStart,
    AuctionHouseHelper.Selling.Events.BagItemClicked,
    AuctionHouseHelper.Cancelling.Events.RequestCancel,
  })

  self:Reset()
end

function AuctionHouseHelperSearchDataProviderMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
  AuctionHouseHelper.EventBus:Unregister(self, {
    AuctionHouseHelper.Selling.Events.SellSearchStart,
    AuctionHouseHelper.Selling.Events.BagItemClicked,
    AuctionHouseHelper.Cancelling.Events.RequestCancel,
  })
end

function AuctionHouseHelperSearchDataProviderMixin:ReceiveEvent(eventName, itemKey, originalItemKey, originalItemLink)
  if eventName == AuctionHouseHelper.Selling.Events.SellSearchStart then
    self:Reset()
    self.onSearchStarted()
    -- Used to prevent a sale causing the view to sometimes change to another item
    self.expectedItemKey = itemKey
    self.originalItemKey = originalItemKey
    self.originalItemLink = originalItemLink
  elseif eventName == AuctionHouseHelper.Selling.Events.BagItemClicked then
    self.onResetScroll()
  elseif eventName == AuctionHouseHelper.Cancelling.Events.RequestCancel then
    self:RegisterEvent("AUCTION_CANCELED")
  end
end

function AuctionHouseHelperSearchDataProviderMixin:GetTableLayout()
  return SEARCH_PROVIDER_LAYOUT
end

function AuctionHouseHelperSearchDataProviderMixin:GetColumnHideStates()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.COLUMNS_SELLING_SEARCH)
end

local COMPARATORS = {
  price = AuctionHouseHelper.Utilities.NumberComparator,
  bidPrice = AuctionHouseHelper.Utilities.NumberComparator,
  quantity = AuctionHouseHelper.Utilities.NumberComparator,
  level = AuctionHouseHelper.Utilities.NumberComparator,
  timeLeft = AuctionHouseHelper.Utilities.NumberComparator,
  owned = AuctionHouseHelper.Utilities.StringComparator,
  otherSellers = AuctionHouseHelper.Utilities.StringComparator,
}

function AuctionHouseHelperSearchDataProviderMixin:UniqueKey(entry)
  return entry.auctionID
end

function AuctionHouseHelperSearchDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionHouseHelperSearchDataProviderMixin:OnEvent(eventName, itemRef, auctionID)
  if eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" and self.expectedItemKey ~= nil and
          self.expectedItemKey.itemID == itemRef then
    self:Reset()
    self:AppendEntries(self:ProcessCommodityResults(itemRef), true)

  elseif (eventName == "ITEM_SEARCH_RESULTS_UPDATED" and self.expectedItemKey ~= nil and
          AuctionHouseHelper.Utilities.ItemKeyString(self.expectedItemKey) == AuctionHouseHelper.Utilities.ItemKeyString(itemRef)
        ) then
    self.onPreserveScroll()
    self:Reset()
    self:AppendEntries(self:ProcessItemResults(itemRef), true)

  elseif eventName == "COMMODITY_PURCHASE_SUCCEEDED" then
    self.onPreserveScroll()
    self:RefreshView()

  elseif eventName == "AUCTION_CANCELED" then
    self:UnregisterEvent("AUCTION_CANCELED")
    self.onPreserveScroll()
    self:RefreshView()
  end
end

function AuctionHouseHelperSearchDataProviderMixin:RefreshView()
  self.onPreserveScroll()
  AuctionHouseHelper.EventBus
    :RegisterSource(self, "AuctionHouseHelperSearchDataProviderMixin")
    :Fire(self, AuctionHouseHelper.Selling.Events.RefreshSearch)
    :UnregisterSource(self)
end

local function cancelShortcutEnabled()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_CANCEL_SHORTCUT) ~= AuctionHouseHelper.Config.Shortcuts.NONE
end

function AuctionHouseHelperSearchDataProviderMixin:ProcessCommodityResults(itemID)
  local entries = {}
  local anyOwnedNotLoaded = false

  for index = 1, C_AuctionHouse.GetNumCommoditySearchResults(itemID) do
    local resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, index)
    local entry = {
      price = resultInfo.unitPrice,
      bidPrice = nil,
      owners = resultInfo.owners,
      totalNumberOfOwners = resultInfo.totalNumberOfOwners,
      otherSellers = AuctionHouseHelper.Utilities.StringJoin(resultInfo.owners, PLAYER_LIST_DELIMITER),
      quantity = resultInfo.quantity,
      quantityFormatted = FormatLargeNumber(resultInfo.quantity),
      level = 0,
      levelPretty = "0",
      timeLeftPretty = AuctionHouseHelper.Utilities.FormatTimeLeft(resultInfo.timeLeftSeconds),
      timeLeft = resultInfo.timeLeftSeconds or 0, --Used in sorting
      auctionID = resultInfo.auctionID,
      itemID = itemID,
      itemType = AuctionHouseHelper.Constants.ITEM_TYPES.COMMODITY,
      canBuy = not (resultInfo.containsOwnerItem or resultInfo.containsAccountItem)
    }

    if #entry.owners > 0 and #entry.owners < entry.totalNumberOfOwners then
      entry.otherSellers = AUCTION_HOUSE_HELPER_L_SELLERS_OVERFLOW_TEXT:format(entry.otherSellers, entry.totalNumberOfOwners - #entry.owners)
    end

    if resultInfo.containsOwnerItem then
      -- Test if the auction has been loaded for cancelling
      if not C_AuctionHouse.CanCancelAuction(resultInfo.auctionID) then
        anyOwnedNotLoaded = true
      end

      entry.otherSellers = GREEN_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_SELLER_YOU)
      entry.owned = AUCTION_HOUSE_HELPER_L_UNDERCUT_YES

    else
      entry.owned = GRAY_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_HELPER_L_UNDERCUT_NO)
    end

    table.insert(entries, entry)
  end

  -- To cancel an owned auction it must have been loaded by QueryOwnedAuctions.
  -- Rather than call it unnecessarily (which wastes a request) it is only
  -- called if an auction exists that hasn't been loaded for cancelling yet.
  -- If a user really really wants to avoid an extra request they can turn the
  -- feature off.
  if anyOwnedNotLoaded and cancelShortcutEnabled() then
    AuctionHouseHelper.AH.QueryOwnedAuctions({})
  end

  return entries
end

function AuctionHouseHelperSearchDataProviderMixin:ProcessItemResults(itemKey)
  local entries = {}
  local anyOwnedNotLoaded = false

  for index = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local resultInfo = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    if AuctionHouseHelper.Selling.DoesItemMatch(self.originalItemKey, self.originalItemLink, resultInfo.itemKey, resultInfo.itemLink) then
      local entry = {
        price = resultInfo.buyoutAmount,
        bidPrice = resultInfo.bidAmount,
        level = resultInfo.itemKey.itemLevel or 0,
        levelPretty = "",
        owners = resultInfo.owners,
        totalNumberOfOwners = resultInfo.totalNumberOfOwners,
        otherSellers = AuctionHouseHelper.Utilities.StringJoin(resultInfo.owners, PLAYER_LIST_DELIMITER),
        timeLeftPretty = AuctionHouseHelper.Utilities.FormatTimeLeftBand(resultInfo.timeLeft),
        timeLeft = resultInfo.timeLeft, --Used in sorting and the vanilla AH tooltip code
        quantity = resultInfo.quantity,
        quantityFormatted = FormatLargeNumber(resultInfo.quantity),
        itemLink = resultInfo.itemLink,
        auctionID = resultInfo.auctionID,
        itemType = AuctionHouseHelper.Constants.ITEM_TYPES.ITEM,
        canBuy = resultInfo.buyoutAmount ~= nil and not (resultInfo.containsOwnerItem or resultInfo.containsAccountItem)
      }

      if #entry.owners > 0 and #entry.owners < entry.totalNumberOfOwners then
        entry.otherSellers = AUCTION_HOUSE_HELPER_L_SELLERS_OVERFLOW_TEXT:format(entry.otherSellers, entry.totalNumberOfOwners - #entry.owners)
      end

      if resultInfo.itemKey.battlePetSpeciesID ~= 0 and entry.itemLink ~= nil then
        entry.level = AuctionHouseHelper.Utilities.GetPetLevelFromLink(entry.itemLink)
        entry.levelPretty = tostring(entry.level)
      end

      local qualityColor = AuctionHouseHelper.Utilities.GetQualityColorFromLink(entry.itemLink)
      entry.levelPretty = "|c" .. qualityColor .. entry.level .. "|r"

      if resultInfo.containsOwnerItem then
        -- Test if the auction has been loaded for cancelling
        if not C_AuctionHouse.CanCancelAuction(resultInfo.auctionID) then
          anyOwnedNotLoaded = true
        end

        entry.otherSellers = GREEN_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_SELLER_YOU)
        entry.owned = AUCTION_HOUSE_HELPER_L_UNDERCUT_YES

      else
        entry.owned = GRAY_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_HELPER_L_UNDERCUT_NO)
      end

      table.insert(entries, entry)
    end
  end

  -- See comment in ProcessCommodityResults
  if anyOwnedNotLoaded and cancelShortcutEnabled() then
    AuctionHouseHelper.AH.QueryOwnedAuctions({})
  end

  return entries
end

function AuctionHouseHelperSearchDataProviderMixin:GetRowTemplate()
  return "AuctionHouseHelperSellSearchRowTemplate"
end
