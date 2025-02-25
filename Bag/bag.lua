local _, addon = ...
if not addon.bag.enabled then return end

local core = addon.core
local lib = addon.skin.lib

local cfg = {
	inset = 5,
	header = 50,
	footer = 40,
	size = ContainerFrame1Item1:GetWidth(),
	bag_size = BankSlotsFrame.Bag1:GetWidth(),
	spacing = 5,
	per_row = 15,
}

local make_movable = function(frame)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		self:SetUserPlaced(false)

		local left, top = self:GetLeft(), self:GetTop()
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
	end)
end

local focus_bank = CreateFrame("Frame", "FocusBagBankBag", UIParent, BackdropTemplateMixin and "BackdropTemplate")
focus_bank:SetWidth(((cfg.size + cfg.spacing) * cfg.per_row) - cfg.spacing + cfg.inset * 2)
focus_bank:SetHeight(1)
focus_bank:SetPoint("TOPLEFT", 200, -200)
focus_bank:SetFrameStrata("HIGH")
focus_bank:Raise()
focus_bank:Hide()
core.util.gen_backdrop(focus_bank, unpack(core.config.frame_background_transparent))
make_movable(focus_bank)

local bank_bag_bg = CreateFrame("Frame", nil, focus_bank, BackdropTemplateMixin and "BackdropTemplate")
bank_bag_bg:SetPoint("BOTTOMLEFT", focus_bank, "TOPLEFT", 0, -1)
bank_bag_bg:SetWidth(cfg.inset * 2 + (cfg.bag_size + cfg.spacing) * NUM_BANKBAGSLOTS - cfg.spacing)
bank_bag_bg:SetHeight(cfg.bag_size + cfg.inset * 2)
core.util.gen_backdrop(bank_bag_bg, unpack(core.config.frame_background_transparent))

local add_reagent_item_to_bag = function(item, bag)
	local start = -cfg.header + (-cfg.size + -cfg.spacing) * bag.num_rows + ((-cfg.header + cfg.spacing) * (bag.num_rows > 0 and 1 or 0))

	if bag.num_reagent_items == 0 then
		item:SetPoint("TOPLEFT", bag, "TOPLEFT", cfg.inset, start)
		bag.num_reagent_items = 1
		bag.num_reagent_rows = 1
	elseif bag.num_reagent_items == cfg.per_row then
		item:SetPoint("TOPLEFT", bag, "TOPLEFT", cfg.inset, start + (-cfg.size + -cfg.spacing) * bag.num_reagent_rows)
		bag.num_reagent_rows = bag.num_reagent_rows + 1
		bag.num_reagent_items = 1
	else
		item:SetPoint("TOPLEFT", bag, "TOPLEFT", cfg.inset + (cfg.size + cfg.spacing) * bag.num_reagent_items, start + (-cfg.size + -cfg.spacing) * (bag.num_reagent_rows - 1))
		bag.num_reagent_items = bag.num_reagent_items + 1
	end
end

local add_item_to_bag = function(item, bag)
	if bag.num_items == 0 then
		item:SetPoint("BOTTOMRIGHT", bag, "TOPLEFT", cfg.inset + cfg.size, -cfg.header + -cfg.size)
		bag.num_items = 1
		bag.num_rows = 1
	elseif bag.num_items == cfg.per_row then
		item:SetPoint("BOTTOMRIGHT", bag, "TOPLEFT", cfg.inset + cfg.size, -cfg.header + -cfg.size + (-cfg.size + -cfg.spacing) * bag.num_rows)
		bag.num_rows = bag.num_rows + 1
		bag.num_items = 1
	else
		item:SetPoint("BOTTOMRIGHT", bag, "TOPLEFT", cfg.inset + cfg.size + (cfg.size + cfg.spacing) * bag.num_items, -cfg.header + -cfg.size + (-cfg.size + -cfg.spacing) * (bag.num_rows - 1))
		bag.num_items = bag.num_items + 1
	end
