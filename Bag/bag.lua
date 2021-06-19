local _, addon = ...
local core = addon.core

local CreateFrame = CreateFrame
local UIParent = UIParent
local BackdropTemplateMixin = BackdropTemplateMixin
local ContainerFrame_GetContainerNumSlots = ContainerFrame_GetContainerNumSlots
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS
local BankSlotsFrame = BankSlotsFrame
local NUM_BANKGENERIC_SLOTS = NUM_BANKGENERIC_SLOTS
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local ReagentBankFrame = ReagentBankFrame
local BACKPACK_CONTAINER = BACKPACK_CONTAINER
local BagItemSearchBox = BagItemSearchBox
local BagItemAutoSortButton = BagItemAutoSortButton
local BackpackTokenFrameToken1 = BackpackTokenFrameToken1
local BackpackTokenFrameToken2 = BackpackTokenFrameToken2
local BackpackTokenFrameToken3 = BackpackTokenFrameToken3
local BackpackTokenFrame = BackpackTokenFrame
local OpenBag = OpenBag
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local LootFrame = LootFrame

local cfg = {
	inset = 10,
	header = 50,
	footer = 40,
	size = 45,
	bag_size = 30,
	spacing = 5,
	per_row = 15,
	edit_size = 200,
	edit_letters = 15,
	color = {
		pressed = {.3, .3, .3, .3},
		highlight = {.6, .6, .6, .3},
		checked = {.6, .6, 0, .3},
		backdrop = {.1, .1, .1, .7},
	},
	backdrop = {
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
	},
}

local style_bank_itembutton = function(button)
	if button.styled then return end
	button.styled = true

	button:SetSize(cfg.size, cfg.size)
	core.util.gen_backdrop(button, unpack(core.config.frame_background_transparent))
	local blank = core.media.textures.blank

	-- ItemButton (ContainerFrameItemButtonTemplate)
	--   Layers
	--     BORDER
	local icon = button.icon -- $parentIconTexture
	--     ARTWORK 2
	local count = button.Count -- $parentCount
	--local stock = _G[name.."Stock"]
	--     OVERLAY
	local border = button.IconBorder
	--     OVERLAY 1
	--local overlay = button.IconOverlay -- Azerite/Corruption
	--     OVERLAY 2
	--local levellock = button.LevelLinkLockTexture
	--     OVERLAY 4
	--local search = button.searchOverlay -- $parentSearchOverlay
	--     OVERLAY 5
	--local context = button.ItemContextOverlay

	-- Normal
	-- Pushed
	-- Highlight

	-- BankItemButtonGenericTemplate
	--   Layers
	--     OVERLAY
	local quest = button.IconQuestTexture
	--   Frames
	--local cooldown = button.Cooldown -- $parentCooldown


	-- BankItemButtonBagTemplate
	--   Layers
	--     OVERLAY
	local slot_highlight = button.SlotHighlightTexture
	--local cooldown = button.Cooldown -- $parentCooldown

	-------------------------------

	-- Layers

	-- BORDER

	icon:SetDrawLayer("ARTWORK", -7)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	core.util.set_inside(icon, button)

	-- ARTWORK 2

	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT")
	core.util.fix_string(count)

	-- OVERLAY

	border:SetTexture(blank)
	border:SetAllPoints(button)
	border:SetDrawLayer("BORDER")
	border:SetBlendMode("ADD")

	border.alt_SetTexture = border.SetTexture
	hooksecurefunc(border, "SetTexture", function(self)
		self:alt_SetTexture(blank)
	end)

	if quest then
		quest:SetAllPoints(icon)
		quest:SetTexCoord(.07, .93, .07, .93)
	end

	if slot_highlight then
		slot_highlight:SetTexCoord(.07, .93, .07, .93)
	end

	------------------------------

	local normal = button:GetNormalTexture()
	normal:SetAllPoints(icon)
	normal:SetTexture()

	local pushed = button:GetPushedTexture()
	pushed:SetAllPoints(icon)
	pushed:SetTexture(blank)
	pushed:SetVertexColor(unpack(cfg.color.pressed))
	pushed:SetDrawLayer("ARTWORK", -6)

	local highlight = button:GetHighlightTexture()
	highlight:SetAllPoints(icon)
	highlight:SetTexture(blank)
	highlight:SetVertexColor(unpack(cfg.color.highlight))

