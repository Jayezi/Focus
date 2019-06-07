local cui = CityUi

BACKPACK_HEIGHT = 22

local config = {
	size = 45,
	bag_size = 30,
	spacing = 5,
	bpr = 12,
	backdrop_color = {.1, .1, .1, .7},
	pressed = {.3, .3, .3, .5},
	highlight = {.6, .6, .6, .3},
	quest = {1, 1, 0, 1},
	backdrop = {
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8", 
		edgeSize = 1,
	},
}

local function strip_textures(object, keep_strings)
	local regions = {object:GetRegions()}
	for i = 1, #regions do
		local region = regions[i]
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
			region.Show = function() end
			region:SetAlpha(0)
		elseif not keep_strings then
			region:Hide()
		end
	end
end

local function make_movable(frame)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	--frame:SetUserPlaced(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
end

local bag_colors = {
	[0x0008] = {0.56, 0.42, 0.33},	-- Leatherworking Bag
	[0x0010] = {1, 1, 1},			-- Inscription Bag
	[0x0020] = {0, 1, 0},			-- Herb Bag
	[0x0040] = {1, 0, 1},			-- Enchanting Bag
	[0x0080] = {0.5, 0.5, 0.5},		-- Engineering Bag
	[0x0200] = {1, 0, 0},			-- Gem Bag
	[0x0400] = {1, 1, 0},			-- Mining Bag
	[0x0800] = {1, 1, 1},			-- Unused
	[0x100000] = {0, 1, 1},			-- Tackle Box
}

local function skin_colors(size, frame, bag_id)
	local bag_type = select(2, GetContainerNumFreeSlots(bag_id - 1))
	local bag_color
		
	if (not bag_type) then
		bag_type = 0
	end
		
	local bag_color = bag_colors[bag_type]
	for i = 1, size do
		cui.util.gen_backdrop(_G[frame..i], bag_color)
	end
end

local function skin_items(index, frame)
    for i = 1, index do
        local item = _G[frame..i]
		local icon = _G[frame..i.."IconTexture"]
		local count = _G[frame..i.."Count"]
		local cooldown = _G[frame..i.."Cooldown"]
		local border = item.IconBorder
		local new = item.NewItemTexture
		local quest = _G[frame..i.."IconQuestTexture"]

		count:SetDrawLayer("OVERLAY")
		cui.util.fix_string(count, cui.config.font_size_med)
		count:SetJustifyH("RIGHT")
		count:SetJustifyV("BOTTOM")
		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", 0, 3)

		icon:SetDrawLayer("OVERLAY", -8)
		icon:SetTexCoord(.1, .9, .1, .9)
		cui.util.set_inside(icon, item)

		cooldown:SetAllPoints(icon)
		cooldown:SetHideCountdownNumbers(false)
		cooldown:SetDrawEdge(false)
		cui.util.fix_string(cooldown:GetRegions(), cui.config.font_size_lrg)

		local blank = cui.media.textures.blank
		
		if new then
			new.Show = function() return end
			new:Hide()
		end
		
		local pushed = item:GetPushedTexture()
		pushed:SetDrawLayer("OVERLAY", -7)
		pushed:SetAllPoints(icon)
		pushed:SetTexture(blank)
		pushed:SetVertexColor(unpack(config.pressed))

		local highlight = item:GetHighlightTexture()
		highlight:SetAllPoints(icon)
		highlight:SetTexture(blank)
		highlight:SetVertexColor(unpack(config.highlight))

		border:SetTexture(blank)
		border.SetTexture = function() return end
		border:SetAllPoints(item)
		border:SetDrawLayer("BORDER", 7)

		if (quest) then
			quest:SetVertexColor(unpack(config.quest))
			quest:SetAllPoints(icon)
			quest:SetTexCoord(.1, .9, .1, .9)
		end

        item:SetNormalTexture("")
    end
end

local function create(name, ...)

	local frame = CreateFrame("Frame", "CityBag"..name, UIParent)
	frame:SetWidth(((config.size + config.spacing) * config.bpr) + 20 - config.spacing)
	frame:SetPoint(...)
	frame:SetFrameStrata("HIGH")
	frame:SetFrameLevel(2)
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	frame:Hide()

	cui.util.gen_backdrop(frame)
	make_movable(frame)
	
	if name == "Bank" then
		local last_bag
		for i = 1, 7 do
			local bag = BankSlotsFrame["Bag"..i]
			bag:ClearAllPoints()
			bag:SetSize(config.bag_size, config.bag_size)

			if last_bag then
				bag:SetPoint("LEFT", last_bag, "RIGHT", config.spacing, 0)
			else
				bag:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
			end
			last_bag = bag

			local icon = bag.icon
			icon:SetTexCoord(.1, .9, .1, .9)
			icon:SetPoint("TOPLEFT", bag, 1, -1)
			icon:SetPoint("BOTTOMRIGHT", bag, -1, 1)

			bag:SetNormalTexture("")
			bag:SetPushedTexture("")
			bag:SetHighlightTexture("")
			--bag:SetCheckedTexture("");
			
			local blank = cui.media.textures.blank
			local border = bag.IconBorder
			hooksecurefunc(border, "SetTexture", function(self, tex)
				if tex ~= blank then
					self:SetTexture(blank)
				end
			end)
			border:SetTexture(blank)
			border:SetAllPoints(bag)
			border:SetDrawLayer("BACKGROUND", 7)
		end
	end
	return frame
end

local function skin_edit_box(frame)
	frame.Left:Hide()
	frame.Middle:Hide()
	frame.Right:Hide()
	frame:SetSize(150, 20)
	
	cui.util.gen_backdrop(frame)

	_G[frame:GetName().."SearchIcon"]:Hide()
	frame:SetTextInsets(5, 20, 0, 2);
	frame.Instructions:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, 2)
	cui.util.fix_string(frame.Instructions, cui.config.font_size_med)
	cui.util.fix_string(frame, cui.config.font_size_med)
