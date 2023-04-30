local MAPPING = {
  itemLevel = AuctionHouseHelper.Search.Filters.ItemLevelMixin,
  exactSearch = AuctionHouseHelper.Search.Filters.ExactMixin,
  craftedLevel = AuctionHouseHelper.Search.Filters.CraftedLevelMixin,
  price = AuctionHouseHelper.Search.Filters.PriceMixin,
  tier = AuctionHouseHelper.Search.Filters.TierMixin,
  expansion = AuctionHouseHelper.Search.Filters.ExpansionMixin,
}

function AuctionHouseHelper.Search.Filters.Create(browseResult, allFilters, filterTracker)
  local result = {}
  local key, filter
  for key, filter in pairs(allFilters) do
    if MAPPING[key] ~= nil then
      table.insert(result, CreateAndInitFromMixin(MAPPING[key], filterTracker, browseResult, filter))
    end
  end
  if #result == 0 then
    table.insert(result, CreateAndInitFromMixin(
        AuctionHouseHelper.Search.Filters.BlankFilterMixin,
        filterTracker,
        browseResult
      )
    )
  end
  return result
end