end

local style_itembutton = function(button)
	if button.styled then return end
	button.styled = true

	button:SetSize(cfg.size, cfg.size)
	core.util.gen_backdrop(button, unpack(core.config.frame_background_transparent))
	local blank = core.media.textures.blank
	local name = button:GetName()

	-- ItemButton (ContainerFrameItemButtonTemplate)
	--   Layers
	--     BORDER
	local icon = button.icon -- $parentIconTexture
	--     ARTWORK 2
	local count = button.Count -- $parentCount
	--local stock = _G[name.."Stock"]
	--     OVERLAY
	local border = button.IconBorder
	--     OVERLAY 1
	--local overlay = button.IconOverlay -- Azerite/Corruption
	--     OVERLAY 2
	--local levellock = button.LevelLinkLockTexture
	--     OVERLAY 4
	--local search = button.searchOverlay -- $parentSearchOverlay
	--     OVERLAY 5
	--local context = button.ItemContextOverlay

	-- Normal
	-- Pushed
	-- Highlight

	-- ContainerFrameItemButtonTemplate
	--   Frames
	--local cooldown = _G[name.."Cooldown"]

	--   Layers
	--     OVERLAY 1
	--local upgrade = button.UpgradeIcon

	--     OVERLAY 2
	local quest = _G[name.."IconQuestTexture"]
	local flash = button.flash
	local new = button.NewItemTexture
	local battlepay = button.BattlepayItemTexture
	local extended = button.ExtendedSlot

	--     OVERLAY 5
	--local junk = button.JunkIcon

	-- LootButtonTemplate
	--   Layers
	--     OVERLAY
	--local quest = _G[name.."IconQuestTexture"]

	--     ARTWORK
	local nameFrame = _G[name.."NameFrame"]
	local text = _G[name.."Text"]

	-------------------------------

	-- Layers

	-- BORDER

	icon:SetDrawLayer("ARTWORK", -7)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	core.util.set_inside(icon, button)

	-- ARTWORK 2
	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT")
	core.util.fix_string(count)

	-- OVERLAY
	border:SetAllPoints(button)
	border:SetTexture(blank)
	border:SetDrawLayer("BORDER")
	border:SetBlendMode("ADD")

	border.alt_SetTexture = border.SetTexture
	hooksecurefunc(border, "SetTexture", function(self)
		self:alt_SetTexture(blank)
	end)

	-- OVERLAY 2
	quest:SetAllPoints(icon)
	quest:SetTexCoord(.07, .93, .07, .93)

	if flash then
		flash:SetAllPoints(icon)
	end

	if new then
		new:SetAllPoints(icon)
		new:SetTexture(blank)
		new:SetVertexColor(unpack(cfg.color.highlight))

		hooksecurefunc(new, "SetAtlas", function(self)
			self:SetTexture(blank)
		end)
	end

	if battlepay then
		battlepay:SetAllPoints()
	end
	if extended then
		extended:SetAllPoints()
		extended:SetTexture()
	end

	------------------------------

	if nameFrame then
		nameFrame:SetTexture()
	end

	------------------------------

	local normal = button:GetNormalTexture()
	normal:SetAllPoints(icon)
	normal:SetTexture()

	local pushed = button:GetPushedTexture()
	pushed:SetAllPoints(icon)
	pushed:SetTexture(blank)
	pushed:SetVertexColor(unpack(cfg.color.pressed))
	pushed:SetDrawLayer("ARTWORK", -6)

	local highlight = button:GetHighlightTexture()
	highlight:SetAllPoints(icon)
	highlight:SetTexture(blank)
	highlight:SetVertexColor(unpack(cfg.color.highlight))
end

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

local focus_backpack = CreateFrame("Frame", "FocusBagCharacterBag", UIParent, BackdropTemplateMixin and "BackdropTemplate")
focus_backpack:SetWidth(((cfg.size + cfg.spacing) * cfg.per_row) - cfg.spacing + cfg.inset * 2)
focus_backpack:SetHeight(1)
focus_backpack:SetPoint("BOTTOMRIGHT", -200, 200)
focus_backpack:SetFrameStrata("DIALOG")
focus_backpack:Raise()
focus_backpack:Hide()
focus_backpack.min_id = 0
focus_backpack.max_id = 4
core.util.gen_backdrop(focus_backpack)
make_movable(focus_backpack)

