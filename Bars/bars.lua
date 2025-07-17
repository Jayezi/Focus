local Local = {}
local _, addon = ...
if not addon.bars.enabled then return end

Local.addon = addon
Local.core = Local.addon.core
Local.cfg = Local.addon.bars.cfg
Local.styles = Local.addon.bars.styles

local CreateFrame = CreateFrame
local UIParent = UIParent
local GetActionText = GetActionText
local GetBindingKey = GetBindingKey
local GetBindingText = GetBindingText
local GameTooltip = GameTooltip
local MainMenuBarBackpackButton = MainMenuBarBackpackButton
local strfind = strfind
local InCombatLockdown = InCombatLockdown

local genBackdrop = Local.core.util.gen_backdrop
local setInside = Local.core.util.set_inside

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

local layoutActionBar = function(bar, cfg)

	if InCombatLockdown() then return end

	for i = 1, bar.numButtons do

		local button = bar.actionButtons[i]
		local container = button.container

		button:SetAllPoints()

		if bar_cfg.buttons.size then
			container:SetSize(bar_cfg.buttons.size, bar_cfg.buttons.height or bar_cfg.buttons.size)
		end

		if bar.numRows == 1 then
			container:ClearAllPoints()

			local padding = bar.buttonPadding
			if i <= bar.numButtons / 2 then
				container:SetPoint("BOTTOMLEFT", bar, "BOTTOM", -(bar_cfg.buttons.size + padding) * (bar.numButtons / 2 - i + 1) + padding / 2, 0)
			else
				container:SetPoint("BOTTOMRIGHT", bar, "BOTTOM", (bar_cfg.buttons.size + padding) * (i - bar.numButtons / 2) - padding / 2, 0)
			end
		end

		if bar.numRows == 2 then
			local cols = bar.numButtons / 2
			local row = i <= cols and 1 or 2
			local col = i > cols and i - cols or i

			container:ClearAllPoints()

			local padding = bar.buttonPadding
			if row == 1 then
				if col <= cols / 2 then
					container:SetPoint("BOTTOMLEFT", bar, "BOTTOM", -(bar_cfg.buttons.size + padding) * (cols / 2 - col + 1) + padding / 2, 0)
				else
					container:SetPoint("BOTTOMRIGHT", bar, "BOTTOM", (bar_cfg.buttons.size + padding) * (col - cols / 2) - padding / 2, 0)
				end
			else
				local height = bar_cfg.buttons.height or bar_cfg.buttons.size
				if col <= cols / 2 then
					container:SetPoint("BOTTOMLEFT", bar, "BOTTOM", -(bar_cfg.buttons.size + padding) * (cols / 2 - col + 1) + padding / 2, height + padding)
				else
					container:SetPoint("BOTTOMRIGHT", bar, "BOTTOM", (bar_cfg.buttons.size + padding) * (col - cols / 2) - padding / 2, height + padding)
				end
			end
		end
	end
end