end

skin_items(28, "BankFrameItem")
for i = 1, 12 do
    skin_items(MAX_CONTAINER_ITEMS, "ContainerFrame"..i.."Item")
end

local backpack = create("Backpack", "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -30, 30)
local bank = create("Bank", "TOPLEFT", UIParent, "TOPLEFT", 30, -30)

hooksecurefunc("ContainerFrame_Update", function(frame)
	local id = frame:GetID()

	if id == 1 then
		BagItemSearchBox:ClearAllPoints()
		BagItemSearchBox:SetPoint("TOPRIGHT", backpack, "TOPRIGHT", -10, -10)
		
		BagItemAutoSortButton:ClearAllPoints()
		BagItemAutoSortButton:SetPoint("TOPLEFT", backpack, "TOPLEFT", 10, -10)

		BankItemSearchBox:ClearAllPoints()
		BankItemSearchBox:SetPoint("TOPRIGHT", bank, "TOPRIGHT", -10, -10)

		BankItemAutoSortButton:ClearAllPoints()
		BankItemAutoSortButton:SetPoint("TOPRIGHT", BankItemSearchBox, "TOPLEFT", -5, 0)
	end
end)

SetSortBagsRightToLeft(true)
SetInsertItemsLeftToRight(false)

skin_edit_box(BagItemSearchBox)
skin_edit_box(BankItemSearchBox)

for i = 1, 3 do
	local frame = _G["BackpackTokenFrameToken"..i]
	frame:SetSize(100, 20)

	local icon = _G["BackpackTokenFrameToken"..i.."Icon"]
	icon:SetSize(20, 20)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:ClearAllPoints()
	icon:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)

	local count = _G["BackpackTokenFrameToken"..i.."Count"]
	cui.util.fix_string(count, cui.config.font_size_med)
	count:SetJustifyH("LEFT")
	count:SetJustifyV("BOTTOM")
	count:ClearAllPoints()
	count:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 10, 0)
	count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

	frame:ClearAllPoints()
	if i == 1 then
		frame:SetPoint("BOTTOMLEFT", backpack, "BOTTOMLEFT", 10, 10)
	else
		frame:SetPoint("LEFT", _G["BackpackTokenFrameToken"..(i - 1)], "RIGHT", 5, 0)
	end
