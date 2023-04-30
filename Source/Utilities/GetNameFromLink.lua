function AuctionHouseHelper.Utilities.GetNameFromLink(itemLink)
  return string.match(itemLink, "h%[(.*)%]|h")
end
