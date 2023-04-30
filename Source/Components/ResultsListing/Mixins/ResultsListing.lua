AuctionHouseHelperResultsListingMixin = {}

function AuctionHouseHelperResultsListingMixin:Init(dataProvider)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperResultsListingMixin:Init()")

  self.isInitialized = false
  self.dataProvider = dataProvider
  self.columnSpecification = self.dataProvider:GetTableLayout()

  local view = CreateScrollBoxListLinearView()
  view:SetElementExtent(20)

  if AuctionHouseHelper.Constants.IsVanilla then
    view:SetElementInitializer("Frame", dataProvider:GetRowTemplate(), function(frame, index)
      frame:Populate(self.dataProvider:GetEntryAt(index), index)
    end)
  else
    view:SetElementInitializer(dataProvider:GetRowTemplate(), function(frame, index)
      frame:Populate(self.dataProvider:GetEntryAt(index), index)
    end)
  end

  ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollArea.ScrollBox, self.ScrollArea.ScrollBar, view)

  self.ScrollArea.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, self.ApplyHiding, self)

  -- Create an instance of table builder - note that the ScrollFrame we reference
  -- mixes a TableBuilder implementation in
  self.tableBuilder = AuctionHouseHelperRetailImportCreateTableBuilder()
  -- Set the frame that will be used for header columns for this tableBuilder
  self.tableBuilder:SetHeaderContainer(self.HeaderContainer)

  self:InitializeTable()
  self:InitializeDataProvider()
end

function AuctionHouseHelperResultsListingMixin:InitializeDataProvider()
  self.dataProvider:SetOnUpdateCallback(function()
    self:UpdateTable()
  end)

  self.dataProvider:SetOnSearchStartedCallback(function()
    self.ScrollArea.NoResultsText:Hide()
    self:EnableSpinner()
  end)

  self.dataProvider:SetOnSearchEndedCallback(function()
    self:RestoreScrollPosition()
    self:DisableSpinner()

    self.ScrollArea.NoResultsText:SetShown(self.dataProvider:GetCount() == 0)
  end)

  self.dataProvider:SetOnPreserveScrollCallback(function()
    self.savedScrollPosition = self.ScrollArea.ScrollBox:GetScrollPercentage()
  end)

  self.dataProvider:SetOnResetScrollCallback(function()
    self.savedScrollPosition = nil
  end)
end

function AuctionHouseHelperResultsListingMixin:RestoreScrollPosition()
  if self.savedScrollPosition ~= nil then
    self:UpdateTable()
    self.ScrollArea.ScrollBox:SetScrollPercentage(self.savedScrollPosition)
  end
end

function AuctionHouseHelperResultsListingMixin:OnShow()
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperResultsListingMixin:OnShow()", self.isInitialized)
  if not self.isInitialized then
    return
  end

  self:UpdateDimensionsForHiding()
  self:ApplyHiding()
  self:UpdateTable()
end

function AuctionHouseHelperResultsListingMixin:InitializeTable()
  self.tableBuilder:Reset()
  self.tableBuilder:SetTableMargins(15)
  self.tableBuilder:SetDataProvider(function(index)
    return self.dataProvider:GetEntryAt(index)
  end)

  ScrollUtil.RegisterTableBuilder(self.ScrollArea.ScrollBox, self.tableBuilder, function(a) return a end)

  for _, columnEntry in ipairs(self.columnSpecification) do
    local column = self.tableBuilder:AddColumn()
    column:ConstructHeader(
      "BUTTON",
      columnEntry.headerTemplate,
      columnEntry.headerText,
      function()
        self:CustomiseColumns()
      end,
      function(sortKey, sortDirection)
        self:ClearColumnSorts()

        self.dataProvider:SetPresetSort(sortKey, sortDirection)
        self.dataProvider:Sort(sortKey, sortDirection)
      end,
      function()
        self:ClearColumnSorts()

        self.dataProvider:ClearSort()
      end,
      unpack((columnEntry.headerParameters or {}))
    )
    column:SetCellPadding(-5, 5)
    column:ConstructCells("FRAME", columnEntry.cellTemplate, unpack((columnEntry.cellParameters or {})))

    if columnEntry.width ~= nil then
      column:SetFixedConstraints(columnEntry.width, 0)
    else
      column:SetFillConstraints(1.0, 0)
    end
  end
  self.isInitialized = true
  self:UpdateDimensionsForHiding()
  self:ApplyHiding()
