function AuctionHouseHelper.Utilities.PrettyDate(when)
  local details = date("*t", when)
  local currentDay = date("*t", time())

  local weekDay = AuctionHouseHelper.Locales.Apply("DAY_"..tostring(details.wday))

  if details.year == currentDay.year and details.month == currentDay.month and details.day == currentDay.day then
    return AUCTION_HOUSE_HELPER_L_TODAY

  elseif GetLocale() == "koKR" then
    -- Korean date format
    -- Prints, for 25th February 2020, "2020.02.25 [Tuesday]"
    return date("%Y.%m.%d", when) .. " [" .. weekDay .. "]"

  else
    -- Default (English) date format
    -- Prints, for 25th February 2020, "Tuesday, February 25"
    return
      weekDay ..  ", " ..
      AuctionHouseHelper.Locales.Apply("MONTH_"..tostring(details.month)) ..
      " " .. details.day
    end
end
