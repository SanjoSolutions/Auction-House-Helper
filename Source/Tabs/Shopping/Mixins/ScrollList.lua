AuctionHouseHelperScrollListMixin = {}

function AuctionHouseHelperScrollListMixin:GetNumEntries()
  error("Need to override")
end

function AuctionHouseHelperScrollListMixin:GetEntry(index)
  error("Need to override")
end

function AuctionHouseHelperScrollListMixin:InitLine(line)
  line:InitLine()
end

function AuctionHouseHelperScrollListMixin:OnShow()
  self:Init()
  self:RefreshScrollFrame(true)
end

function AuctionHouseHelperScrollListMixin:Init()
  if self.isInitialized then
    return
  end

  self.isInitialized = true

  local view = CreateScrollBoxListLinearView()

  view:SetPadding(2, 2, 2, 2, 0);
  view:SetPanExtent(50)

  ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

  local function FirstTimeInit(frame)
    if frame.created == nil then
      self:InitLine(frame)
      frame.created = true
    end
  end
  view:SetElementExtent(20)
  if AuctionHouseHelper.Constants.IsVanilla then
    view:SetElementInitializer("Button", self.lineTemplate, function(frame, elementData)
      FirstTimeInit(frame)
      frame:Populate(elementData.searchTerm, elementData.index)
    end)
  else
    view:SetElementInitializer(self.lineTemplate, function(frame, elementData)
      FirstTimeInit(frame)
      frame:Populate(elementData.searchTerm, elementData.index)
    end)
  end
end

function AuctionHouseHelperScrollListMixin:RefreshScrollFrame(persistScroll)
  AuctionHouseHelper.Debug.Message("AuctionHouseHelperScrollListMixin:RefreshScrollFrame()")

  if not self.isInitialized or not self:IsVisible() then
    return
  end

  local entries = {}
  for i = 1, self:GetNumEntries() do
    table.insert(entries, {
      searchTerm = self:GetEntry(i),
      index = i,
    })
  end

  self.ScrollBox:SetDataProvider(CreateDataProvider(entries), persistScroll)
end

function AuctionHouseHelperScrollListMixin:ScrollToBottom()
  self.ScrollBox:SetScrollPercentage(1)
end

function AuctionHouseHelperScrollListMixin:SetLineTemplate(lineTemplate)
  self.lineTemplate = lineTemplate;
end