local setupActionBars = function()

	local bars = {
		MainMenuBar,
		MultiBarBottomLeft,
		MultiBarBottomRight,
		MultiBarLeft,
		MultiBarRight,
		-- MultiBar5,
		-- MultiBar6,
		-- MultiBar7,
	}

	for _, bar in ipairs(bars) do
		local cfg = Local.cfg.bars[bar:GetName()]
	
		for i = 1, bar.numButtons do
			local button = bar.actionButtons[i]
			local container = button.container

			button:SetAllPoints()

			if not InCombatLockdown() then

				if cfg.buttons.size then
					container:SetSize(cfg.buttons.size, cfg.buttons.height or cfg.buttons.size)
				end

				if bar.numRows == 1 then
					container:ClearAllPoints()

					local padding = bar.buttonPadding
					if i <= bar.numButtons / 2 then
						container:SetPoint("BOTTOMLEFT", bar, "BOTTOM", -(cfg.buttons.size + padding) * (bar.numButtons / 2 - i + 1) + padding / 2, 0)
					else
						container:SetPoint("BOTTOMRIGHT", bar, "BOTTOM", (cfg.buttons.size + padding) * (i - bar.numButtons / 2) - padding / 2, 0)
					end
				end

				if bar.numRows == 2 then
					local cols = bar.numButtons / 2
					local row = i <= cols and 1 or 2
					local col = i > cols and i - cols or i

					container:ClearAllPoints()

					local padding = bar.buttonPadding
					if row == 1 then
						if col <= cols / 2 then
							container:SetPoint("BOTTOMLEFT", bar, "BOTTOM", -(cfg.buttons.size + padding) * (cols / 2 - col + 1) + padding / 2, 0)
						else
							container:SetPoint("BOTTOMRIGHT", bar, "BOTTOM", (cfg.buttons.size + padding) * (col - cols / 2) - padding / 2, 0)
						end
					else
						local height = cfg.buttons.height or cfg.buttons.size
						if col <= cols / 2 then
							container:SetPoint("BOTTOMLEFT", bar, "BOTTOM", -(cfg.buttons.size + padding) * (cols / 2 - col + 1) + padding / 2, height + padding)
						else
							container:SetPoint("BOTTOMRIGHT", bar, "BOTTOM", (cfg.buttons.size + padding) * (col - cols / 2) - padding / 2, height + padding)
						end
					end
				end
			end

			if button.styled then return end
			button.styled = {}

			genBackdrop(button, unpack(Local.core.config.frame_background_transparent))
			Local.styles.ActionBarButtonTemplate(button, cfg)
		end

		-- for i = 1, NUM_ACTIONBAR_BUTTONS do
		-- 	hooksecurefunc(_G[name.."Button"..i], "SetTooltip", set_tooltip)
		-- end
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

	BagsBar:SetSize(BagsBar.initialWidth, BagsBar.initialHeight)
	BagBarExpandToggle:SetSize(BagsBar.bagBarExpandToggleInitialWidth, BagsBar.bagBarExpandToggleInitialHeight)

	MainMenuBarBackpackButton:ClearAllPoints()
	MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", BagsBar, "BOTTOMRIGHT", 0, 0)

	local expand = MainMenuBarBagManager:ShouldBarExpand();

	local left = 0
	local right = math.pi
	local rotation = expand and right or left;

	BagBarExpandToggle:GetNormalTexture():SetRotation(rotation);
	BagBarExpandToggle:GetPushedTexture():SetRotation(rotation);
	BagBarExpandToggle:GetHighlightTexture():SetRotation(rotation);

	BagBarExpandToggle:ClearAllPoints()
	BagBarExpandToggle:SetPoint("TOPRIGHT", MainMenuBarBackpackButton, "TOPLEFT")

	local prev = BagBarExpandToggle
	for _, bag in ipairs(bags) do
		styles.bagbutton(bag)
		bag:SetSize(bar_cfg.buttons.size, bar_cfg.buttons.size)

		if bag:IsShown() and bag ~= MainMenuBarBackpackButton then
			bag:ClearAllPoints()
			bag:SetPoint("TOPRIGHT", prev, "TOPLEFT", -2, 0)
			prev = bag
		end
	end
end

-- hooksecurefunc(BagsBar, "Layout", function()
-- 	setup_bagbar()
-- end)

-- EventRegistry:RegisterCallback("MainMenuBarManager.OnExpandChanged", function()
-- 	setup_bagbar()
-- end, BagsBar);

local setup_microbar = function()
	-- MicroButtonAndBagsBar:SetSize(290, 50)
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
		setupActionBars()
		--setup_microbar()
		-- setup_stancebar()
		-- setup_petbar()
		-- setup_possessbar()
		-- setup_bagbar()
	else
		if addon == "Blizzard_UIWidgets" then
			--place_widget()
		end
	end
end)

hooksecurefunc('ActionButton_UpdateCooldown', function(button)
	if (button.chargeCooldown and button.chargeCooldown:IsShown()) then
		button.cooldown:GetRegions():SetAlpha(0)
	else
		button.cooldown:GetRegions():SetAlpha(1)
	end
end)

hooksecurefunc('StartChargeCooldown', function(button, chargeStart, chargeDuration, chargeModRate)
	-- if self:IsForbidden() then return end
	setInside(button.chargeCooldown, button)
	Local.styles.CooldownFrameTemplate(button.chargeCooldown)

	button.chargeCooldown:SetHideCountdownNumbers(false)
	button.chargeCooldown:SetDrawEdge(false)
end)

--SpellFlyout.Background:Hide()

-- SpellFlyout:HookScript("OnShow", function(self)
-- 	local b = 1
-- 	local button = _G["SpellFlyoutButton"..b]
-- 	while button do
-- 		if not button.styled then
-- 			styles.actionbutton(button)
-- 			button.styled = true
-- 		end
-- 		b = b + 1
-- 		button = _G["SpellFlyoutButton"..b]
-- 	end
-- end)

-- hooksecurefunc("ActionButton_SetupOverlayGlow", function(button)
-- 	Local.styles.ActionBarButtonSpellActivationAlert(button.SpellActivationAlert)
-- end)
