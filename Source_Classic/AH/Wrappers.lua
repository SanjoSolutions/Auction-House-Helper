-- query = {
--   searchString -> string
--   minLevel -> int?
--   maxLevel -> int?
--   itemClassFilters -> itemClassFilter[]
--   isExact -> boolean?
-- }
function AuctionHouseHelper.AH.QueryAuctionItems(query)
  AuctionHouseHelper.AH.Internals.scan:StartQuery(query, 0, -1)
end

function AuctionHouseHelper.AH.QueryAndFocusPage(query, page)
  AuctionHouseHelper.AH.Internals.scan:StartQuery(query, page, page)
end

function AuctionHouseHelper.AH.GetCurrentPage()
  return AuctionHouseHelper.AH.Internals.scan:GetCurrentPage()
end

function AuctionHouseHelper.AH.AbortQuery()
  AuctionHouseHelper.AH.Internals.scan:AbortQuery()
end

-- Event ThrottleUpdate will fire whenever the state changes
function AuctionHouseHelper.AH.IsNotThrottled()
  return AuctionHouseHelper.AH.Internals.throttling:IsReady()
end

function AuctionHouseHelper.AH.GetAuctionItemSubClasses(classID)
  return { GetAuctionItemSubClasses(classID) }
end

function AuctionHouseHelper.AH.PlaceAuctionBid(...)
  AuctionHouseHelper.AH.Internals.throttling:BidPlaced()
  PlaceAuctionBid("list", ...)
end

function AuctionHouseHelper.AH.PostAuction(...)
  AuctionHouseHelper.AH.Internals.throttling:AuctionsPosted()
  PostAuction(...)
end

-- view is a string and must be "list", "owner" or "bidder"
function AuctionHouseHelper.AH.DumpAuctions(view)
  local auctions = {}
  for index = 1, GetNumAuctionItems(view) do
    local auctionInfo = { GetAuctionItemInfo(view, index) }
    local itemLink = GetAuctionItemLink(view, index)
    local timeLeft = GetAuctionItemTimeLeft(view, index)
    local entry = {
      info = auctionInfo,
      itemLink = itemLink,
      timeLeft = timeLeft - 1, --Offset to match Retail time parameters
      index = index,
    }
    table.insert(auctions, entry)
  end
  return auctions
end

function AuctionHouseHelper.AH.CancelAuction(auction)
  for index = 1, GetNumAuctionItems("owner") do
    local info = { GetAuctionItemInfo("owner", index) }

    local stackPrice = info[AuctionHouseHelper.Constants.AuctionItemInfo.Buyout]
    local stackSize = info[AuctionHouseHelper.Constants.AuctionItemInfo.Quantity]
    local bidAmount = info[AuctionHouseHelper.Constants.AuctionItemInfo.BidAmount]
    local saleStatus = info[AuctionHouseHelper.Constants.AuctionItemInfo.SaleStatus]
    local itemLink = GetAuctionItemLink("owner", index)

    if saleStatus ~= 1 and auction.bidAmount == bidAmount and auction.stackPrice == stackPrice and auction.stackSize == stackSize and AuctionHouseHelper.Search.GetCleanItemLink(itemLink) == AuctionHouseHelper.Search.GetCleanItemLink(auction.itemLink) then
      AuctionHouseHelper.AH.Internals.throttling:AuctionCancelled()
      CancelAuction(index)
      break
    end
  end
end
