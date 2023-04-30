AuctionHouseHelperRetailImportTemplatedListElementMixin = {};

function AuctionHouseHelperRetailImportTemplatedListElementMixin:InitElement(...)
	-- Override in your mixin.
end

function AuctionHouseHelperRetailImportTemplatedListElementMixin:UpdateDisplay()
	-- Override in your mixin.
	assert("Your templated list element must define a display method");
end

function AuctionHouseHelperRetailImportTemplatedListElementMixin:OnSelected()
	-- Override in your mixin.
end

function AuctionHouseHelperRetailImportTemplatedListElementMixin:OnEnter()
	-- Override in your mixin.
end

function AuctionHouseHelperRetailImportTemplatedListElementMixin:OnLeave()
	-- Override in your mixin.
end

function AuctionHouseHelperRetailImportTemplatedListElementMixin:Populate(listIndex)
	self.listIndex = listIndex;
	self:UpdateDisplay();
end

function AuctionHouseHelperRetailImportTemplatedListElementMixin:OnClick()
	self:GetList():SetSelectedListIndex(self.listIndex);
	self:OnSelected();
end

function AuctionHouseHelperRetailImportTemplatedListElementMixin:IsSelected()
	return self:GetListIndex() == self:GetList():GetSelectedListIndex();
end

function AuctionHouseHelperRetailImportTemplatedListElementMixin:GetListIndex()
	return self.listIndex;
end

function AuctionHouseHelperRetailImportTemplatedListElementMixin:GetList()
	return self:GetParent();
end


AuctionHouseHelperRetailImportTemplatedListMixin = {};

function AuctionHouseHelperRetailImportTemplatedListMixin:SetElementTemplate(elementTemplate, ...)
	if self.elementTemplate ~= nil then
		assert("You cannot change the element template once it is set, as the necessary frames may have already been created from the old template.");
		return;
	end

	self.elementTemplate = elementTemplate;
	self.elementTemplateInitArgs = SafePack(...);
end

function AuctionHouseHelperRetailImportTemplatedListMixin:SetGetNumResultsFunction(getNumResultsFunction)
	self.getNumResultsFunction = getNumResultsFunction;
	self:ResetList();
end

function AuctionHouseHelperRetailImportTemplatedListMixin:SetSelectionCallback(selectionCallback)
	self.selectionCallback = selectionCallback;
end

function AuctionHouseHelperRetailImportTemplatedListMixin:SetRefreshCallback(refreshCallback)
	self.refreshCallback = refreshCallback;
end

function AuctionHouseHelperRetailImportTemplatedListMixin:GetSelectedHighlight()
	return self.ArtOverlay.SelectedHighlight;
end

function AuctionHouseHelperRetailImportTemplatedListMixin:OnShow()
	self:CheckListInitialization();
	self:RefreshListDisplay();
end

function AuctionHouseHelperRetailImportTemplatedListMixin:IsInitialized()
	return self.isInitialized;
end

function AuctionHouseHelperRetailImportTemplatedListMixin:CheckListInitialization()
	if self.isInitialized or (self:GetElementTemplate() == nil) or not self:CanInitialize() then
		return;
	end

	self:InitializeList();
	self:InitializeElements();
	
	self.isInitialized = true;
end

function AuctionHouseHelperRetailImportTemplatedListMixin:GetElementTemplate()
	return self.elementTemplate;
end

function AuctionHouseHelperRetailImportTemplatedListMixin:GetElementInitializationArgs()
	return SafeUnpack(self.elementTemplateInitArgs);
end

function AuctionHouseHelperRetailImportTemplatedListMixin:InitializeElements()
	-- We use a local sub-function to capture the variadic parameters and avoid unpacking multiple times.
	local function InitializeAllElementFrames(...)
		for i = 1, self:GetNumElementFrames() do
			self:GetElementFrame(i):InitElement(...);
		end
	end

	InitializeAllElementFrames(self:GetElementInitializationArgs());
end