local focus_bank = CreateFrame("Frame", "FocusBagBankBag", UIParent, BackdropTemplateMixin and "BackdropTemplate")
focus_bank:SetWidth(((cfg.size + cfg.spacing) * cfg.per_row) - cfg.spacing + cfg.inset * 2)
focus_bank:SetHeight(1)
focus_bank:SetPoint("TOPLEFT", 200, -200)
focus_bank:SetFrameStrata("HIGH")
focus_bank:Raise()
focus_bank:Hide()
focus_bank.min_id = 5
focus_bank.max_id = 11
core.util.gen_backdrop(focus_bank)
make_movable(focus_bank)

local bank_bag_bg = CreateFrame("Frame", nil, focus_bank, BackdropTemplateMixin and "BackdropTemplate")
bank_bag_bg:SetPoint("BOTTOMLEFT", focus_bank, "TOPLEFT", 0, -1)
bank_bag_bg:SetWidth(cfg.inset + (cfg.bag_size + cfg.spacing) * NUM_BANKBAGSLOTS + cfg.bag_size)
bank_bag_bg:SetHeight(cfg.bag_size + cfg.inset * 2)
core.util.gen_backdrop(bank_bag_bg)

local add_reagent_item_to_bag = function(item, bag, style)
	style(item)

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

local add_item_to_bag = function(item, bag, style)
	style(item)

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
	local portrait = container.PortraitButton
	if not bag.last_portrait then
		portrait:SetPoint("TOPLEFT", bag, cfg.inset, -cfg.inset)
	else
		portrait:SetPoint("TOPLEFT", bag.last_portrait, "TOPRIGHT", cfg.spacing, 0)
	end
	bag.last_portrait = portrait

	for i = slots, 1, -1 do
		add_item_to_bag(_G[name.."Item"..i], bag, style_itembutton)
	end
end

local update_bag_items = function(bag)

	bag.num_items = 0
	bag.num_rows = 0

	bag.num_reagent_items = 0
	bag.num_reagent_rows = 0

	bag.last_portrait = nil

	if bag == focus_bank then
		if BankSlotsFrame:IsVisible() then
			for i = 1, NUM_BANKGENERIC_SLOTS, 1 do
				local button = BankSlotsFrame["Item"..i];
				button:ClearAllPoints()
				button:Raise()
				add_item_to_bag(button, bag, style_bank_itembutton)
			end
		end
	end

	for id = bag.min_id, bag.max_id do
		for i = 1, NUM_CONTAINER_FRAMES do
			local container = _G["ContainerFrame"..i]
			if container:GetID() == id and container:IsShown() then
				add_container_to_bag(container, bag)
				break
			end
		end
	end

	if bag == focus_bank then
		if ReagentBankFrame:IsVisible() then
			for i = 1, ReagentBankFrame.size do
				local button = ReagentBankFrame["Item"..i];

				button:ClearAllPoints()
				button:Raise()
				add_reagent_item_to_bag(button, bag, style_bank_itembutton)
			end
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

local skin_edit_box = function(frame)
	if frame.styled then return end
	frame.styled = true

	-- SearchBoxTemplate
	--   Layers
	--     OVERLAY
	local search_icon = frame.searchIcon -- $parentSearchIcon
	--   Frames
	--local clear_button = frame.clearButton -- $parentClearButton
	--     Layers
	--       ARTWORK
	--local clear_button_texture = clear_button.texture


	-- InputBoxInstructionsTemplate (SearchBoxTemplate)
	--   Layers
	--     ARTWORK
	local instructions = frame.Instructions


	-- InputBoxTemplate (InputBoxInstructionsTemplate)
	--   Layers
	--     BACKGROUND
	local left = frame.Left
	local right = frame.Right
	local middle = frame.Middle

	---------------------------------

	left:Hide()
	middle:Hide()
	right:Hide()
	search_icon:Hide()

	core.util.gen_backdrop(frame)
	
	frame:SetWidth(cfg.edit_size)
	frame:SetHeight(cfg.bag_size)
	frame:SetMaxLetters(cfg.edit_letters)
	frame:SetTextInsets(5, 0, 0, 0);
	instructions:SetPoint("TOPLEFT", 5, 0)
	core.util.fix_string(instructions, core.config.font_size_med)
	core.util.fix_string(frame, core.config.font_size_med)
