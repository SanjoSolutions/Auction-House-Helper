AuctionHouseHelperCraftingInfoObjectiveTrackerFrameMixin = {}

function AuctionHouseHelperCraftingInfoObjectiveTrackerFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
    "PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
    "TRACKED_RECIPE_UPDATE",
  })
  self:UpdateSearchButton()

  local function Update()
    self:ShowIfRelevant()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end
end

function AuctionHouseHelperCraftingInfoObjectiveTrackerFrameMixin:SetDoNotShowProfit()
  self.doNotShowProfit = true
end

function AuctionHouseHelperCraftingInfoObjectiveTrackerFrameMixin:ShowIfRelevant()
  self:SetShown(AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.CRAFTING_INFO_SHOW) and self:IsAnythingTracked())
  if self:IsShown() then
    self:UpdateSearchButton()
  end
end

function AuctionHouseHelperCraftingInfoObjectiveTrackerFrameMixin:UpdateSearchButton()
  self.SearchButton:SetShown(AuctionHouseFrame and AuctionHouseFrame:IsShown())
end

function AuctionHouseHelperCraftingInfoObjectiveTrackerFrameMixin:IsAnythingTracked()
  return #C_TradeSkillUI.GetRecipesTracked(true) > 0 or #C_TradeSkillUI.GetRecipesTracked(false) > 0 
end

function AuctionHouseHelperCraftingInfoObjectiveTrackerFrameMixin:SearchButtonClicked()
  AuctionHouseHelper.CraftingInfo.DoTrackedRecipesSearch()
end

function AuctionHouseHelperCraftingInfoObjectiveTrackerFrameMixin:OnEvent(eventName, eventData)
  if eventName == "TRACKED_RECIPE_UPDATE" then
    self:ShowIfRelevant()
  elseif eventData == Enum.PlayerInteractionType.Auctioneer then
    self:UpdateSearchButton()
  end
end