end

local add_container_to_bag = function(container, bag)
	local id = container:GetID()
	local name = container:GetName()
	local slots = ContainerFrame_GetContainerNumSlots(id)
	local portrait = container.PortraitContainer.portrait
	container.PortraitButton:SetAllPoints(portrait)
	
	local size = BankSlotsFrame.Bag1:GetWidth()
	portrait:SetSize(size, size)
	if not bag.last_portrait then
		portrait:SetPoint("TOPLEFT", bag, cfg.inset, -cfg.inset)
	else
		portrait:SetPoint("TOPLEFT", bag.last_portrait, "TOPRIGHT", cfg.spacing, 0)
	end
	bag.last_portrait = portrait

	for i = slots, 1, -1 do
		local item = _G[name.."Item"..i]
		add_item_to_bag(item, bag)
	end
end

local update_bag_items = function(bag)
	bag.num_items = 0
	bag.num_rows = 0

	bag.num_reagent_items = 0
	bag.num_reagent_rows = 0

	bag.last_portrait = nil

	if BankSlotsFrame:IsVisible() then
		for i = 1, NUM_BANKGENERIC_SLOTS do
			local item = BankSlotsFrame["Item"..i];
			item:ClearAllPoints()
			item:Raise()

			lib.skin_itembutton(item, {["BankItemButtonGenericTemplate"] = true})
			add_item_to_bag(item, bag)
		end
	end

	for id = NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS do
		for i = 1, NUM_CONTAINER_FRAMES do
			local container = _G["ContainerFrame"..i]
			if container:GetID() == id and container:IsShown() then
				add_container_to_bag(container, bag)
				break
			end
		end
	end

	if ReagentBankFrame:IsVisible() then
		for i = 1, ReagentBankFrame.size do
			local button = ReagentBankFrame["Item"..i];
			lib.skin_itembutton(button, {["ReagentBankItemButtonGenericTemplate"] = true})
			button:ClearAllPoints()
			button:Raise()
			add_reagent_item_to_bag(button, bag)
		end
	end

	if bag.num_rows + bag.num_reagent_rows > 0 then
		local height = 0
		if bag.num_rows > 0 then
			height = height + cfg.header + bag.num_rows * (cfg.size + cfg.spacing) - cfg.spacing
		end
		if bag.num_reagent_rows > 0 then
			height = height + cfg.header + bag.num_reagent_rows * (cfg.size + cfg.spacing) - cfg.spacing
		end
		bag:SetHeight(height + cfg.footer)
		bag:Show()
	else
		bag:Hide()
	end
end


local bags = {
	ContainerFrame1,
	ContainerFrame2,
	ContainerFrame3,
	ContainerFrame4,
	ContainerFrame5,
	ContainerFrame6,
	ContainerFrame7,
	ContainerFrame8,
	ContainerFrame9,
	ContainerFrame10,
	ContainerFrame11,
	ContainerFrame12,
	ContainerFrame13,
	ContainerFrameCombinedBags
}

for _, container in ipairs(bags) do
	container.PortraitContainer.portrait:SetSize(40, 40)

	core.util.gen_backdrop(container, unpack(core.config.frame_background_transparent))
	container.NineSlice:Hide()
	container.Bg:Hide()

	container.PortraitContainer.portrait:ClearAllPoints()
	container.PortraitContainer.portrait:SetPoint("TOPLEFT", -10, 10)
	container.PortraitContainer.bg = container.PortraitContainer:CreateTexture(nil, "OVERLAY", nil, -2)
	container.PortraitContainer.bg:SetColorTexture(unpack(core.config.color.light_border))
	core.util.set_outside(container.PortraitContainer.bg, container.PortraitContainer.portrait)

	container.PortraitContainer.portrait.mask = container.PortraitContainer.CircleMask
	core.util.circle_mask(container.PortraitContainer, container.PortraitContainer.portrait, 3)
	core.util.circle_mask(container.PortraitContainer, container.PortraitContainer.bg, 3)
	hooksecurefunc(container, "SetPortraitShown", function(self, shown)
		if shown then
			self.PortraitContainer.bg:Show()
		else
			self.PortraitContainer.bg:Hide()
		end
	end)
	core.util.fix_string(container.TitleContainer.TitleText, core.config.font_size_med)

	container.CloseButton:ClearAllPoints()
	container.CloseButton:SetPoint("TOPRIGHT", -3, -3)
	lib.skin_icon_button(container.CloseButton, nil, "x")