end

local money_text = {
	"ContainerFrame1MoneyFrameGoldButtonText",
	"ContainerFrame1MoneyFrameSilverButtonText",
	"ContainerFrame1MoneyFrameCopperButtonText",
	"BankFrameMoneyFrameGoldButtonText",
	"BankFrameMoneyFrameSilverButtonText",
	"BankFrameMoneyFrameCopperButtonText"
}

for _, name in pairs(money_text) do
	cui.util.fix_string(_G[name], cui.config.font_size_med)
end

ContainerFrame1MoneyFrame:ClearAllPoints()
ContainerFrame1MoneyFrame:Show()
ContainerFrame1MoneyFrame:SetPoint("BOTTOMRIGHT", backpack, "BOTTOMRIGHT", -5, 10)

local function set_bank(show)
	if show then
		local num_rows, last_row_first_item, num_items, last_item = 0, nil, 0, nil

		skin_colors(28, "BankFrameItem", 0)
		
		bank:SetID(BANK_CONTAINER)
		for index = 1, 28 do
			local item = _G["BankFrameItem"..index]
			item:ClearAllPoints()
			item:SetSize(config.size, config.size)
			item:Show()
			
			if (not last_item) then
				item:SetPoint("TOPLEFT", bank, "TOPLEFT", 10, -45)
				last_row_first_item = item
				num_items = num_items + 1
			elseif num_items == config.bpr then
				item:SetPoint("TOPLEFT", last_row_first_item, "BOTTOMLEFT", 0, -config.spacing)
				last_row_first_item = item
				num_rows = num_rows + 1
				num_items = 1
			else
				item:SetPoint("TOPLEFT", last_item, "TOPRIGHT", config.spacing, 0)
				num_items = num_items + 1
			end
			last_item = item
		end

		for bag = 6, 12 do
			local slots = GetContainerNumSlots(bag - 1)
			skin_colors(MAX_CONTAINER_ITEMS, "ContainerFrame"..bag.."Item", bag)
			
			for item = slots, 1, -1 do
				
				local item = _G["ContainerFrame"..bag.."Item"..item]
				item:ClearAllPoints()
				item:SetSize(config.size, config.size)
				item:Show()

				if num_items == config.bpr then
					item:SetPoint("TOPLEFT", last_row_first_item, "BOTTOMLEFT", 0, -config.spacing)
					last_row_first_item = item
					num_rows = num_rows + 1
					num_items = 1
				else
					item:SetPoint("TOPLEFT", last_item, "TOPRIGHT", config.spacing, 0)
					num_items = num_items + 1
				end
				last_item = item
			end
		end
		bank:SetHeight(((config.size + config.spacing) * (num_rows + 1) + 100) - config.spacing)

		BankFrame:EnableMouse(false)
		BankFrame:SetFrameStrata("HIGH")
		BankFrame:SetFrameLevel(3)
		BankSlotsFrame:EnableMouse(false)

		BankPortraitTexture:Hide()
		BankFrameCloseButton:Hide()
		BankFrameMoneyFrame:Hide()
		BankFrameMoneyFrameInset:Hide()
		BankFrameMoneyFrameBorder:Hide()
		BankFrameMoneyFrame:Hide()
		strip_textures(BankFrame)
		strip_textures(BankSlotsFrame)
		strip_textures(ReagentBankFrame)
		BankFrame.NineSlice:Hide()
		ReagentBankFrame:DisableDrawLayer("BACKGROUND")
		ReagentBankFrame:DisableDrawLayer("ARTWORK")

		BankFrameTab1Text:ClearAllPoints()
		BankFrameTab2Text:ClearAllPoints()

		BankFrameTab1:SetPoint("TOPLEFT", bank, "TOPLEFT", 10, -10)
		BankFrameTab2:SetPoint("LEFT", BankFrameTab1Text, "RIGHT", 10, 0)

		BankFrameTab1:SetSize(50, 20)
		BankFrameTab2:SetSize(125, 20)

		BankFrameTab1Text:SetJustifyH("CENTER")
		BankFrameTab2Text:SetJustifyH("MIDDLE")
		BankFrameTab1Text:SetJustifyV("CENTER")
		BankFrameTab2Text:SetJustifyV("MIDDLE")

		BankFrameTab1Text:SetAllPoints(BankFrameTab1)
		BankFrameTab2Text:SetAllPoints(BankFrameTab2)

		cui.util.fix_string(BankFrameTab1Text, cui.config.font_size_med)
		cui.util.fix_string(BankFrameTab2Text, cui.config.font_size_med)

		strip_textures(BankFrameTab1, true)
		strip_textures(BankFrameTab2, true)

		strip_textures(BankFramePurchaseInfo)
		BankFrameDetailMoneyFrame:Hide()

		BankFramePurchaseButton:SetSize(config.bag_size, config.bag_size)
		BankFramePurchaseButton:ClearAllPoints()
		BankFramePurchaseButton:SetPoint("LEFT", BankSlotsFrame["Bag7"], "RIGHT", 5, 0)
		strip_textures(BankFramePurchaseButton, true)

		cui.util.fix_string(BankFramePurchaseButtonText, cui.config.font_size_med)
		BankFramePurchaseButtonText:SetAllPoints(BankFramePurchaseButton)
		BankFramePurchaseButtonText:SetText("+")
		BankFramePurchaseButtonText:SetJustifyH("CENTER")
		BankFramePurchaseButtonText:SetJustifyV("MIDDLE")
	else
		for index = 1, 28 do
			_G["BankFrameItem"..index]:Hide()
		end
		for bag = 6, 12 do
			local slots = GetContainerNumSlots(bag - 1)
			if slots < 40 then slots = 40 end
			for item = 1, slots do
				if (_G["ContainerFrame"..bag.."Item"..item]) then
					_G["ContainerFrame"..bag.."Item"..item]:Hide()
				end
			end
		end
	end
