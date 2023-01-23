local _, addon = ...
if not addon.bars.enabled then return end
local core = addon.core
local cfg = addon.bars.cfg
local styles = addon.bars.styles

local CreateFrame = CreateFrame
local UIParent = UIParent
local GetActionText = GetActionText
local GetBindingKey = GetBindingKey
local GetBindingText = GetBindingText
local GameTooltip = GameTooltip
local MainMenuBarBackpackButton = MainMenuBarBackpackButton
local AUTOCAST_SHINE_TIMERS = AUTOCAST_SHINE_TIMERS
local AUTOCAST_SHINE_SPEEDS = AUTOCAST_SHINE_SPEEDS
local strfind = strfind
local InCombatLockdown = InCombatLockdown

local MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"GuildMicroButton",
	"LFDMicroButton",
	"EJMicroButton",
	"CollectionsMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton",
	"StoreMicroButton",
}

local set_tooltip = function(self)
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
		if (name and not (name == "") and bind and not (bind == "")) then
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(name, bind, 1, 0.5, 1, 0.5, 1, 1)
		else
			if (name and not (name == "")) then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(name, 1, 0.5, 1)
			end
			if (bind and not (bind == "")) then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(bind, 1, 0.5, 1)
			end
		end
		GameTooltip:Show()
	end
end

local setup_bar = function(name, num, bar_cfg, style_func, buttons)
	
	for i = 1, num do
		local button = buttons and buttons[i] or _G[name.."Button"..i]
		local parent = button:GetParent()

		if not InCombatLockdown() then

			if bar_cfg.buttons.size then
				button:SetSize(bar_cfg.buttons.size, bar_cfg.buttons.height or bar_cfg.buttons.size)
			end

			if parent.numRows == 1 then
				button:ClearAllPoints()

				local padding = parent.buttonPadding
				if i <= num / 2 then
					button:SetPoint("BOTTOMLEFT", parent, "BOTTOM", -(bar_cfg.buttons.size + padding) * (num / 2 - i + 1) + padding / 2, 0)
				else
					button:SetPoint("BOTTOMRIGHT", parent, "BOTTOM", (bar_cfg.buttons.size + padding) * (i - num / 2) - padding / 2, 0)
				end
			end
		end

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

		local parent = _G[name.."Button1"]:GetParent()

		setup_bar(name, NUM_ACTIONBAR_BUTTONS, bar_cfg, styles.actionbutton)

		for i = 1, NUM_ACTIONBAR_BUTTONS do
			hooksecurefunc(_G[name.."Button"..i], "SetTooltip", set_tooltip)
		end
	end

	--StatusTrackingBarManager:Hide()
	MainMenuBar:EnableMouse(false)
end

local setup_stancebar = function()
	local name = "Stance"
	local num = StanceBar.numButtons
	local bar_cfg = cfg.bars[name]
	
	hooksecurefunc(StanceBar, "UpdateGridLayout", function()
		setup_bar(name, num, bar_cfg, styles.actionbutton)
	end)
	setup_bar(name, num, bar_cfg, styles.actionbutton)
end

local setup_petbar = function()
	local name = "PetAction"
	local num = PetActionBar.numButtons
	local bar_cfg = cfg.bars[name]

	hooksecurefunc(PetActionBar, "UpdateGridLayout", function()
		setup_bar(name, num, bar_cfg, styles.actionbutton)
	end)
	setup_bar(name, num, bar_cfg, styles.actionbutton)
end

local setup_possessbar = function()
	-- can test possess bar with remote control toys
	local name = "Possess"
	local num = NUM_POSSESS_SLOTS
	local bar_cfg = cfg.bars[name]

	hooksecurefunc(PossessActionBar, "UpdateGridLayout", function()
		setup_bar(name, num, bar_cfg, styles.actionbutton)
	end)
	setup_bar(name, num, bar_cfg, styles.actionbutton)
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
		CharacterReagentBag0Slot
	}

	MainMenuBarBackpackButton:ClearAllPoints()
	MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", MicroButtonAndBagsBar, "BOTTOMLEFT", 0, 5)

	local prev
	for _, bag in ipairs(bags) do
		styles.bagbutton(bag)
		bag:SetSize(bar_cfg.buttons.size, bar_cfg.buttons.size)

		if prev and bag ~= CharacterBag0Slot then
			bag:SetPoint("RIGHT", prev, "LEFT", -2, 0)
		end
		prev = bag
	end
end

local setup_microbar = function()
	MicroButtonAndBagsBar:SetSize(290, 50)
	for _, name in ipairs(MICRO_BUTTONS) do
		local button = _G[name]
		styles.microbutton(button)
	end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	if event == "PLAYER_LOGIN" then
		setup_actionbars()
		setup_microbar()
		setup_stancebar()
		setup_petbar()
		setup_possessbar()
		setup_bagbar()
	else
		if addon == "Blizzard_UIWidgets" then
			place_widget()
		end
	end
end)

hooksecurefunc('CooldownFrame_Set', function(self)
	if self:IsForbidden() then return end
	
	if strfind(self:GetDebugName(), "ChargeCooldown") then
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

SpellFlyout.Background:Hide()

SpellFlyout:HookScript("OnShow", function(self)
	local b = 1
	local button = _G["SpellFlyoutButton"..b]
	while button do
		if not button.styled then
			styles.actionbutton(button)
			button.styled = true
		end
		b = b + 1
		button = _G["SpellFlyoutButton"..b]
	end
end)

-- adjust the vertical distance for squashed buttons

local autocast_shines = {}

hooksecurefunc('AutoCastShine_AutoCastStart', function(button, r, g, b)
	if autocast_shines[button] then
		return
	end

	autocast_shines[button] = true
end)

hooksecurefunc('AutoCastShine_AutoCastStop', function(button, r, g, b)
	autocast_shines[button] = nil
end)

hooksecurefunc('AutoCastShine_OnUpdate', function()
	for button, _ in pairs(autocast_shines) do
		local parent, distance = button, button:GetWidth()
		local height = button:GetHeight()

		if distance == height then
			return
		end

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
