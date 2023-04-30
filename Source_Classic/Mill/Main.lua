AuctionHouseHelper.Mill = {}

function AuctionHouseHelper.Mill.IsMillable(itemID)
  return AuctionHouseHelper.Mill.MILL_TABLE[tostring(itemID)] ~= nil
end

local function GetMillResults(itemID)
  return AuctionHouseHelper.Mill.MILL_TABLE[tostring(itemID)]
end

function AuctionHouseHelper.Mill.GetMillAuctionPrice(itemID)
  local millResults = GetMillResults(itemID)

  if millResults == nil then
    return nil
  end

  local price = 0

  for reagentKey, allDrops in pairs(millResults) do
    local reagentPrice = AuctionHouseHelper.Database:GetPrice(reagentKey)

    if reagentPrice == nil then
      return nil
    end

    for index, drop in ipairs(allDrops) do
      price = price + reagentPrice * index * drop
    end
  end

  return price / 5
end