end

local skin_cleanup_button = function(button)
	if button.styled then return end
	button.styled = true

	button:SetSize(cfg.bag_size, cfg.bag_size)
	
	local normal = button:GetNormalTexture()
	normal:SetTexCoord(.18, .82, .18, .82)
	core.util.set_inside(normal, button)

	local pushed = button:GetPushedTexture()
	pushed:SetAllPoints(normal)
	pushed:SetTexCoord(.18, .82, .18, .82)

	local highlight = button:GetHighlightTexture()
	highlight:SetAllPoints(normal)
	highlight:SetTexture(core.media.textures.blank)
	highlight:SetVertexColor(unpack(cfg.color.highlight))

	button.bg = button:CreateTexture(nil, "BACKGROUND")
	button.bg:SetAllPoints()
	button.bg:SetTexture(core.media.textures.blank)
	button.bg:SetVertexColor(unpack(core.config.frame_border))
end

hooksecurefunc("ContainerFrame_Update", function(bag)
	local id = bag:GetID()

	if id == BACKPACK_CONTAINER then
		skin_edit_box(BagItemSearchBox)
		BagItemSearchBox:ClearAllPoints()
		BagItemSearchBox:SetPoint("TOPLEFT", focus_backpack, "TOPRIGHT", -(cfg.inset + BagItemSearchBox:GetWidth()), -cfg.inset)

		BagItemAutoSortButton:ClearAllPoints()
		BagItemAutoSortButton:SetPoint("TOPRIGHT", BagItemSearchBox, "TOPLEFT", -cfg.spacing, 0)
		skin_cleanup_button(BagItemAutoSortButton)
	end
end)

hooksecurefunc("ContainerFrame_OnHide", function(bag)
	local id = bag:GetID()
	if id > focus_backpack.max_id then
		update_bag_items(focus_bank)
	else
		update_bag_items(focus_backpack)
	end
end)