end

local function set_reagents(show)

	local num_rows, last_row_first_item, num_items, last_item = 0, nil, 0, nil
	for i = 1, 98 do
		local item = _G["ReagentBankFrameItem"..i]
		if (not item) then return end
		item:ClearAllPoints()
		item:SetSize(config.size, config.size)
		item:Show()

		if (not last_item) then
			item:SetPoint("TOPLEFT", bank, "TOPLEFT", 10, -45)
			last_row_first_item = item
			num_items = num_items + 1
		elseif num_items == config.bpr then
			item:SetPoint("TOPLEFT", last_row_first_item, "BOTTOMLEFT", 0, -config.spacing)
			last_row_first_item = item
			num_rows = num_rows + 1
			num_items = 1
		else
			item:SetPoint("TOPLEFT", last_item, "TOPRIGHT", config.spacing, 0)
			num_items = num_items + 1
		end
		last_item = item
	end
	bank:SetHeight(((config.size + config.spacing) * (num_rows + 1) + 100) - config.spacing)

	skin_colors(98, "ReagentBankFrameItem", 0)
	skin_items(98, "ReagentBankFrameItem")
	
	cui.util.fix_string(ReagentBankFrameText, cui.config.font_size_med)
	ReagentBankFrameText:ClearAllPoints()
	ReagentBankFrameText:SetPoint("BOTTOMRIGHT", bank, "BOTTOMRIGHT", -10, 10)
	ReagentBankFrameText:SetJustifyH("RIGHT")
	ReagentBankFrameText:SetJustifyV("BOTTOM")
	
	local deposit = ReagentBankFrame:GetChildren()
	deposit:SetAllPoints(ReagentBankFrameText)
	strip_textures(deposit, true)

	if (show) then
		bank:SetID(REAGENTBANK_CONTAINER)
	end
