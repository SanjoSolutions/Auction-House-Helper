AuctionHouseHelperCustomiseColumnsDropDownMixin = {}

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function AuctionHouseHelperCustomiseColumnsDropDownMixin:OnLoad()
  LibDD:Create_UIDropDownMenu(self)
  LibDD:UIDropDownMenu_SetInitializeFunction(self, AuctionHouseHelperCustomiseColumnsDropDownMixin.Initialize)
  LibDD:UIDropDownMenu_SetDisplayMode(self, "MENU")
end

function AuctionHouseHelperCustomiseColumnsDropDownMixin:Callback(columns, hideStates, applyChanges)
  self.columns = columns
  self.hideStates = hideStates
  self.applyChanges = applyChanges

  self:Toggle()
end

function AuctionHouseHelperCustomiseColumnsDropDownMixin:MoreThanOneVisible()
  local count = 0
  for _, column in ipairs(self.columns) do
    if not self.hideStates[column.headerText] then
      count = count + 1
    end
  end

  return count >= 2
end

function AuctionHouseHelperCustomiseColumnsDropDownMixin:Initialize()
  if not self.columns then
    LibDD:HideDropDownMenu(1)
    return
  end

  for _, column in ipairs(self.columns) do
    local info = LibDD:UIDropDownMenu_CreateInfo()
    info.text = column.headerText
    info.isNotRadio = true
    info.checked = not self.hideStates[column.headerText]
    info.disabled = false
    info.func = (function(column)
      return function()
        self.hideStates[column.headerText] = self:MoreThanOneVisible() and not self.hideStates[column.headerText]
        self.applyChanges()
      end
      end)(column)
    LibDD:UIDropDownMenu_AddButton(info)
  end
end

function AuctionHouseHelperCustomiseColumnsDropDownMixin:Toggle()
  LibDD:ToggleDropDownMenu(1, nil, self, "cursor", 0, 0)
end
