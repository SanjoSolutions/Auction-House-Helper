AuctionHouseHelperConfigMinMaxMixin = {}

function AuctionHouseHelperConfigMinMaxMixin:OnLoad()
  self.onTabOut = function() end
  self.onEnter = function() end

  if self.titleText ~= nil then
    self.Title:SetText(self.titleText)
  end

  self.ResetButton:SetClickCallback(function()
    self:Reset()
  end)
end

function AuctionHouseHelperConfigMinMaxMixin:SetFocus()
  self.MinBox:SetFocus()
end

function AuctionHouseHelperConfigMinMaxMixin:SetCallbacks(callbacks)
  self.onTabOut = callbacks.OnTab or function() end
  self.onEnter = callbacks.OnEnter or function() end
end

function AuctionHouseHelperConfigMinMaxMixin:OnEnterPressed()
  self.onEnter()
end

function AuctionHouseHelperConfigMinMaxMixin:MinTabPressed()
  self.MaxBox:SetFocus()
end

function AuctionHouseHelperConfigMinMaxMixin:MaxTabPressed()
  self.onTabOut()
end

function AuctionHouseHelperConfigMinMaxMixin:GetMin()
  return self.MinBox:GetNumber()
end

function AuctionHouseHelperConfigMinMaxMixin:GetMax()
  return self.MaxBox:GetNumber()
end

function AuctionHouseHelperConfigMinMaxMixin:SetMin(value)
  if value == nil then
    self.MinBox:SetText("")
  else
    self.MinBox:SetNumber(value)
  end
end

function AuctionHouseHelperConfigMinMaxMixin:SetMax(value)
  if value == nil then
    self.MaxBox:SetText("")
  else
    self.MaxBox:SetNumber(value)
  end
end

function AuctionHouseHelperConfigMinMaxMixin:Reset()
  self.MinBox:SetText("")
  self.MaxBox:SetText("")
end
