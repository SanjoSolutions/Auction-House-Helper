-- Group items by database key for use with Auctiontator.Database:ProcessScan
function AuctionHouseHelper.Search.GroupResultsForDB(results)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelper.Search.GroupResults", #results)

  local waiting = #results
  local doneComplete = false
  local groups = {}

  local function OnComplete()
    doneComplete = true
    AuctionHouseHelper.Database:ProcessScan(groups)
    AuctionHouseHelper.EventBus
      :RegisterSource(AuctionHouseHelper.Search.GroupResultsForDB, "Classic GroupResultsForDB")
      :Fire(AuctionHouseHelper.Search.GroupResultsForDB, AuctionHouseHelper.Search.Events.PricesProcessed)
      :UnregisterSource(AuctionHouseHelper.Search.GroupResultsForDB)
  end

  for _, entry in ipairs(results) do
    if entry.info[3] ~= 0 and entry.info[10] ~= 0 then
      AuctionHouseHelper.Utilities.DBKeyFromLink(entry.itemLink, function(keys)
        local unitPrice = math.ceil(entry.info[10] / entry.info[3])
        waiting = waiting - 1
        for _, key in ipairs(keys) do
          if groups[key] == nil then
            groups[key] = {}
          end
          table.insert(groups[key], {
            price = unitPrice,
            available = entry.info[3],
          })
        end
        if waiting == 0 then
          OnComplete()
        end
      end)
    else
      waiting = waiting - 1
    end
  end

  if waiting == 0 and not doneComplete then
    OnComplete()
  end
end
