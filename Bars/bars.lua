local _, addon = ...
if not addon.bars.enabled then return end
local core = addon.core
local cfg = addon.bars.cfg
local styles = addon.bars.styles

local create_bar = function(name, num, bar_cfg)

	local per_row = num / (bar_cfg.rows or 1)
	local bar = CreateFrame("Frame", "FocusBars"..name.."Bar", UIParent)

	if bar_cfg.buttons.size then
		bar:SetWidth((bar_cfg.buttons.size * (bar_cfg.buttons.width_scale or 1) + bar_cfg.buttons.margin) * per_row - bar_cfg.buttons.margin)
		bar:SetHeight(((bar_cfg.buttons.height or bar_cfg.buttons.size) + bar_cfg.buttons.margin) * (bar_cfg.rows or 1) - bar_cfg.buttons.margin)
	end

	local point = bar_cfg.pos
	if point[2] == "UIParent" then
		point = {core.util.to_tl_anchor(bar, point)}
	end
	if type(point[2]) == "string" then
		point[2] = _G[point[2]]
	end
	bar:SetPoint(unpack(point))

	return bar
end

local setup_bar = function(name, bar, num, bar_cfg, style_func, buttons)
	local cols = num / (bar_cfg.rows or 1)

	local col = 1
	for i = 1, num do
		local button = buttons and buttons[i] or _G[name.."Button"..i]

		if bar_cfg.buttons.size then
			button:SetSize(bar_cfg.buttons.size * (bar_cfg.buttons.width_scale or 1), bar_cfg.buttons.height or bar_cfg.buttons.size)
		end

		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("TOPLEFT", bar)
			button:SetAttribute("flyoutDirection", "LEFT");
		else
			if col == 1 then
				button:SetPoint("TOPLEFT", buttons and buttons[i - cols] or _G[name.."Button"..(i - cols)], "BOTTOMLEFT", 0, -bar_cfg.buttons.margin)
				button:SetAttribute("flyoutDirection", "LEFT");
			else
				button:SetPoint("TOPLEFT", buttons and buttons[i - 1] or _G[name.."Button"..(i - 1)], "TOPRIGHT", bar_cfg.buttons.margin, 0)
				if col == cols then
					button:SetAttribute("flyoutDirection", "RIGHT");
				else
					button:SetAttribute("flyoutDirection", "UP");
				end
			end
		end
		if col == cols then col = 0 end
		col = col + 1

		style_func(button, bar_cfg)
	end
end

local setup_actionbars = function()

	local bars = {
		"Action",
		"MultiBarBottomLeft",
		"MultiBarBottomRight",
		"MultiBarLeft",
		"MultiBarRight",
	}

	for _, name in ipairs(bars) do
		local bar_cfg = cfg.bars[name]

		local bar = create_bar(name, NUM_ACTIONBAR_BUTTONS, bar_cfg)
		setup_bar(name, bar, NUM_ACTIONBAR_BUTTONS, bar_cfg, styles.actionbutton)
	end

	MainMenuBarArtFrameBackground:Hide()
	MainMenuBarArtFrame.LeftEndCap:Hide()
	MainMenuBarArtFrame.RightEndCap:Hide()
	MainMenuBarArtFrame.PageNumber:Hide()
	StatusTrackingBarManager:Hide()
	ActionBarUpButton:Hide()
	ActionBarDownButton:Hide()
	MicroButtonAndBagsBar.MicroBagBar:Hide()
	MainMenuBar:EnableMouse(false)
end

local setup_stancebar = function()
	local name = "Stance"
	local num = NUM_STANCE_SLOTS
	local bar_cfg = cfg.bars[name]

	local bar = create_bar(name, num, bar_cfg)
	setup_bar(name, bar, num, bar_cfg, styles.actionbutton)

	for _, texture in ipairs({StanceBarFrame:GetRegions()}) do
		texture:SetTexture()
	end
	StanceBarFrame:EnableMouse(false)
end

local setup_petbar = function()
	local name = "PetAction"
	local num = NUM_PET_ACTION_SLOTS
	local bar_cfg = cfg.bars[name]

	local bar = create_bar(name, num, bar_cfg)
	setup_bar(name, bar, num, bar_cfg, styles.actionbutton)

	PetActionBarFrame:EnableMouse(false)
end

local setup_possessbar = function()
	-- can test possess bar with remote control toys
	local name = "Possess"
	local num = NUM_POSSESS_SLOTS
	local bar_cfg = cfg.bars[name]

	local bar = create_bar(name, num, bar_cfg)
	setup_bar(name, bar, num, bar_cfg, styles.actionbutton)

	PossessBackground1:SetTexture()
	PossessBackground2:SetTexture()
	PossessBarFrame:EnableMouse(false)
end