end

function AuctionHouseHelperResultsListingMixin:UpdateTable()
  if not self.isInitialized then
    return
  end

  local tmpDataProvider = CreateIndexRangeDataProvider(self.dataProvider:GetCount())

  local shouldPreserveScroll = self.savedScrollPosition ~= nil

  self.ScrollArea.ScrollBox:SetDataProvider(tmpDataProvider, shouldPreserveScroll)
end

function AuctionHouseHelperResultsListingMixin:ClearColumnSorts()
  for _, col in ipairs(self.tableBuilder:GetColumns()) do
    col.headerFrame.Arrow:Hide()
  end
end

function AuctionHouseHelperResultsListingMixin:CustomiseColumns()
  if self.dataProvider:GetColumnHideStates() ~= nil then
    self.CustomiseDropDown:Callback(
      self.columnSpecification,
      self.dataProvider:GetColumnHideStates(),
      function()
        self:UpdateDimensionsForHiding()
        self:ApplyHiding()
    end)
  end
end

-- Hide cells and column header
local function SetColumnShown(column, isShown)
  column:GetHeaderFrame():SetShown(isShown)
  for _, cell in pairs(column.cells) do
    cell:SetShown(isShown)
  end
end

-- Prevent hidden columns displaying and overlapping visible ones
function AuctionHouseHelperResultsListingMixin:ApplyHiding()
  local hidingDetails = self.dataProvider:GetColumnHideStates()
  if hidingDetails == nil then
    return
  end

  for index, column in ipairs(self.tableBuilder:GetColumns()) do
    local columnEntry = self.columnSpecification[index]
    SetColumnShown(column, not hidingDetails[columnEntry.headerText])
  end
end

function AuctionHouseHelperResultsListingMixin:UpdateDimensionsForHiding()
  if not self.dataProvider:GetColumnHideStates() then
    self.tableBuilder:Arrange()
    return
  end

  local hidingDetails = self.dataProvider:GetColumnHideStates()

  local anyFlexibleWidths = false
  local visibleColumn

  for index, column in ipairs(self.tableBuilder:GetColumns()) do
    local columnEntry = self.columnSpecification[index]

    -- Import default value if hidden state not already set.
    if hidingDetails[columnEntry.headerText] == nil then
      hidingDetails[columnEntry.headerText] = columnEntry.defaultHide or false
    end

    if hidingDetails[columnEntry.headerText] then
      SetColumnShown(column, false)
      column:SetFixedConstraints(0.001, 0)
    else
      SetColumnShown(column, true)

      if columnEntry.width ~= nil then
        column:SetFixedConstraints(columnEntry.width, 0)
      else
        anyFlexibleWidths = true
        column:SetFillConstraints(1.0, 0)
      end

      if visibleColumn == nil then
        visibleColumn = column
      end
    end
  end

  -- Checking that at least one column will fill up empty space, if there isn't
  -- one, the first visible column is modified to do so.
  if not anyFlexibleWidths then
    visibleColumn:SetFillConstraints(1.0, 0)
  end

  self.tableBuilder:Arrange()
end

function AuctionHouseHelperResultsListingMixin:EnableSpinner()
  self.ScrollArea.ResultsText:Show()
  self.ScrollArea.LoadingSpinner:Show()
  self.ScrollArea.SpinnerAnim:Play()
end

function AuctionHouseHelperResultsListingMixin:DisableSpinner()
  self.ScrollArea.ResultsText:Hide()
  self.ScrollArea.LoadingSpinner:Hide()
  self.ScrollArea.SpinnerAnim:Stop()
end
