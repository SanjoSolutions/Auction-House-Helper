local function userPrefersPercentage()
  return
    AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.AUCTION_SALES_PREFERENCE) ==
    AuctionHouseHelper.Config.SalesTypes.PERCENTAGE
end

local function getPercentage()
  return (100 - AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.UNDERCUT_PERCENTAGE)) / 100
end

local function getSetAmount()
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.UNDERCUT_STATIC_VALUE)
end


function AuctionHouseHelper.Selling.CalculateItemPriceFromPrice(basePrice)
  AuctionHouseHelper.Debug.Message(" AuctionHouseHelperItemSellingMixin:CalculateItemPriceFromResult")
  local value

  if userPrefersPercentage() then
    value = basePrice * getPercentage()

    AuctionHouseHelper.Debug.Message("Percentage calculation", basePrice, getPercentage(), value)
  else
    value = basePrice - getSetAmount()

    AuctionHouseHelper.Debug.Message("Static value calculation", basePrice, getSetAmount(), value)
  end

  --Ensure the value is at least 1s
  if value < 100 then
    value = 100
  end

  return value
end