end

local function set_backpack()
	local num_rows, last_row_first_item, num_items, last_item = 0, nil, 0, nil
		
	for bag = 1, (NUM_BAG_SLOTS + 1) do
		local slots = GetContainerNumSlots(bag - 1)

		skin_colors(slots, "ContainerFrame"..bag.."Item", bag)

		for index = slots, 1, -1 do
			local item = _G["ContainerFrame"..bag.."Item"..index]
			item:ClearAllPoints()
			item:SetWidth(config.size)
			item:SetHeight(config.size)

			if (not last_item) then
				item:SetPoint("TOPLEFT", backpack, "TOPLEFT", 10, -50)
				last_row_first_item = item
				num_items = num_items + 1
			elseif num_items == config.bpr then
				item:SetPoint("TOPLEFT", last_row_first_item, "BOTTOMLEFT", 0, -config.spacing)
				last_row_first_item = item
				num_rows = num_rows + 1
				num_items = 1
			else
				item:SetPoint("TOPLEFT", last_item, "TOPRIGHT", config.spacing, 0)
				num_items = num_items + 1
			end
			last_item = item
		end
	end
	backpack:SetHeight(((config.size + config.spacing) * (num_rows + 1) + 100) - config.spacing)
	
	ContainerFrame1MoneyFrameCopperButton:SetPoint("RIGHT", ContainerFrame1MoneyFrame, "RIGHT", 0, 0)
end

function BankFrame_ShowPanel(sidePanelName, selection)
	local tabIndex;
	
	ShowUIPanel(BankFrame);
	for index, data in pairs(BANK_PANELS) do
		local panel = _G[data.name];

		if data.name == sidePanelName then
			panel:Show()
			tabIndex = index;
			BankFrame.activeTabIndex = tabIndex;
			
			if data.name == "ReagentBankFrame" then
				set_reagents(true)
				set_bank(false)
			else
				set_bank(true)
			end
		else
			panel:Hide()
		end
	end
end

function ContainerFrame_GenerateFrame(frame, size, id)
	frame.size = size
	for i = 1, size do
		local index = size - i + 1
	 	local item_button = _G[frame:GetName().."Item"..i]
		item_button:SetID(index)
		item_button:Show()
	end
	frame:SetID(id)
	frame:Show()
	
	if (id == 0) then
		set_backpack()
	end

	local frame = _G['ContainerFrame'..id+1]
	frame:SetFrameStrata("HIGH")
	frame:SetFrameLevel(3)
	frame:EnableMouse(false)
end

ContainerFrame1Item1:HookScript("OnShow", function() backpack:Show() end)
ContainerFrame1Item1:HookScript("OnHide", function() backpack:Hide() end)
BankFrame:HookScript("OnShow", function() OpenAllBags() end)
BankFrame:HookScript("OnHide", function() CloseAllBags() end)
GameMenuFrame:HookScript("OnShow", function() CloseAllBags() end)

function UpdateContainerFrameAnchors() end
function ToggleBag() ToggleAllBags() end
function ToggleBackpack() ToggleAllBags() end

local open = false

function OpenAllBags()
	open = true
	for i = 0, NUM_BAG_FRAMES do
		OpenBag(i)
	end
	if BankFrame:IsShown() then
		backpack:Show()
		bank:Show()
		for i = 0, NUM_CONTAINER_FRAMES do
			OpenBag(i)
		end
	end
end

function CloseAllBags()
	open = false
	for i = 0, NUM_CONTAINER_FRAMES do
		CloseBag(i)
	end
	backpack:Hide()
	bank:Hide()
	CloseBankFrame()
end

function OpenBackpack()
	OpenAllBags()
end

function CloseBackpack()
	CloseAllBags()
end

function ToggleAllBags()
	if open then
		CloseAllBags()
	else
		OpenAllBags()
	end
end