local setup_bagbar = function()
	local name = "Bag"
	local bar_cfg = cfg.bars.bag

	local bags = {
		MainMenuBarBackpackButton,
		CharacterBag0Slot,
		CharacterBag1Slot,
		CharacterBag2Slot,
		CharacterBag3Slot,
	}

	local bar = create_bar(name, #bags, bar_cfg)
	setup_bar(name, bar, #bags, bar_cfg, styles.bagbutton, bags)
end

local setup_microbar = function()
	for _, name in ipairs(MICRO_BUTTONS) do
		local button = _G[name]
		styles.microbutton(button)
	end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self, event)
	setup_actionbars()
	setup_microbar()
	setup_stancebar()
	setup_petbar()
	setup_possessbar()
	setup_bagbar()
end)

ExtraActionBarFrame:SetParent(UIParent)
ExtraActionBarFrame:ClearAllPoints()
ExtraActionBarFrame:SetPoint(unpack(cfg.bars.extra.pos))
ExtraActionBarFrame.ignoreFramePositionManager = true

ZoneAbilityFrame:SetParent(UIParent)
ZoneAbilityFrame:ClearAllPoints()
ZoneAbilityFrame:SetPoint(unpack(cfg.bars.zone.pos))
ZoneAbilityFrame.ignoreFramePositionManager = true

hooksecurefunc("ActionButton_SetTooltip", function(self)
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
end)

hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', function(self)
	if self:GetDebugName():find("ChargeCooldown") then
		self:SetHideCountdownNumbers(false)
		self:SetDrawEdge(false)
		self:SetFrameStrata("HIGH")
		core.util.fix_string(self:GetRegions(), core.config.font_size_lrg)
	end
end)

hooksecurefunc('ActionButton_UpdateCooldown', function(self)
	if (self.chargeCooldown and self.chargeCooldown:IsShown()) then
		self.cooldown:GetRegions():SetAlpha(0)
	else
		self.cooldown:GetRegions():SetAlpha(1)
	end
end)

SpellFlyoutBackgroundEnd:SetTexture()
SpellFlyoutHorizontalBackground:SetTexture()
SpellFlyoutVerticalBackground:SetTexture()
SpellFlyout:HookScript("OnShow", function(self)
	print("show")
	local flyout_buttons = {self:GetChildren()}
	for _, button in ipairs(flyout_buttons) do
		if button.styled ~= true then
			print("styling")
			styles.actionbutton(button)
			button.styled = true
		end
	end
end)

-- adjust the vertical distance for squashed buttons

local AUTOCAST_SHINES = {}

hooksecurefunc('AutoCastShine_AutoCastStart', function(button, r, g, b)
	if AUTOCAST_SHINES[button] then
		return
	end

	AUTOCAST_SHINES[button] = true
end)

hooksecurefunc('AutoCastShine_AutoCastStop', function(button, r, g, b)
	AUTOCAST_SHINES[button] = nil
end)

hooksecurefunc('AutoCastShine_OnUpdate', function()
	for button in next, AUTOCAST_SHINES do
		local parent, distance = button, button:GetWidth()
		local height = button:GetHeight()

		if distance == height then return end

		local mult = height / distance

		for i = 1, 4 do
			local timer = AUTOCAST_SHINE_TIMERS[i]
			local speed = AUTOCAST_SHINE_SPEEDS[i]

			if ( timer <= speed ) then
				local basePosition = timer / speed * distance
				button.sparkles[0 + i]:SetPoint("CENTER", parent, "TOPLEFT", basePosition, 0)
				button.sparkles[4 + i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePosition, 0)
				button.sparkles[8 + i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePosition * mult)
				button.sparkles[12 + i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePosition * mult)
			elseif ( timer <= speed * 2 ) then
				local basePosition = (timer-speed) / speed * distance
				button.sparkles[0 + i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePosition * mult)
				button.sparkles[4 + i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePosition * mult)
				button.sparkles[8 + i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePosition, 0)
				button.sparkles[12 + i]:SetPoint("CENTER", parent, "TOPLEFT", basePosition, 0)
			elseif ( timer <= speed * 3 ) then
				local basePosition = (timer-speed*2) / speed * distance
				button.sparkles[0 + i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePosition, 0)
				button.sparkles[4 + i]:SetPoint("CENTER", parent, "TOPLEFT", basePosition, 0)
				button.sparkles[8 + i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePosition * mult)
				button.sparkles[12 + i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePosition * mult)
			else
				local basePosition = (timer-speed * 3) / speed * distance
				button.sparkles[0 + i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePosition  * mult)
				button.sparkles[4 + i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePosition  * mult)
				button.sparkles[8 + i]:SetPoint("CENTER", parent, "TOPLEFT", basePosition, 0)
				button.sparkles[12 + i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePosition, 0)
			end
		end
	end
end)
