local AUCTION_HOUSE_HELPER_EVENTS = {
  "CRAFT_SHOW",
}

AuctionHouseHelperInitializeVanillaMixin = {}

function AuctionHouseHelperInitializeVanillaMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_HELPER_EVENTS)
end

function AuctionHouseHelperInitializeVanillaMixin:OnEvent(event, ...)
  if event == "CRAFT_SHOW" then
    AuctionHouseHelper.EnchantInfo.Initialize()
    self:CraftShown()
  end
end

function AuctionHouseHelperInitializeVanillaMixin:CraftShown()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperInitializeVanillaMixin::CraftShown()")

  if self.initializedCraftHooks then
    return
  end

  local reagentHook = function(self)
    if IsModifiedClick("CHATLINK") and AuctionHouseHelperShoppingFrame ~= nil and AuctionHouseHelperShoppingFrame:IsVisible() then
      local name = GetCraftReagentInfo(GetCraftSelectionIndex(), self:GetID())

      if name == nil then
        return
      end

      AuctionHouseHelperShoppingFrame.OneItemSearchBox:SetText(name)
      AuctionHouseHelperShoppingFrame.OneItemSearchButton:Click()
    end
  end
  CraftReagent1:HookScript("OnClick", reagentHook)
  CraftReagent2:HookScript("OnClick", reagentHook)
  CraftReagent3:HookScript("OnClick", reagentHook)
  CraftReagent4:HookScript("OnClick", reagentHook)

  self.initializedCraftHooks = true
end