function AuctionHouseHelperRetailImportTemplatedListMixin:UpdatedSelectedHighlight()
	local selectedHighlight = self:GetSelectedHighlight();
	selectedHighlight:ClearAllPoints();
	selectedHighlight:Hide();

	local selectedListIndex = self:GetSelectedListIndex();
	if self.isInitialized and selectedListIndex ~= nil then
		local elementOffset = selectedListIndex - self:GetListOffset();
		if elementOffset >= 1 and elementOffset <= self:GetNumElementFrames() then
			local elementFrame = self:GetElementFrame(elementOffset);
			self:AttachHighlightToElementFrame(selectedHighlight, elementFrame);
		end
	end
end

function AuctionHouseHelperRetailImportTemplatedListMixin:AttachHighlightToElementFrame(selectedHighlight, elementFrame)
	local elementFrame = self:GetElementFrame(elementOffset);
	selectedHighlight:SetPoint("CENTER", elementFrame, "CENTER", 0, 0);
	selectedHighlight:Show();
end

function AuctionHouseHelperRetailImportTemplatedListMixin:SetSelectedListIndex(listIndex, skipUpdates)
	local sameIndex = selectedListIndex == listIndex;
	self.selectedListIndex = listIndex;

	if not skipUpdates then
		if self.selectionCallback then
			self.selectionCallback(listIndex);
		end
	end

	if sameIndex or skipUpdates then
		return;
	end

	self:RefreshListDisplay();
end

function AuctionHouseHelperRetailImportTemplatedListMixin:GetSelectedListIndex()
	return self.selectedListIndex;
end

function AuctionHouseHelperRetailImportTemplatedListMixin:ResetList()
	if self.isInitialized then
		self:ResetDisplay();
	end
end

function AuctionHouseHelperRetailImportTemplatedListMixin:CanDisplay()
	if self.elementTemplate == nil then
		return false, "Templated list elementTemplate not set. Use AuctionHouseHelperRetailImportTemplatedListMixin:SetElementTemplate.";
	end

	if self.getNumResultsFunction == nil then
		return false, "Templated list getNumResultsFunction not set. Use AuctionHouseHelperRetailImportTemplatedListMixin:SetGetNumResultsFunction.";
	end

	if not self.isInitialized then
		return false, "Templated list has not been initialized. This should generally happen in OnShow.";
	end

	return true, nil;
end

function AuctionHouseHelperRetailImportTemplatedListMixin:RefreshListDisplay()
	if not self:IsVisible() then
		return;
	end

	local canDisplay, displayError = self:CanDisplay();
	if not canDisplay then
		error(displayError);
		return;
	end

	local numResults = self.getNumResultsFunction();
	local lastDisplayedOffset = self:DisplayList(numResults);
	
	self:UpdatedSelectedHighlight();

	if self.refreshCallback ~= nil then
		self.refreshCallback(lastDisplayedOffset);
	end
end

function AuctionHouseHelperRetailImportTemplatedListMixin:DisplayList(numResults)
	local listOffset = self:GetListOffset();
	local numElementFrames = self:GetNumElementFrames();
	local lastDisplayedOffset = 0;

	for i = 1, numElementFrames do
		local listIndex = listOffset + i;
		local elementFrame = self:GetElementFrame(i);

		if listIndex <= numResults then
			elementFrame:Populate(listIndex);
			elementFrame:Show();
			lastDisplayedOffset = i;
		else
			elementFrame:Hide();
		end
	end
	
	return lastDisplayedOffset;
end

function AuctionHouseHelperRetailImportTemplatedListMixin:EnumerateElementFrames()
	local numElementFrames = self:GetNumElementFrames();
	local elementFrameIndex = 0;
	local function ElementFrameIterator()
		elementFrameIndex = elementFrameIndex + 1;

		if elementFrameIndex > numElementFrames then
			return nil;
		end

		return self:GetElementFrame(elementFrameIndex);
	end

	return ElementFrameIterator;
end

function AuctionHouseHelperRetailImportTemplatedListMixin:CanInitialize()
	return true; -- May be implemented by derived mixins.
end

function AuctionHouseHelperRetailImportTemplatedListMixin:InitializeList()
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function AuctionHouseHelperRetailImportTemplatedListMixin:GetNumElementFrames()
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function AuctionHouseHelperRetailImportTemplatedListMixin:GetElementFrame(frameIndex)
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function AuctionHouseHelperRetailImportTemplatedListMixin:GetListOffset()
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function AuctionHouseHelperRetailImportTemplatedListMixin:ResetDisplay()
	-- Implemented by derived mixins.
end
