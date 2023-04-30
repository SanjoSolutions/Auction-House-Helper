AuctionHouseHelper.Constants.MaxResultsPerPage = 50
AuctionHouseHelper.Constants.ITEM_LEVEL_THRESHOLD = 0
AuctionHouseHelper.Constants.IsClassic = true

AuctionHouseHelper.Constants.AuctionItemInfo = {
  Buyout = 10,
  Quantity = 3,
  Owner = 14,
  ItemID = 17,
  Level = 6,
  MinBid = 8,
  BidAmount = 11,
  Bidder = 12,
  SaleStatus = 16,
}
AuctionHouseHelper.Constants.ValidItemClassIDs = {
  Enum.ItemClass.Weapon,
  Enum.ItemClass.Armor,
  Enum.ItemClass.Container,
  Enum.ItemClass.Consumable,
  Enum.ItemClass.Glyph,
  Enum.ItemClass.Tradegoods,
  Enum.ItemClass.Projectile,
  Enum.ItemClass.Quiver,
  Enum.ItemClass.Recipe,
  Enum.ItemClass.Gem,
  Enum.ItemClass.Miscellaneous,
  Enum.ItemClass.Questitem,
  Enum.ItemClass.Key,
}
-- Note that -2 is the keyring bag, which only exists in classic
AuctionHouseHelper.Constants.BagIDs = {-2, 0, 1, 2, 3, 4}
AuctionHouseHelper.Constants.QualityIDs = {
  Enum.ItemQuality.Poor,
  Enum.ItemQuality.Standard,
  Enum.ItemQuality.Good,
  Enum.ItemQuality.Rare,
  Enum.ItemQuality.Epic,
}

AuctionHouseHelper.Constants.PriceIncreaseWarningDuration = 5
AuctionHouseHelper.Constants.PriceIncreaseWarningThreshold = 40