end
ContainerFrame1.MoneyFrame.Border:Hide()
ContainerFrameCombinedBags.MoneyFrame.Border:Hide()

for c = 1, NUM_CONTAINER_FRAMES do
	local i = 1
	local item = _G["ContainerFrame"..c.."Item"..i]
	while item do
		lib.skin_itembutton(item, {["ContainerFrameItemButtonTemplate"] = true})
		i = i + 1
		item = _G["ContainerFrame"..c.."Item"..i]
	end

	_G["ContainerFrame"..c]:HookScript("OnHide", function(container)
		local id = container:GetID()
		if id > NUM_TOTAL_EQUIPPED_BAG_SLOTS then
			update_bag_items(focus_bank)
		end
	end)
end

core.util.fix_editbox(BagItemSearchBox)
lib.skin_icon_button(BagItemAutoSortButton, nil, "C")

local skin_tokens = function(tracker)
	-- BackpackTokenFrameTemplate
	tracker.Border:Hide()
	local prev
	for token in tracker.tokenPool:EnumerateActive() do
		if not prev then
			token:ClearAllPoints()
			token:SetPoint("BOTTOMRIGHT", -4, 0)
		else
			token:ClearAllPoints()
			token:SetPoint("BOTTOMRIGHT", prev, "BOTTOMLEFT", -3, 0)
		end
		prev = token
		core.util.crop_icon(token.Icon)
		token.Icon:SetSize(15, 15)
		token:SetSize(60, 15)
		core.util.fix_string(token.Count)
		token.Count:SetPoint("BOTTOMRIGHT", token.Icon, "BOTTOMLEFT")
	end
end

hooksecurefunc(ContainerFrame1, "SetTokenTracker", function(self, tracker)
	skin_tokens(tracker)

	if not tracker.hooked then
		tracker.hooked = true
		hooksecurefunc(tracker, "Update", function(tracker)
			skin_tokens(tracker)
		end)
	end
end)

hooksecurefunc(ContainerFrameCombinedBags, "SetTokenTracker", function(self, tracker)
	skin_tokens(tracker)

	if not tracker.hooked then
		tracker.hooked = true
		hooksecurefunc(tracker, "Update", function(tracker)
			skin_tokens(tracker)
		end)
	end
end)

local anchor_tokens = function(bag)
	local tokenFrame = ContainerFrameSettingsManager:GetTokenTrackerIfShown(bag)
	
	if tokenFrame then
		tokenFrame:ClearAllPoints();
		tokenFrame:SetPoint("BOTTOMLEFT", 3, 3)
		tokenFrame:SetPoint("BOTTOMRIGHT", -3, 3)

		bag.MoneyFrame:ClearAllPoints();
		bag.MoneyFrame:SetPoint("BOTTOMRIGHT", tokenFrame, "TOPRIGHT", 0, 3);
		bag.MoneyFrame:SetPoint("BOTTOMLEFT", tokenFrame, "TOPLEFT", 0, 3);
	else
		bag.MoneyFrame:ClearAllPoints();
		bag.MoneyFrame:SetPoint("BOTTOMLEFT", 3, 3);
		bag.MoneyFrame:SetPoint("BOTTOMRIGHT", -3, 3);
	end
end

