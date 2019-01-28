local addon, ns = ...
local cfg = ns.cfg
local lib = ns.lib
local CityUi = CityUi

MainMenuBar:EnableMouse(false)

MainMenuBarArtFrameBackground:Hide()
MainMenuBarArtFrame.LeftEndCap:Hide()
MainMenuBarArtFrame.RightEndCap:Hide()
MainMenuBarArtFrame.PageNumber:Hide()
StatusTrackingBarManager:Hide()
ActionBarUpButton:Hide()
ActionBarDownButton:Hide()
MicroButtonAndBagsBar.MicroBagBar:Hide()

ExtraActionBarFrame:SetParent(UIParent)
ExtraActionBarFrame:ClearAllPoints()
ExtraActionBarFrame:SetPoint(unpack(cfg.bars.extra.pos))
ExtraActionBarFrame.ignoreFramePositionManager = true
ExtraActionBarFrame:SetAttribute("ignoreFramePositionManager", true)

ZoneAbilityFrame:SetParent(UIParent)
ZoneAbilityFrame:ClearAllPoints()
ZoneAbilityFrame:SetPoint(unpack(cfg.bars.zone.pos))
ZoneAbilityFrame.ignoreFramePositionManager = true
ZoneAbilityFrame:SetAttribute("ignoreFramePositionManager", true)

do
	local num = NUM_POSSESS_SLOTS
	local bar_cfg = cfg.bars.possess
	PossessBackground1:SetTexture("")
	PossessBackground2:SetTexture("")
	PossessBarFrame.ignoreFramePositionManager = true
	PossessBarFrame:SetAttribute("ignoreFramePositionManager", true);
	PossessBarFrame:ClearAllPoints()
	PossessBarFrame:SetPoint(unpack(bar_cfg.pos))
	PossessBarFrame:SetWidth((bar_cfg.buttons.size + bar_cfg.buttons.margin) * num - bar_cfg.buttons.margin)
	PossessBarFrame:SetHeight(bar_cfg.buttons.size)
	PossessBarFrame:SetScale(1 / cfg.bars.main.scale)
	
	for i = 1, num do
		local button = _G["PossessButton"..i]
		lib.style_stance(button)
		button:ClearAllPoints()
		button:SetSize(bar_cfg.buttons.size, bar_cfg.buttons.size)
		if i == 1 then
			button:SetPoint("TOPLEFT", PossessBarFrame)
		else
			button:SetPoint("TOPLEFT", _G["PossessButton"..(i - 1)], "TOPRIGHT", bar_cfg.buttons.margin, 0)
		end
	end
end

do
	local num = NUM_PET_ACTION_SLOTS
	local bar_cfg = cfg.bars.pet
	local per_row = num / bar_cfg.rows

	for i = 1, num do
		local button = _G["PetActionButton"..i]
		lib.style_pet(button)
		button:ClearAllPoints()
		button:SetSize(bar_cfg.buttons.size, bar_cfg.buttons.size)

		if i == 1 then
			button:SetPoint(unpack(bar_cfg.pos))
		elseif i % per_row == 1 then
			button:SetPoint("BOTTOMLEFT", _G["PetActionButton"..(i - per_row)], "TOPLEFT", 0, bar_cfg.buttons.margin)
		else
			button:SetPoint("TOPLEFT", _G["PetActionButton"..(i - 1)], "TOPRIGHT", bar_cfg.buttons.margin, 0)
		end
	end
end

do
	local num = NUM_STANCE_SLOTS
	local bar_cfg = cfg.bars.stance
	StanceBarFrame.ignoreFramePositionManager = true
	StanceBarFrame:SetAttribute("ignoreFramePositionManager", true);
	StanceBarFrame:ClearAllPoints()
	StanceBarFrame:SetPoint(unpack(bar_cfg.pos))
	StanceBarFrame:SetWidth((bar_cfg.buttons.size + bar_cfg.buttons.margin) * num - bar_cfg.buttons.margin)
	StanceBarFrame:SetHeight(bar_cfg.buttons.size)
	StanceBarFrame:SetScale(1 / cfg.bars.main.scale)

	for i = 1, num do
		local button = _G["StanceButton"..i]
		lib.style_stance(button)
		button:ClearAllPoints()
		button:SetSize(bar_cfg.buttons.size, bar_cfg.buttons.size)
		if i == 1 then
		button:SetPoint("TOPLEFT", StanceBarFrame)
		else
			button:SetPoint("TOPLEFT", _G["StanceButton"..(i - 1)], "TOPRIGHT", bar_cfg.buttons.margin, 0)
		end
	end
end

