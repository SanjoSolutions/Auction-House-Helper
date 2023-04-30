local popupOwner;

function AuctionHouseHelperRetailImportMoneyInputFrame_SetEnabled(moneyFrame, enabled)
	moneyFrame.gold:SetEnabled(enabled);
	moneyFrame.silver:SetEnabled(enabled);
	moneyFrame.copper:SetEnabled(enabled);
end

function AuctionHouseHelperRetailImportMoneyInputFrame_ResetMoney(moneyFrame)
	moneyFrame.gold:SetText("");
	moneyFrame.silver:SetText("");
	moneyFrame.copper:SetText("");
end

function AuctionHouseHelperRetailImportMoneyInputFrame_ClearFocus(moneyFrame)
	moneyFrame.gold:ClearFocus();
	moneyFrame.silver:ClearFocus();
	moneyFrame.copper:ClearFocus();
end

function AuctionHouseHelperRetailImportMoneyInputFrame_SetGoldOnly(moneyFrame, set)
	if ( set ) then
		moneyFrame.goldOnly = true;
	else
		moneyFrame.goldOnly = nil;
	end
end

function AuctionHouseHelperRetailImportMoneyInputFrame_SetCopperShown(moneyFrame, shown)
	moneyFrame.copper:SetShown(shown);
	moneyFrame:SetWidth(shown and 176 or 126);
end

function AuctionHouseHelperRetailImportMoneyInputFrame_GetCopper(moneyFrame)
	local totalCopper = 0;
	local copper = moneyFrame.copper:GetText();
	local silver = moneyFrame.silver:GetText();
	local gold = moneyFrame.gold:GetText();
	
	if ( copper ~= "" ) then
		totalCopper = totalCopper + copper;
	end
	if ( silver ~= "" ) then
		totalCopper = totalCopper + (silver * COPPER_PER_SILVER);
	end
	if ( gold ~= "" ) then
		totalCopper = totalCopper + (gold * COPPER_PER_GOLD);
	end
	return totalCopper;
end

function AuctionHouseHelperRetailImportMoneyInputFrame_SetTextColor(moneyFrame, r, g, b)
	moneyFrame.copper:SetTextColor(r, g, b);
	moneyFrame.silver:SetTextColor(r, g, b);
	moneyFrame.gold:SetTextColor(r, g, b);
end