hooksecurefunc(ContainerFrame1, "UpdateCurrencyFrames", function(bag)
	anchor_tokens(bag)
end)

hooksecurefunc(ContainerFrameCombinedBags, "UpdateCurrencyFrames", function(bag)
	anchor_tokens(bag)
end)

hooksecurefunc("MoneyFrame_Update", function(name)
	local frame
	if ( type(name) == "table" ) then
		frame = name
		name = frame:GetName()
	else
		frame = _G[name]
	end

	local goldButton = frame.GoldButton
	local silverButton = frame.SilverButton
	local copperButton = frame.CopperButton

	if copperButton:IsShown() then
		copperButton:SetPoint("RIGHT")
	elseif silverButton:IsShown() then
		silverButton:SetPoint("RIGHT")
	elseif goldButton:IsShown() then
		goldButton:SetPoint("RIGHT")
	end
end)

hooksecurefunc("ContainerFrame_GenerateFrame", function(bag)
	local id = bag:GetID()
	if id > NUM_TOTAL_EQUIPPED_BAG_SLOTS then
		bag:EnableMouse(false)
		bag.ClickableTitleFrame:Hide()
		bag.CloseButton:Hide()
		bag.TitleContainer:Hide()
		core.util.strip_textures(bag)
		bag:SetFrameStrata(focus_bank:GetFrameStrata())
		update_bag_items(focus_bank)
		bag:Raise()
	end
end)

core.util.strip_textures(BankFrame)
core.util.strip_textures(BankSlotsFrame)

BankFrame.CloseButton:Hide()
BankFrame.NineSlice:Hide()
BankFrame.PortraitContainer:Hide()
BankFrame.TitleContainer:Hide()
BankFrameMoneyFrameInset:Hide()
BankFrameMoneyFrameBorder:Hide()
BankFrameTitleText:Hide()

BankItemSearchBox:ClearAllPoints()
BankItemSearchBox:SetPoint("TOPRIGHT", focus_bank, "TOPRIGHT", -cfg.inset, -cfg.inset)
core.util.fix_editbox(BankItemSearchBox)

BankItemAutoSortButton:ClearAllPoints()
BankItemAutoSortButton:SetPoint("TOPRIGHT", BankItemSearchBox, "TOPLEFT", -cfg.spacing, 0)
lib.skin_icon_button(BankItemAutoSortButton, nil, "C")

core.util.strip_textures(BankFramePurchaseInfo)
lib.skin_button(BankFramePurchaseButton)
BankFramePurchaseButton:ClearAllPoints()
BankFramePurchaseButton:SetPoint("BOTTOMLEFT", BankSlotsFrame.Bag7, "BOTTOMRIGHT", 10, 0)
BankFramePurchaseButton:SetSize(30, 30)
core.util.fix_string(BankFramePurchaseButton.Text, core.config.font_size_lrg)
BankFramePurchaseButton.Text:SetAllPoints()
BankFramePurchaseButton.Text:SetText("+")
BankFramePurchaseButton.Text:SetJustifyH("CENTER")
BankFramePurchaseButton.Text:SetJustifyV("MIDDLE")

BankFrameDetailMoneyFrame:Hide()
BankFrameMoneyFrame:SetPoint("BOTTOMRIGHT", focus_bank, "BOTTOMRIGHT", -3, 3)

lib.skin_itembutton(BankSlotsFrame.Bag1, {["BankItemButtonBagTemplate"] = true})
BankSlotsFrame.Bag1:ClearAllPoints()
BankSlotsFrame.Bag1:SetPoint("TOPLEFT", bank_bag_bg, "TOPLEFT", 5, -5)
for i = 2, NUM_BANKBAGSLOTS do
	local button = BankSlotsFrame["Bag"..i]
	lib.skin_itembutton(button, {["BankItemButtonBagTemplate"] = true})
	button:SetPoint("TOPLEFT", BankSlotsFrame["Bag"..(i - 1)], "TOPRIGHT", 5, 0)
