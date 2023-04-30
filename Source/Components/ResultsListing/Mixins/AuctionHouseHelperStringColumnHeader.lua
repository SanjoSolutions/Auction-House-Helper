AuctionHouseHelperStringColumnHeaderTemplateMixin = CreateFromMixins(AuctionHouseHelperRetailImportTableBuilderElementMixin)

function AuctionHouseHelperStringColumnHeaderTemplateMixin:Init(name, customiseFunction, sortFunction, clearSortFunction, sortKey, tooltipText)
  self.tooltipText = tooltipText
  self.sortKey = sortKey
  self.customiseFunction = customiseFunction
  self.clearSortFunction = clearSortFunction
  self.sortFunction = sortFunction
  self.sortDirection = nil

  self:SetText(name)
end

function AuctionHouseHelperStringColumnHeaderTemplateMixin:DoSort()
  if self.sortKey then
    if self.sortDirection == AuctionHouseHelper.Constants.SORT.DESCENDING or self.sortDirection == nil then
      self.sortDirection = AuctionHouseHelper.Constants.SORT.ASCENDING
    else
      self.sortDirection = AuctionHouseHelper.Constants.SORT.DESCENDING
    end

    self.sortFunction(self.sortKey, self.sortDirection)

    if self.sortDirection == AuctionHouseHelper.Constants.SORT.DESCENDING then
      self.Arrow:SetTexCoord(0, 1, 1, 0)
    else
      self.Arrow:SetTexCoord(0, 1, 0, 1)
    end

    self.Arrow:Show()
  end

  PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

-- Implementing mouse events for sorting
function AuctionHouseHelperStringColumnHeaderTemplateMixin:OnClick(button, ...)
  if button == "LeftButton" then
    if IsShiftKeyDown() then
      self.clearSortFunction()
    else
      self:DoSort()
    end
  end
end

function AuctionHouseHelperStringColumnHeaderTemplateMixin:OnMouseUp(button, ...)
  -- Registered to the mouse handler so that the dropdown still shows even when
  -- the headers are disabled
  if button == "RightButton" then
    self.customiseFunction()
  end
end

-- Implementing mouse events for tooltip
function AuctionHouseHelperStringColumnHeaderTemplateMixin:OnEnter()
  if self.tooltipText then
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip_AddColoredLine(GameTooltip, self.tooltipText, WHITE_FONT_COLOR, true)
    GameTooltip:Show()
  end
end

function AuctionHouseHelperStringColumnHeaderTemplateMixin:OnLeave()
  GameTooltip:Hide()
end