do
	local bags = {
		MainMenuBarBackpackButton,
		CharacterBag0Slot,
		CharacterBag1Slot,
		CharacterBag2Slot,
		CharacterBag3Slot
	}
	
	MainMenuBarBackpackButton:ClearAllPoints();
	MainMenuBarBackpackButton:SetPoint(unpack(cfg.bars.bag.pos))
	
	local prev = nil
	for _, button in pairs(bags) do
		if (prev) then
			button:ClearAllPoints();
			button:SetPoint("BOTTOMLEFT", prev, "BOTTOMRIGHT", 2, 0)
		end
		prev = button
		button:SetScale(1 / cfg.bars.main.scale)
		lib.style_bag(button)
	end
	
	MainMenuBarBackpackButtonCount:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
	MainMenuBarBackpackButtonCount:SetDrawLayer("OVERLAY", 7)
	MainMenuBarBackpackButtonCount:SetPoint("BOTTOMRIGHT")
end

do
	MultiBarBottomLeft:SetScale(1 / cfg.bars.main.scale)
	MultiBarBottomRight:SetScale(1 / cfg.bars.main.scale)
	MultiBarRight:SetScale(1 / cfg.bars.main.scale)
	MultiBarLeft:SetScale(1 / cfg.bars.main.scale)
	ActionButton1:SetScale(1 / cfg.bars.main.scale)

	local num = NUM_ACTIONBAR_BUTTONS
	local bars = {
		"ActionButton",
		"MultiBarBottomLeftButton",
		"MultiBarBottomRightButton",
		"MultiBarLeftButton",
		"MultiBarRightButton",
	}

	for _, name in ipairs(bars) do
		local bar_cfg = cfg.bars[name]
		local per_row = num / bar_cfg.rows

		local frame = CreateFrame("Frame", "City"..name, UIParent)
		frame:SetPoint(unpack(bar_cfg.pos))
		frame:SetWidth((bar_cfg.buttons.size + bar_cfg.buttons.margin) * per_row - bar_cfg.buttons.margin)
		frame:SetHeight((bar_cfg.buttons.size + bar_cfg.buttons.margin) * bar_cfg.rows - bar_cfg.buttons.margin)

		for i = 1, num do
			local button = _G[name..i]

			if name == "ActionButton" then
				button:SetScale(1 / cfg.bars.main.scale)
			end
			
			button.short = bar_cfg.short
			button:ClearAllPoints()
			button:SetSize(bar_cfg.buttons.size, bar_cfg.buttons.size * (button.short and (2 / 3) or 1))
			
			if i == 1 then
				button:SetPoint("TOPLEFT", frame)
			elseif i % per_row == 1 then
				button:SetPoint("TOPLEFT", _G[name..(i - per_row)], "BOTTOMLEFT", 0, -bar_cfg.buttons.margin)
			else
				button:SetPoint("TOPLEFT", _G[name..(i - 1)], "TOPRIGHT", bar_cfg.buttons.margin, 0)
			end
			
			lib.style_action(button)

			if bar_cfg.limit and i > bar_cfg.limit then
				button.oldShow = button.Show
				button.Show = function(self)
					self:Hide()
				end
			end
		end
	end
end

local old_ActionButton_SetTooltip = ActionButton_SetTooltip;

ActionButton_SetTooltip = function(self)
	old_ActionButton_SetTooltip(self)

	local button_type = self.buttonType
	local action = self.action
	local id

	if ( not button_type ) then
        button_type = "ACTIONBUTTON";
		id = self:GetID();
	else
		if ( button_type == "MULTICASTACTIONBUTTON" ) then
			id = self.buttonIndex;
		else
			id = self:GetID();
		end
	end

	local name = GetActionText(action)
	
	local key1, key2 = GetBindingKey(button_type..id)
	local key = key2 or key1
	local bind = GetBindingText(key, 1)

	if (name and not (name == "") or bind and not (bind == "")) then
		GameTooltip:AddLine(" ")
		if (name and not (name == "")) then GameTooltip:AddLine(name, 1, 1, 1) end
		if (bind and not (bind == "")) then GameTooltip:AddLine(bind, 1, 1, 1) end
		GameTooltip:Show()
	end
end

hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', function(self, start, duration, modRate)
	if self:GetDebugName():find("ChargeCooldown") then
		self:SetHideCountdownNumbers(false)
		self:SetDrawEdge(false)
		self:SetFrameStrata("HIGH")
		self:GetRegions():SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_lrg, CityUi.config.font_flags)
		self:GetRegions():SetShadowOffset(0, 0)
	end
end)

SpellFlyoutBackgroundEnd:SetTexture("")
SpellFlyoutHorizontalBackground:SetTexture("")
SpellFlyoutVerticalBackground:SetTexture("")
SpellFlyout:HookScript("OnShow", function(self)
	for i = 1, 10 do
		lib.style_action(_G["SpellFlyoutButton"..i])
	end
end)