hooksecurefunc("ContainerFrame_GenerateFrame", function(bag)
	local id = bag:GetID()
	
	local name = bag:GetName()

	-- Frames
	local money = _G[name.."MoneyFrame"]
	--   Frames
	--local money_trial_error_button = money.trialErrorButton -- $parentTrialErrorButton
	--     Layers
	--       ARTWORK
	--local money_trial_error_button_texture = _G[money_trial_error_button:GetName().."Texture"]

	local copper = _G[money:GetName().."CopperButton"]
	local copper_text = copper.Text -- $parentText

	local silver = _G[money:GetName().."SilverButton"]
	local silver_text = silver.Text -- $parentText
	
	local gold = _G[money:GetName().."GoldButton"]
	local gold_text = gold.Text -- $parentText

	local portrait_button = bag.PortraitButton -- $parentPortraitButton
	--   Layers
	--     OVERLAY
	local portrait_button_highlight = portrait_button.Highlight

	local filter_icon = bag.FilterIcon
	--   Layers
	--     OVERLAY
	--local filter_icon_icon = filter_icon.Icon

	local add_slots = _G[name.."AddSlotsButton"]
	--   Layers
	--     BACKGROUND
	--     OVERLAY
	--local add_slots_border = add_slots.Border
	--     ARTWORK
	--local add_slots_icon = add_slots.Icon
	--    HighlightTexture

	--local extra_slots_help = bag.ExtraBagSlotsHelpBox -- $parentExtraBagSlotsHelpBox
	--   Layers
	--     ARTWORK
	--local extra_slots_help_arrow = extra_slots_help.Arrow
	--     BORDER
	--local extra_slots_help_arrow_glow = extra_slots_help.ArrowGlow
	--     OVERLAY
	--local extra_slots_help_text = extra_slots_help.Text
	--   Frames
	--local extra_slots_help_close = extra_slots_help.CloseButton

	local close = _G[name.."CloseButton"]
	--local filter_dropdown = bag.FilterDropDown -- $parentFilterDropDown
	local title = bag.ClickableTitleFrame

	-- Layers
	--   BACKGROUND
	local portrait = bag.Portrait -- $parentPortrait
	--   ARTWORK
	local bgtop = _G[name.."BackgroundTop"]
	local bgmiddle1 = _G[name.."BackgroundMiddle1"]
	local bgmiddle2 = _G[name.."BackgroundMiddle2"]
	local bgbottom = _G[name.."BackgroundBottom"]
	local bagname = _G[name.."Name"]
	local bg1slot = _G[name.."Background1Slot"]

	-------------------------------

	bag:EnableMouse(false)
	filter_icon:SetPoint("CENTER", portrait, "BOTTOMRIGHT", -5, 5)

	close:Hide()
	title:Hide()
	bgtop:Hide()
	bgmiddle1:Hide()
	bgmiddle2:Hide()
	bgbottom:Hide()
	bagname:Hide()
	bg1slot:Hide()

	portrait_button:SetSize(cfg.bag_size, cfg.bag_size)
	core.util.set_inside(portrait, portrait_button)
	portrait_button_highlight:SetAllPoints(portrait)
	portrait_button_highlight:SetTexture(core.media.textures.blank)
	portrait_button_highlight:SetVertexColor(unpack(cfg.color.highlight))

	if not bag.portrait_bg then
		bag.portrait_bg = bag:CreateTexture()
		local layer, level = portrait:GetDrawLayer()
		bag.portrait_bg:SetDrawLayer(layer, level - 1)
		bag.portrait_bg:SetAllPoints(portrait_button)
		bag.portrait_bg:SetTexture(core.media.textures.blank)
		bag.portrait_bg:SetVertexColor(unpack(core.config.frame_border))
	end

	-- backpack doesn't actually have a portrait
	if id == BACKPACK_CONTAINER then
		portrait:SetTexture("Interface\\Buttons\\Button-Backpack-Up")
		portrait:SetTexCoord(.1, .9, .1, .9)

		add_slots:ClearAllPoints()
		add_slots:SetPoint("CENTER", focus_backpack, "TOPLEFT", 0, 0)

		local money_size = 15

		money:ClearAllPoints()
		money:SetPoint("TOPRIGHT", focus_backpack, "BOTTOMRIGHT", -cfg.inset, cfg.inset + money_size)

		--copper:SetPoint("RIGHT")
		copper:GetNormalTexture():SetSize(money_size, money_size)
		copper_text:ClearAllPoints()
		copper_text:SetPoint("BOTTOMRIGHT", copper:GetNormalTexture(), "BOTTOMLEFT", 0, 0)
		core.util.fix_string(copper_text)
		copper:Show()
	
		silver:SetPoint("RIGHT", copper_text, "LEFT", -5, 0)
		silver:GetNormalTexture():SetSize(money_size, money_size)
		silver_text:ClearAllPoints()
		silver_text:SetPoint("BOTTOMRIGHT", silver:GetNormalTexture(), "BOTTOMLEFT", 0, 0)
		core.util.fix_string(silver_text)
	
		gold:SetPoint("RIGHT", silver_text, "LEFT", -5, 0)
		gold:GetNormalTexture():SetSize(money_size, money_size)
		gold_text:ClearAllPoints()
		gold_text:SetPoint("BOTTOMRIGHT", gold:GetNormalTexture(), "BOTTOMLEFT", 0, 0)
		core.util.fix_string(gold_text)
	else
		portrait:SetTexCoord(.15, .85, .15, .85)
	end

	if bag.extendedOverlay then
		bag.extendedOverlay:SetTexture()
	end

	if id > focus_backpack.max_id then
		bag:SetFrameStrata(focus_bank:GetFrameStrata())
		update_bag_items(focus_bank)
	else
		bag:SetFrameStrata(focus_backpack:GetFrameStrata())
		update_bag_items(focus_backpack)
	end
	bag:Raise()
end)

ContainerFrame1MoneyFrameCopperButton.alt_SetPoint = ContainerFrame1MoneyFrameCopperButton.SetPoint
hooksecurefunc(ContainerFrame1MoneyFrameCopperButton, "SetPoint", function(self)
	self:alt_SetPoint("RIGHT")
end)
BankFrameMoneyFrameCopperButton.alt_SetPoint = BankFrameMoneyFrameCopperButton.SetPoint
hooksecurefunc(BankFrameMoneyFrameCopperButton, "SetPoint", function(self)
	self:alt_SetPoint("RIGHT")
end)

if not IsAddOnLoaded("Blizzard_TokenUI") then
	LoadAddOn("Blizzard_TokenUI")
