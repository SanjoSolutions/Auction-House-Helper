AuctionHouseHelperBagItemContainerMixin = {}

function AuctionHouseHelperBagItemContainerMixin:OnLoad()
  self.iconSize = AuctionHouseHelper.Config.Get(AuctionHouseHelper.Config.Options.SELLING_ICON_SIZE)

  self.buttons = {}
  self.buttonPool = CreateFramePool("Button", self, "AuctionHouseHelperBagItem", FramePool_HideAndClearAnchors, false, function(button)
    button:SetSize(self.iconSize, self.iconSize)
  end)
end

function AuctionHouseHelperBagItemContainerMixin:Reset()
  self.buttons = {}

  self.buttonPool:ReleaseAll()
end

function AuctionHouseHelperBagItemContainerMixin:GetRowLength()
  return math.floor(250/self.iconSize)
end

function AuctionHouseHelperBagItemContainerMixin:GetRowWidth()
  return self:GetRowLength() * self.iconSize
end

function AuctionHouseHelperBagItemContainerMixin:AddItems(itemList)
  for _, item in ipairs(itemList) do
    self:AddItem(item)
  end

  self:DrawButtons()
end

function AuctionHouseHelperBagItemContainerMixin:AddItem(item)
  local button = self.buttonPool:Acquire()

  button:Show()

  button:SetItemInfo(item)

  table.insert(self.buttons, button)
end

function AuctionHouseHelperBagItemContainerMixin:DrawButtons()
  local rows = 1

  for index, button in ipairs(self.buttons) do
    if index == 1 then
      button:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -2)
    elseif ((index - 1) % self:GetRowLength()) == 0 then
      rows = rows + 1
      button:SetPoint("TOPLEFT", self.buttons[index - self:GetRowLength()], "BOTTOMLEFT")
    else
      button:SetPoint("TOPLEFT", self.buttons[index - 1], "TOPRIGHT")
    end
  end

  if #self.buttons > 0 then
    self:SetSize(self.buttons[1]:GetWidth() * 3, rows * self.iconSize + 2)
  else
    self:SetSize(0, 0)
  end

  self:SetSize(self.iconSize * self:GetRowLength(), self:GetHeight())
end

function AuctionHouseHelperBagItemContainerMixin:GetNumItems()
  return #self.buttons
end