function AuctionHouseHelperRetailImportMoneyInputFrame_SetCopper(moneyFrame, money)
	local gold = floor(money / (COPPER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);
	local editbox = nil;

	moneyFrame.expectChanges = 0;
	if ( moneyFrame.goldOnly) then
		moneyFrame.copper:Hide();
		moneyFrame.silver:Hide();
	else
		editbox = moneyFrame.copper;
		if ( editbox:GetNumber() ~= copper ) then
			editbox:SetNumber(copper);
			moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
		end
		editbox = moneyFrame.silver;
		if ( editbox:GetNumber() ~= silver ) then
			editbox:SetNumber(silver);
			moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
		end
	end
	editbox = moneyFrame.gold;
	if ( editbox:GetNumber() ~= gold ) then
		editbox:SetNumber(gold);
		moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
	end
end

function AuctionHouseHelperRetailImportMoneyInputFrame_OnTextChanged(self)
	local moneyFrame = self:GetParent();
	if ( moneyFrame.expectChanges ) then
		if ( moneyFrame.expectChanges > 1 ) then
			moneyFrame.expectChanges = moneyFrame.expectChanges - 1;
			return;
		end
		moneyFrame.expectChanges = nil;
	end
	if ( self.expandOnDigits ) then
		if ( strlen(self:GetText()) >= self.expandOnDigits ) then
			moneyFrame.fixedSilver:Show();
			moneyFrame.fixedSilver.amount:SetText(moneyFrame.silver:GetNumber());
			moneyFrame.silver:Hide();
			moneyFrame.fixedCopper:Show();
			moneyFrame.fixedCopper.amount:SetText(moneyFrame.copper:GetNumber());
			moneyFrame.copper:Hide();
			moneyFrame.gold:SetWidth(self.normalWidth);
		else
			moneyFrame.gold:SetWidth(self.minWidth);
			moneyFrame.silver:Show();
			moneyFrame.fixedSilver:Hide();
			moneyFrame.copper:Show();
			moneyFrame.fixedCopper:Hide();
		end
	end
	if ( self.darkenOnDigits ) then
		if ( strlen(self:GetText()) >= self.darkenOnDigits ) then
			self.texture:SetAlpha(0.2);
			self.label:SetAlpha(0.2);
		else
			self.texture:SetAlpha(1);
			self.label:SetAlpha(1);
		end
	end	
	if ( moneyFrame.onValueChangedFunc ) then
		moneyFrame.onValueChangedFunc();
	end
	if ( moneyFrame.goldOnly ) then
		moneyFrame.silver:Hide();
		moneyFrame.copper:Hide();
		if ( self.expandOnDigits ) then
			moneyFrame.fixedSilver:Hide();
			moneyFrame.fixedCopper:Hide();
		end
	end
end

function AuctionHouseHelperRetailImportMoneyInputFrame_SetCompact(frame, width, expandOnDigits)
	local goldFrame = frame.gold;
	goldFrame.normalWidth = goldFrame:GetWidth();
	goldFrame.minWidth = width;
	goldFrame.expandOnDigits = expandOnDigits;
	goldFrame:SetWidth(width);
	if ( frame.goldOnly ) then
		return;
	end

	local frameName = frame:GetName();
	local coinFrame;
	-- silver
	coinFrame = CreateFrame("Frame", frameName.."FixedSilver", frame, "FixedCoinFrameTemplate");
	coinFrame:SetPoint("LEFT", goldFrame, "RIGHT", 2, 0);
	coinFrame.texture:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons");
	coinFrame.texture:SetTexCoord(0.25, 0.5, 0, 1);
	coinFrame.label:SetText(SILVER_AMOUNT_SYMBOL);
	frame.fixedSilver = coinFrame;
	-- copper
	coinFrame = CreateFrame("Frame", frameName.."FixedCopper", frame, "FixedCoinFrameTemplate");
	coinFrame:SetPoint("LEFT", frame.fixedSilver, "RIGHT", 2, 0);
	coinFrame.texture:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons");
	coinFrame.texture:SetTexCoord(0.5, 0.75, 0, 1);
	coinFrame.label:SetText(COPPER_AMOUNT_SYMBOL);
	frame.fixedCopper = coinFrame;
end

-- Used to set the frames before the moneyframe when tabbing through
function AuctionHouseHelperRetailImportMoneyInputFrame_SetPreviousFocus(moneyFrame, focus)
	moneyFrame.previousFocus = focus;
end

function AuctionHouseHelperRetailImportMoneyInputFrame_SetNextFocus(moneyFrame, focus)
	moneyFrame.nextFocus = focus;
end

function AuctionHouseHelperRetailImportMoneyInputFrame_SetOnValueChangedFunc(moneyFrame, func)
	moneyFrame.onValueChangedFunc = func;
end

function AuctionHouseHelperRetailImportMoneyInputFrame_OnShow(moneyFrame)
	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		moneyFrame.copper.texture:Hide();
		moneyFrame.gold.texture:Hide();
		moneyFrame.silver.texture:Hide();
		moneyFrame.copper.label:Show();
		moneyFrame.gold.label:Show();
		moneyFrame.silver.label:Show();
		if ( moneyFrame.gold.expandOnDigits ) then
			moneyFrame.fixedSilver.texture:Hide();
			moneyFrame.fixedCopper.texture:Hide();
			moneyFrame.fixedSilver.label:Show();
			moneyFrame.fixedCopper.label:Show();
		end
	else
		moneyFrame.copper.texture:Show();
		moneyFrame.gold.texture:Show();
		moneyFrame.silver.texture:Show();
		moneyFrame.copper.label:Hide();
		moneyFrame.gold.label:Hide();
		moneyFrame.silver.label:Hide();
		if ( moneyFrame.gold.expandOnDigits ) then
			moneyFrame.fixedSilver.texture:Show();
			moneyFrame.fixedCopper.texture:Show();
			moneyFrame.fixedSilver.label:Hide();
			moneyFrame.fixedCopper.label:Hide();
		end		
	end
	if ( moneyFrame.goldOnly ) then
		moneyFrame.copper.texture:Hide();
		moneyFrame.silver.texture:Hide();
		moneyFrame.copper.label:Hide();
		moneyFrame.silver.label:Hide();
		if ( moneyFrame.gold.expandOnDigits ) then
			moneyFrame.fixedSilver.texture:Hide();
			moneyFrame.fixedCopper.texture:Hide();
			moneyFrame.fixedSilver.label:Hide();
			moneyFrame.fixedCopper.label:Hide();
		end
	end
end

function AuctionHouseHelperRetailImportMoneyInputFrame_OpenPopup(moneyFrame)
	if ( popupOwner ) then
		popupOwner.hasPickup = 0;
	end
	if(moneyFrame and moneyFrame.info.canPickup) then
		popupOwner = moneyFrame;
		moneyFrame.hasPickup = 1;
		StaticPopup_Show("PICKUP_MONEY");
	end
end

function AuctionHouseHelperRetailImportMoneyInputFrame_ClosePopup()
	popupOwner = nil;
	StaticPopup_Hide("PICKUP_MONEY");
end

function AuctionHouseHelperRetailImportMoneyInputFrame_PickupPlayerMoney(moneyFrame)
	local copper = AuctionHouseHelperRetailImportMoneyInputFrame_GetCopper(moneyFrame);
	if ( copper > GetMoney() ) then
		UIErrorsFrame:AddMessage(ERR_NOT_ENOUGH_MONEY, 1.0, 0.1, 0.1, 1.0);
	else
		PickupPlayerMoney(copper);
	end
end

AuctionHouseHelperRetailImportLargeMoneyInputBoxMixin = {};

function AuctionHouseHelperRetailImportLargeMoneyInputBoxMixin:OnLoad()
	self:SetFontObject("ChatFontNormal");
	
	if self.iconAtlas then
		self.Icon:SetAtlas(self.iconAtlas);
	end
end

function AuctionHouseHelperRetailImportLargeMoneyInputBoxMixin:Clear()
	self:SetText("");
end

function AuctionHouseHelperRetailImportLargeMoneyInputBoxMixin:SetAmount(amount)
	self:SetNumber(amount);
end

function AuctionHouseHelperRetailImportLargeMoneyInputBoxMixin:GetAmount()
	return self:GetNumber() or 0;
end

function AuctionHouseHelperRetailImportLargeMoneyInputBoxMixin:OnTextChanged()
	self:GetParent():OnAmountChanged();
end

AuctionHouseHelperRetailImportLargeMoneyInputFrameMixin = {};

function AuctionHouseHelperRetailImportLargeMoneyInputFrameMixin:OnLoad()
	if self.hideCopper then
		self.CopperBox:Hide();
		self.SilverBox:ClearAllPoints();
		self.SilverBox:SetPoint("RIGHT", self.CopperBox, "RIGHT");
	
		self.GoldBox.nextEditBox = self.SilverBox;
		self.SilverBox.previousEditBox = self.GoldBox;
		self.SilverBox.nextEditBox = self.nextEditBox;
	else
		self.GoldBox.nextEditBox = self.SilverBox;
		self.SilverBox.previousEditBox = self.GoldBox;
		self.SilverBox.nextEditBox = self.CopperBox;
    ---XXX: Bugfix, had Gold instead of Silver in the following line
		self.CopperBox.previousEditBox = self.SilverBox;
		self.CopperBox.nextEditBox = self.nextEditBox;
	end
end

function AuctionHouseHelperRetailImportLargeMoneyInputFrameMixin:SetNextEditBox(nextEditBox)
	if self.hideCopper then
		self.SilverBox.nextEditBox = nextEditBox or self.GoldBox;

		if nextEditBox then
			nextEditBox.previousEditBox = self.SilverBox;
		end
	else
		self.CopperBox.nextEditBox = nextEditBox or self.GoldBox;

		if nextEditBox then
			nextEditBox.previousEditBox = self.CopperBox;
		end
	end
end

function AuctionHouseHelperRetailImportLargeMoneyInputFrameMixin:Clear()
	self.CopperBox:Clear();
	self.SilverBox:Clear();
	self.GoldBox:Clear();
end

function AuctionHouseHelperRetailImportLargeMoneyInputFrameMixin:SetAmount(amount)
	self.CopperBox:SetAmount(amount % COPPER_PER_SILVER);
	self.SilverBox:SetAmount(math.floor((amount % COPPER_PER_GOLD) / COPPER_PER_SILVER));
	self.GoldBox:SetAmount(math.floor(amount / COPPER_PER_GOLD));
end

function AuctionHouseHelperRetailImportLargeMoneyInputFrameMixin:GetAmount()
	return self.CopperBox:GetAmount() + (self.SilverBox:GetAmount() * COPPER_PER_SILVER) + (self.GoldBox:GetAmount() * COPPER_PER_GOLD);
end

function AuctionHouseHelperRetailImportLargeMoneyInputFrameMixin:SetOnValueChangedCallback(callback)
	self.onValueChangedCallback = callback;
end

function AuctionHouseHelperRetailImportLargeMoneyInputFrameMixin:OnAmountChanged(callback)
	if self.onValueChangedCallback then
		self.onValueChangedCallback();
	end
end
