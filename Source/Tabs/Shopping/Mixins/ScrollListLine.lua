AuctionHouseHelperScrollListLineMixin = {}

function AuctionHouseHelperScrollListLineMixin:DeleteItem()
end

function AuctionHouseHelperScrollListLineMixin:Populate(searchTerm, dataIndex)
  self.LastSearchedHighlight:Hide()
  self.searchTerm = searchTerm
  self.dataIndex = dataIndex
  self.Text:SetText(AuctionHouseHelper.Search.PrettifySearchString(self.searchTerm))
end

local function ComposeTooltip(searchTerm)
  local tooltipDetails = AuctionHouseHelper.Search.ComposeTooltip(searchTerm)

  GameTooltip:SetText(tooltipDetails.title, 1, 1, 1, 1)

  for _, line in ipairs(tooltipDetails.lines) do
    if line[2] == AUCTION_HOUSE_HELPER_L_ANY_LOWER then
      -- Faded line when no filter set
      GameTooltip:AddDoubleLine(line[1], line[2], 0.4, 0.4, 0.4, 0.4, 0.4, 0.4)

    else
      GameTooltip:AddDoubleLine(
        line[1],
        WHITE_FONT_COLOR:WrapTextInColorCode(line[2])
      )
    end
  end
end

function AuctionHouseHelperScrollListLineMixin:ShowTooltip()
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  ComposeTooltip(self.searchTerm)
  GameTooltip:Show()
end

function AuctionHouseHelperScrollListLineMixin:HideTooltip()
  GameTooltip:Hide()
end

function AuctionHouseHelperScrollListLineMixin:OnClick()

end

function AuctionHouseHelperScrollListLineMixin:OnEnter()
  -- Have to override since we arent building rows (see TableBuilder.lua)

  -- Our stuff
  self:ShowTooltip()
end

function AuctionHouseHelperScrollListLineMixin:OnLeave()
  -- Have to override since we arent building rows (see TableBuilder.lua)

  -- Our stuff
  self:HideTooltip()
end

function AuctionHouseHelperScrollListLineMixin:OnSelected()
  error("Need to override")
end
