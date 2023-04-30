function AuctionHouseHelper.Search.GetCleanItemLink(itemLink)
  local _, pre, hyperlink, post = ExtractHyperlinkString(itemLink)

  local parts = { strsplit(":", hyperlink) }

  for index = 3, 7 do
    parts[index] = ""
  end

  local wantedBits = AuctionHouseHelper.Utilities.Slice(parts, 1, 8)

  return AuctionHouseHelper.Utilities.StringJoin(wantedBits, ":")
end
