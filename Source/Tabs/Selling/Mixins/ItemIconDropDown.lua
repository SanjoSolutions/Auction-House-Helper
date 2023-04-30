AuctionHouseHelperItemIconDropDownMixin = {}

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local function HideItem(info)
  table.insert(
    AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS),
    AuctionHouseHelper.Selling.UniqueBagKey(info)
  )

  AuctionHouseHelper.EventBus
    :RegisterSource(HideItem, "HideItem")
    :Fire(HideItem, AuctionHouseHelper.Selling.Events.BagRefresh)
    :UnregisterSource(HideItem)
end

local function UnhideItem(info)
  local ignored = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS)
  local index = tIndexOf(ignored, AuctionHouseHelper.Selling.UniqueBagKey(info))

  if index ~= nil then
    table.remove(ignored, index)
  end

  AuctionHouseHelper.EventBus
    :RegisterSource(UnhideItem, "UnhideItem")
    :Fire(UnhideItem, AuctionHouseHelper.Selling.Events.BagRefresh)
    :UnregisterSource(UnhideItem)
end

local function IsHidden(info)
  return tIndexOf(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS), AuctionHouseHelper.Selling.UniqueBagKey(info)) ~= nil
end
local function ToggleHidden(info)
  if IsHidden(info) then
    UnhideItem(info)
  else
    HideItem(info)
  end
end

function AuctionHouseHelper.Selling.GetAllFavourites()
  local favourites = {}
  for _, fav in pairs(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_FAVOURITE_KEYS)) do
    table.insert(favourites, fav)
  end

  return favourites
end

function AuctionHouseHelper.Selling.IsFavourite(data)
  return AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_FAVOURITE_KEYS)[AuctionHouseHelper.Selling.UniqueBagKey(data)] ~= nil
end

local function ToggleFavouriteItem(data)
  if AuctionHouseHelper.Selling.IsFavourite(data) then
    AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_FAVOURITE_KEYS)[AuctionHouseHelper.Selling.UniqueBagKey(data)] = nil
  else
    AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_FAVOURITE_KEYS)[AuctionHouseHelper.Selling.UniqueBagKey(data)] = {
      itemKey = data.itemKey,
      itemLink = data.itemLink,
      count = 0,
      iconTexture = data.iconTexture,
      itemType = data.itemType,
      location = nil,
      quality = data.quality,
      classId = data.classId,
      auctionable = data.auctionable,
    }
  end

  AuctionHouseHelper.EventBus
    :RegisterSource(ToggleFavouriteItem, "ToggleFavouriteItem")
    :Fire(ToggleFavouriteItem, AuctionHouseHelper.Selling.Events.BagRefresh)
    :UnregisterSource(ToggleFavouriteItem)
end

local function UnhideAllItemKeys()
  AuctionHouseHelper.Config.Set(AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS, {})

  AuctionHouseHelper.EventBus
    :RegisterSource(UnhideAllItemKeys, "UnhideAllItemKeys")
    :Fire(UnhideAllItemKeys, AuctionHouseHelper.Selling.Events.BagRefresh)
    :UnregisterSource(UnhideAllItemKeys)
end

local function NoItemKeysHidden()
  return #AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_IGNORED_KEYS) == 0
end

function AuctionHouseHelperItemIconDropDownMixin:OnLoad()
  LibDD:Create_UIDropDownMenu(self)

  LibDD:UIDropDownMenu_SetInitializeFunction(self, AuctionHouseHelperItemIconDropDownMixin.Initialize)
  LibDD:UIDropDownMenu_SetDisplayMode(self, "MENU")
  AuctionHouseHelper.EventBus:Register(self, {
    AuctionHouseHelper.Selling.Events.ItemIconCallback,
  })
end

function AuctionHouseHelperItemIconDropDownMixin:ReceiveEvent(event, ...)
  if event == AuctionHouseHelper.Selling.Events.ItemIconCallback then
    self:Callback(...)
  end
end

function AuctionHouseHelperItemIconDropDownMixin:Initialize()
  if not self.data then
    LibDD:HideDropDownMenu(1)
    return
  end

  local hideInfo = LibDD:UIDropDownMenu_CreateInfo()
  hideInfo.notCheckable = 1
  if IsHidden(self.data) then
    hideInfo.text = AUCTION_HOUSE_HELPER_L_UNHIDE
  else
    hideInfo.text = AUCTION_HOUSE_HELPER_L_HIDE
  end

  hideInfo.disabled = false
  hideInfo.func = function()
    ToggleHidden(self.data)
  end

  LibDD:UIDropDownMenu_AddButton(hideInfo)

  local unhideAllAllInfo = LibDD:UIDropDownMenu_CreateInfo()
  unhideAllAllInfo.notCheckable = 1
  unhideAllAllInfo.text = AUCTION_HOUSE_HELPER_L_UNHIDE_ALL

  unhideAllAllInfo.disabled = NoItemKeysHidden()
  unhideAllAllInfo.func = function()
    StaticPopup_Show(AuctionHouseHelper.Constants.DialogNames.SellingConfirmUnhideAll)
  end

  LibDD:UIDropDownMenu_AddButton(unhideAllAllInfo)

  local favouriteItemInfo = LibDD:UIDropDownMenu_CreateInfo()
  favouriteItemInfo.notCheckable = 1
  if AuctionHouseHelper.Selling.IsFavourite(self.data) then
    favouriteItemInfo.text = AUCTION_HOUSE_HELPER_L_REMOVE_FAVOURITE
  else
    favouriteItemInfo.text = AUCTION_HOUSE_HELPER_L_ADD_FAVOURITE
  end

  favouriteItemInfo.disabled = false
  favouriteItemInfo.func = function()
    ToggleFavouriteItem(self.data)
  end

  LibDD:UIDropDownMenu_AddButton(favouriteItemInfo)
end

function AuctionHouseHelperItemIconDropDownMixin:Callback(itemInfo)
  self.data = itemInfo
  self:Toggle()
end

function AuctionHouseHelperItemIconDropDownMixin:Toggle()
  LibDD:ToggleDropDownMenu(1, nil, self, "cursor", 0, 0)
end