end

hooksecurefunc("ManageBackpackTokenFrame", function()
	-- BackpackTokenFrame
	--   Layers
	--     BACKGROUND
	--   Frames
	local tokens = {
		BackpackTokenFrameToken1,
		BackpackTokenFrameToken2,
		BackpackTokenFrameToken3
	}

	BackpackTokenFrame:GetRegions():SetTexture()

	for _, token in ipairs(tokens) do
		-- BackpackTokenTemplate
		--   Layers
		--     ARTWORK
		local icon = token.icon -- $parentIcon
		local count = token.count -- $parentCount

		token:SetSize(100, 15)

		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		token.bg = token:CreateTexture(nil, "BACKGROUND")
		core.util.set_outside(token.bg, icon)
		token.bg:SetTexture(core.media.textures.blank)
		token.bg:SetVertexColor(unpack(core.config.frame_border))

		icon:SetSize(15, 15)
		icon:ClearAllPoints()
		icon:SetPoint("BOTTOMLEFT", token, "BOTTOMLEFT", 0, 0)

		core.util.fix_string(count)
		count:SetJustifyH("LEFT")
		count:SetJustifyV("BOTTOM")
		count:ClearAllPoints()
		count:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, 0)
		count:SetPoint("BOTTOMRIGHT", token, "BOTTOMRIGHT", 0, 0)
	end

	BackpackTokenFrameToken1:ClearAllPoints()
	BackpackTokenFrameToken1:SetPoint("BOTTOMLEFT", focus_backpack, "BOTTOMLEFT", cfg.inset + 1, cfg.inset + 1)
end)

local strip_textures = function(frame, only_textures)
	local regions = { frame:GetRegions() }
	for _, region in ipairs(regions) do
		if region:GetObjectType() ~= "Texture" then
			if only_textures then return end
		else
			region:SetTexture()
		end
		region:Hide()
	end
end

strip_textures(BankFrame)
strip_textures(BankSlotsFrame)

BankFrame.CloseButton:Hide()
BankFrame.NineSlice:Hide()
BankFrameMoneyFrameInset:Hide()
BankFrameMoneyFrameBorder:Hide()

BankItemSearchBox:ClearAllPoints()
BankItemSearchBox:SetPoint("TOPRIGHT", focus_bank, "TOPRIGHT", -cfg.inset, -cfg.inset)
skin_edit_box(BankItemSearchBox)

BankItemAutoSortButton:ClearAllPoints()
BankItemAutoSortButton:SetPoint("TOPRIGHT", BankItemSearchBox, "TOPLEFT", -cfg.spacing, 0)
skin_cleanup_button(BankItemAutoSortButton)

strip_textures(BankFramePurchaseInfo)
BankFramePurchaseButton:ClearAllPoints()
BankFramePurchaseButton:SetPoint("LEFT", BankSlotsFrame["Bag7"], "RIGHT")
BankFramePurchaseButton:SetSize(cfg.bag_size, cfg.bag_size)
strip_textures(BankFramePurchaseButton, true)
core.util.fix_string(BankFramePurchaseButton.Text, core.config.font_size_lrg)
BankFramePurchaseButton.Text:SetAllPoints()
BankFramePurchaseButton.Text:SetText("+")
BankFramePurchaseButton.Text:SetJustifyH("CENTER")
BankFramePurchaseButton.Text:SetJustifyV("MIDDLE")
BankFramePurchaseButton:GetHighlightTexture():SetTexture()

BankFrameDetailMoneyFrame:Hide()
BankFrameMoneyFrame:SetPoint("BOTTOMRIGHT", focus_bank, "BOTTOMRIGHT", -cfg.inset, cfg.inset)

style_bank_itembutton(BankSlotsFrame.Bag1)
BankSlotsFrame.Bag1:SetSize(cfg.bag_size, cfg.bag_size)
BankSlotsFrame.Bag1:ClearAllPoints()
BankSlotsFrame.Bag1:SetPoint("TOPLEFT", bank_bag_bg, "TOPLEFT", cfg.inset, -cfg.inset)
for i = 2, NUM_BANKBAGSLOTS do
	local button = BankSlotsFrame["Bag"..i]
	style_bank_itembutton(button)
	button:SetSize(cfg.bag_size, cfg.bag_size)
	button:SetPoint("TOPLEFT", BankSlotsFrame["Bag"..(i - 1)], "TOPRIGHT", cfg.spacing, 0)