end

for t = 1, 2 do
	local tab = _G["BankFrameTab"..t]
	tab:ClearAllPoints()
	core.util.fix_string(_G["BankFrameTab"..t].Text, core.config.font_size_sml)
end
_G["BankFrameTab2"]:SetPoint("BOTTOMRIGHT", focus_bank, "TOPRIGHT", 0, -1)
_G["BankFrameTab1"]:SetPoint("BOTTOMRIGHT", _G["BankFrameTab2"], "BOTTOMLEFT", 1, 0)

BankFrame:SetFrameStrata("HIGH")
BankFrame:EnableMouse(false)

lib.skin_button(ReagentBankFrame.DespositButton)
ReagentBankFrame.DespositButton:ClearAllPoints()
ReagentBankFrame.DespositButton:SetPoint("BOTTOMLEFT", focus_bank, "BOTTOMLEFT", cfg.inset, cfg.inset)

ReagentBankFrame.UnlockInfo:EnableMouse(true)
ReagentBankFrame.UnlockInfo:ClearAllPoints()
ReagentBankFrame.UnlockInfo:SetPoint("BOTTOMLEFT", focus_bank)
ReagentBankFrame.UnlockInfo:SetPoint("BOTTOMRIGHT", focus_bank)
ReagentBankFrame.UnlockInfo:SetHeight(math.ceil(98 / cfg.per_row) * (cfg.size + cfg.spacing) - cfg.spacing - cfg.inset + cfg.header + cfg.footer)

BankFrame:HookScript("OnShow", function(self)
	if BankSlotsFrame:IsShown() then
		bank_bag_bg:Show()
		for id = 1, NUM_BANKBAGSLOTS do
			OpenBag(id + NUM_TOTAL_EQUIPPED_BAG_SLOTS)
		end
	end
	update_bag_items(focus_bank)
end)

ReagentBankFrame:HookScript("OnShow", function(self)
	update_bag_items(focus_bank)
	core.util.strip_textures(ReagentBankFrame)
	bank_bag_bg:Hide()
end)

ReagentBankFrame:HookScript("OnHide", function(self)
	update_bag_items(focus_bank)
	bank_bag_bg:Show()
end)

BankFrame:HookScript("OnHide", function()
	update_bag_items(focus_bank)
end)

-- LootFrame.NineSlice:Hide()
-- LootFrame.Bg:Hide()
-- LootFrame.TitleBg:Hide()
-- LootFrame.TopTileStreaks:Hide()
-- LootFrame.Inset:Hide()

-- LootFramePortrait:SetPoint("TOPLEFT")
-- LootFramePortrait:SetSize(60, 30)
-- LootFramePortrait:SetTexture(core.media.textures.blank)
-- LootFramePortrait:SetVertexColor(0, 0, 0)
-- LootFramePortrait:SetDrawLayer("OVERLAY", -2)

-- LootFramePortraitOverlay:SetTexCoord(.16, .84, .33, .67)
-- LootFramePortraitOverlay:SetPoint("TOPLEFT", LootFramePortrait, "TOPLEFT", 1, -1)
-- LootFramePortraitOverlay:SetPoint("BOTTOMRIGHT", LootFramePortrait, "BOTTOMRIGHT", -1, 1)

-- core.util.gen_backdrop(LootFrame, unpack(core.config.frame_background_transparent))
-- LootFrame:SetFrameStrata("DIALOG")
-- LootFrame:Raise()

-- lib.skin_itembutton(LootButton1, {["LootButtonTemplate"] = true}, 38, 38)
-- lib.skin_itembutton(LootButton2, {["LootButtonTemplate"] = true}, 38, 38)
-- lib.skin_itembutton(LootButton3, {["LootButtonTemplate"] = true}, 38, 38)
-- lib.skin_itembutton(LootButton4, {["LootButtonTemplate"] = true}, 38, 38)


