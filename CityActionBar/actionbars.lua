local addon, ns = ...
local cfg = ns.cfg
local lib = ns.lib
local CityUi = CityUi

MainMenuBar:ClearAllPoints()
MainMenuBar:SetPoint(unpack(cfg.bars.main.pos))
MainMenuBar:SetScale(cfg.bars.main.scale)

ExtraActionBarFrame:SetParent(UIParent)
ExtraActionBarFrame:ClearAllPoints()
ExtraActionBarFrame:SetPoint(unpack(cfg.bars.extra.pos))
ExtraActionBarFrame.ignoreFramePositionManager = true
ExtraActionBarFrame:SetAttribute("ignoreFramePositionManager", true);

ZoneAbilityFrame:SetParent(UIParent)
ZoneAbilityFrame:ClearAllPoints()
ZoneAbilityFrame:SetPoint(unpack(cfg.bars.zone.pos))
ZoneAbilityFrame.ignoreFramePositionManager = true
ZoneAbilityFrame:SetAttribute("ignoreFramePositionManager", true);

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
	PetActionBarFrame.ignoreFramePositionManager = true
	PetActionBarFrame:SetAttribute("ignoreFramePositionManager", true);
	PetActionBarFrame.oldSetPoint = PetActionBarFrame.SetPoint
	PetActionBarFrame.is_set = false
	PetActionBarFrame.SetPoint = function(self, ...)
		if not self.is_set then
			self:oldSetPoint(unpack(bar_cfg.pos))
			self.is_set = true
		end
	end

	PetActionBarFrame:SetParent(UIParent)
	PetActionBarFrame:ClearAllPoints()
	PetActionBarFrame:SetPoint(unpack(bar_cfg.pos))
	PetActionBarFrame:SetWidth((bar_cfg.buttons.size + bar_cfg.buttons.margin) * num - bar_cfg.buttons.margin)
	PetActionBarFrame:SetHeight(bar_cfg.buttons.size)

	for i = 1, num do
		local button = _G["PetActionButton"..i]
		lib.style_pet(button)
		button:ClearAllPoints()
		button:SetSize(bar_cfg.buttons.size, bar_cfg.buttons.size)
		if i == 1 then
			button:SetPoint("TOPLEFT", PetActionBarFrame)
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
			button:SetPoint("LEFT", prev, "RIGHT", 2, 0)
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
		"MultiBarRightButton",
		"MultiBarLeftButton"
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
			
			button:ClearAllPoints()
			button:SetSize(bar_cfg.buttons.size, bar_cfg.buttons.size)
			
			if i == 1 then
				button:SetPoint("TOPLEFT", frame)
			elseif i % per_row == 1 then
				button:SetPoint("TOPLEFT", _G[name..(i - per_row)], "BOTTOMLEFT", 0, -bar_cfg.buttons.margin)
			else
				button:SetPoint("TOPLEFT", _G[name..(i - 1)], "TOPRIGHT", bar_cfg.buttons.margin, 0)
			end
			
			lib.style_action(button)
		end
	end
end

hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', function(self, start, duration)
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