end

for t = 1, 2 do
	local tab = _G["BankFrameTab"..t]
	tab:ClearAllPoints()
	core.util.gen_backdrop(tab)
	strip_textures(tab, true)
	tab:GetHighlightTexture():SetTexture()
	core.util.fix_string(_G["BankFrameTab"..t.."Text"], core.config.font_size_med)
end
_G["BankFrameTab2"]:SetPoint("BOTTOMRIGHT", focus_bank, "TOPRIGHT", 0, -1)
_G["BankFrameTab1"]:SetPoint("BOTTOMRIGHT", _G["BankFrameTab2"], "BOTTOMLEFT", 1, 0)

BankFrame:SetFrameStrata("HIGH")
BankFrame:EnableMouse(false)

strip_textures(ReagentBankFrame.DespositButton, true)
ReagentBankFrame.DespositButton:GetHighlightTexture():SetTexture()
core.util.fix_string(ReagentBankFrame.DespositButton.Text, core.config.font_size_med)
ReagentBankFrame.DespositButton.Text:ClearAllPoints()
ReagentBankFrame.DespositButton:SetAllPoints(ReagentBankFrame.DespositButton.Text)

ReagentBankFrame.UnlockInfo:EnableMouse(true)
ReagentBankFrame.UnlockInfo:ClearAllPoints()
ReagentBankFrame.UnlockInfo:SetPoint("BOTTOMLEFT", focus_bank)
ReagentBankFrame.UnlockInfo:SetPoint("BOTTOMRIGHT", focus_bank)
ReagentBankFrame.UnlockInfo:SetHeight(math.ceil(98 / cfg.per_row) * (cfg.size + cfg.spacing) - cfg.spacing - cfg.inset + cfg.header + cfg.footer)

BankFrame:HookScript("OnShow", function(self)
	if BankSlotsFrame:IsShown() then
		bank_bag_bg:Show()
		for id = 1, NUM_BANKBAGSLOTS do
			OpenBag(id + NUM_BAG_SLOTS)
		end
	end
	update_bag_items(focus_bank)
end)

ReagentBankFrame:HookScript("OnShow", function(self)
	update_bag_items(focus_bank)
	ReagentBankFrame.DespositButton.Text:ClearAllPoints()
	ReagentBankFrame.DespositButton.Text:SetPoint("BOTTOMLEFT", focus_bank, "BOTTOMLEFT", cfg.inset, cfg.inset)
	strip_textures(ReagentBankFrame)
	bank_bag_bg:Hide()
end)

ReagentBankFrame:HookScript("OnHide", function(self)
	update_bag_items(focus_bank)
	bank_bag_bg:Show()
end)

BankFrame:HookScript("OnHide", function()
	update_bag_items(focus_bank)
end)

SetSortBagsRightToLeft(true)
SetInsertItemsLeftToRight(false)

LootFrame.NineSlice:Hide()
LootFrame.Bg:Hide()
LootFrame.TitleBg:Hide()
LootFrame.TopTileStreaks:Hide()
LootFrame.Inset:Hide()

LootFramePortrait:SetPoint("TOPLEFT")
LootFramePortrait:SetSize(60, 30)
LootFramePortrait:SetTexture(core.media.textures.blank)
LootFramePortrait:SetVertexColor(0, 0, 0)
LootFramePortrait:SetDrawLayer("OVERLAY", -2)

LootFramePortraitOverlay:SetTexCoord(.16, .84, .33, .67)
LootFramePortraitOverlay:SetPoint("TOPLEFT", LootFramePortrait, "TOPLEFT", 1, -1)
LootFramePortraitOverlay:SetPoint("BOTTOMRIGHT", LootFramePortrait, "BOTTOMRIGHT", -1, 1)

core.util.gen_backdrop(LootFrame)
LootFrame:SetFrameStrata("DIALOG")
LootFrame:Raise()

style_itembutton(LootButton1)
LootButton1:SetSize(38, 38)
style_itembutton(LootButton2)
LootButton2:SetSize(38, 38)
style_itembutton(LootButton3)
LootButton3:SetSize(38, 38)
style_itembutton(LootButton4)
LootButton4:SetSize(38, 38)
