function AuctionHouseHelper.Utilities.GetQualityColorFromLink(itemLink)
  return string.match(itemLink, "|c(........)|")
end
