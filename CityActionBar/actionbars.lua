local _, cab = ...
local cfg = cab.cfg
local lib = cab.lib
local cui = CityUi

do
	lib.hide_blizzard()

	local num = NUM_ACTIONBAR_BUTTONS
	local bars = {
		"MultiBarBottomLeft",
		"MultiBarBottomRight",
		"MultiBarLeft",
		"MultiBarRight",
	}

	do
		local name = "Action"
		local bar_cfg = cfg.bars[name]
		
		local bar = lib.create_bar(name, num, bar_cfg)
		lib.setup_bar(name, bar, num, bar_cfg, lib.style_action)
		for i = 1, num do
			local button = _G["ActionButton"..i]
			button:SetParent(bar)
			bar:SetFrameRef("ActionButton"..i, button)
		end

		bar:Execute(([[
			buttons = table.new()
			for i=1, %d do
				table.insert(buttons, self:GetFrameRef("%s"..i))
			end
		]]):format(num, "ActionButton"))

		bar:SetAttribute("_onstate-page", [[
			for i, button in next, buttons do
				button:SetAttribute("actionpage", newstate)
			end
		]])

		RegisterStateDriver(bar, "page", "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[overridebar]14;[shapeshift]13;[vehicleui]12;[possessbar]12;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1")

		bar:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
		bar:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
		bar:SetScript("OnEvent", function(self, event, unit, ...)
			for i = 1, num do
				local button = _G["ActionButton"..i]
				local action = button.action
				local icon = button.icon

				if action >= 120 then
					local texture = GetActionTexture(action)

					if (texture) then
						icon:SetTexture(texture)
						icon:Show()
					else
						if icon:IsShown() then
							icon:Hide()
						end
					end
				end
			end
		end)
	end

	for _, name in ipairs(bars) do
		local bar_cfg = cfg.bars[name]

		local bar = lib.create_bar(name, num, bar_cfg)
		_G[name]:SetParent(bar)
		_G[name]:EnableMouse(false)
		lib.setup_bar(name, bar, num, bar_cfg, lib.style_action)
	end
end

ExtraActionBarFrame:SetParent(UIParent)
ExtraActionBarFrame:ClearAllPoints()
ExtraActionBarFrame:SetPoint(unpack(cfg.bars.extra.pos))
ExtraActionBarFrame.ignoreFramePositionManager = true

ZoneAbilityFrame:SetParent(UIParent)
ZoneAbilityFrame:ClearAllPoints()
ZoneAbilityFrame:SetPoint(unpack(cfg.bars.zone.pos))
ZoneAbilityFrame.ignoreFramePositionManager = true

do
	-- can test possess bar with remote control toys
	local name = "Possess"
	local num = NUM_POSSESS_SLOTS
	local bar_cfg = cfg.bars[name]

	PossessBackground1:SetTexture("")
	PossessBackground2:SetTexture("")

	local bar = lib.create_bar(name, num, bar_cfg)
	PossessBarFrame:SetParent(bar)
	lib.setup_bar(name, bar, num, bar_cfg, lib.style_stance)
end

do
	local name = "PetAction"
	local num = NUM_PET_ACTION_SLOTS
	local bar_cfg = cfg.bars[name]
	local per_row = num / bar_cfg.rows

	local bar = lib.create_bar(name, num, bar_cfg)
	PetActionBarFrame:SetParent(bar)
	lib.setup_bar(name, bar, num, bar_cfg, lib.style_pet)
end

do
	local name = "Stance"
	local num = NUM_STANCE_SLOTS
	local bar_cfg = cfg.bars[name]

	local bar = lib.create_bar(name, num, bar_cfg)
	StanceBarFrame:SetParent(bar)
	lib.setup_bar(name, bar, num, bar_cfg, lib.style_stance)
end

do
	local name = "MicroMenu"
	local bar_cfg = cfg.bars[name]

	local buttons = {}
	for i, name in next, MICRO_BUTTONS do
		local button = _G[name]
		if button and button:IsShown() then
			table.insert(buttons, button)
		end
	end

	local bar = lib.create_bar(name, #buttons, bar_cfg)
	for i = 1, #buttons do
		buttons[i]:SetParent(bar)
	end
	lib.setup_bar(name, bar, #buttons, bar_cfg, lib.style_menu, buttons)

	GuildMicroButtonTabard:SetAllPoints(GuildMicroButton)
	GuildMicroButtonTabardEmblem:SetSize(bar_cfg.buttons.size * bar_cfg.buttons.width_scale / 2, bar_cfg.buttons.size / 2)
	GuildMicroButtonTabardBackground:SetAllPoints(GuildMicroButtonTabard)
	PetBattleFrame.BottomFrame.MicroButtonFrame:SetScript("OnShow", nil)
end

do
	local bags = {
		MainMenuBarBackpackButton,
		CharacterBag0Slot,
		CharacterBag1Slot,
		CharacterBag2Slot,
		CharacterBag3Slot,
	}

	local name = "Bag"
	local bar_cfg = cfg.bars[name]

	local bar = lib.create_bar(name, #bags, bar_cfg)
	for i = 1, #bags do
		bags[i]:SetParent(bar)
	end
	lib.setup_bar(name, bar, #bags, bar_cfg, lib.style_bag, bags)
	
	MainMenuBarBackpackButtonCount:SetFont(cui.config.default_font, cui.config.font_size_med, cui.config.font_flags)
	MainMenuBarBackpackButtonCount:SetDrawLayer("OVERLAY", 7)
	MainMenuBarBackpackButtonCount:SetPoint("BOTTOMRIGHT")
end

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

hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', function(self, start, duration, modRate)
	if self:GetDebugName():find("ChargeCooldown") then
		self:SetHideCountdownNumbers(false)
		self:SetDrawEdge(false)
		self:SetFrameStrata("HIGH")
		cui.util.fix_string(self:GetRegions(), cui.config.font_size_lrg)
	end
end)

hooksecurefunc('ActionButton_UpdateCooldown', function(self)
	if (self.chargeCooldown and self.chargeCooldown:IsShown()) then
		self.cooldown:GetRegions():SetAlpha(0)
	else
		self.cooldown:GetRegions():SetAlpha(1)
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
