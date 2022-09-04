local _, addon = ...
if not addon.units.enabled then return end
local core = addon.core
local cfg = addon.units.cfg

local lib = {}
addon.units.lib = lib

local UnitFrame_OnEnter = UnitFrame_OnEnter
local UnitFrame_OnLeave = UnitFrame_OnLeave
local CreateFrame = CreateFrame
local Round = Round

lib.invert_color = function(self)
	self:SetBackdropColor(self:GetStatusBarColor())
	self:SetStatusBarColor(unpack(core.config.frame_background))
end

lib.push_bar = function(base, bar)
	if base.stack_height then
		bar:SetPoint("TOPLEFT", base, "TOPLEFT", 0, 1 - base.stack_height)
		base.stack_height = base.stack_height + bar:GetHeight() - 1
	else
		bar:SetPoint("TOPLEFT", base, "TOPLEFT", 0, 0)
		base.stack_height = bar:GetHeight()
	end	
end

lib.enable_mouse = function(base)
	base:RegisterForClicks("AnyUp")
	base:SetScript("OnEnter", UnitFrame_OnEnter)
	base:SetScript("OnLeave", UnitFrame_OnLeave)
end

-- TODO config for colors
lib.gen_heal_bar = function(health)
	
	local my_heals = CreateFrame("StatusBar", nil, health)
	my_heals:SetStatusBarTexture(core.media.textures.blank)
	my_heals:SetPoint("LEFT", health:GetStatusBarTexture(), "RIGHT", 0, 0)
	my_heals:SetPoint("TOP", 0, -1)
	my_heals:SetPoint("BOTTOM", 0, 1)
	my_heals:SetWidth(health:GetWidth() - 2)
	my_heals:SetStatusBarColor(0.25, 0.75, 0.25, 0.75)
	my_heals:SetFrameLevel(health:GetFrameLevel())
	
	local other_heals = CreateFrame("StatusBar", nil, health)
	other_heals:SetStatusBarTexture(core.media.textures.blank)
	other_heals:SetPoint("LEFT", my_heals:GetStatusBarTexture(), "RIGHT")
	other_heals:SetPoint("TOP", 0, -1)
	other_heals:SetPoint("BOTTOM", 0 ,1)
	other_heals:SetWidth(health:GetWidth() - 2)
	other_heals:SetStatusBarColor(0.25, 0.75, 0.25, 0.75)
	other_heals:SetFrameLevel(health:GetFrameLevel())
	
	local absorbs = CreateFrame("StatusBar", nil, health)
	absorbs:SetStatusBarTexture(core.media.textures.blank)
	absorbs:SetPoint("LEFT", health, "LEFT", 1, 0)
	absorbs:SetPoint("TOP", 0, -1)
	absorbs:SetPoint("BOTTOM", 0, 1)
	absorbs:SetWidth(health:GetWidth() - 2)
	absorbs:SetStatusBarColor(0.75, 0.75, 0.5, 0.25)
	absorbs:SetFrameLevel(health:GetFrameLevel())
	
	local heal_absorbs = CreateFrame("StatusBar", nil, health)
	heal_absorbs:SetReverseFill(true)
	heal_absorbs:SetStatusBarTexture(core.media.textures.blank)
	heal_absorbs:SetPoint("RIGHT", health, "RIGHT", -1, 0)
	heal_absorbs:SetPoint("TOP", 0, -1)
	heal_absorbs:SetPoint("BOTTOM", 0, 1)
	heal_absorbs:SetWidth(health:GetWidth() - 2)
	heal_absorbs:SetStatusBarColor(0.25, 0.25, 0.25, 0.75)
	heal_absorbs:SetFrameLevel(health:GetFrameLevel())
	
	return {
		myBar = my_heals,
		otherBar = other_heals,
		absorbBar = absorbs,
		healAbsorbBar = heal_absorbs,
		maxOverflow = 1,
	}
end

lib.gen_cast_bar = function(base, w, h, text_size, latency, interrupt, color)

	local cast_bar = core.util.gen_statusbar(base, w, h, core.config.frame_background, core.config.frame_background_light)
	
	if latency then
		cast_bar.SafeZone = cast_bar:CreateTexture(nil, "OVERLAY", nil, -8)
		cast_bar.SafeZone:SetTexture(core.media.textures.blank)
		cast_bar.SafeZone:SetVertexColor(1, 0, 0, 0.3)
	end
	
	local cast_icon = cast_bar:CreateTexture()
	cast_icon:SetDrawLayer("OVERLAY", -6)
	cast_icon:SetSize(Round(h * 3 / 2), Round(h * 3 / 4))
	cast_icon:SetPoint("CENTER", cast_bar, "TOP", 0, 0)
	cast_icon:SetTexCoord(0.1, 0.9, 0.30, 0.70)
	cast_bar.Icon = cast_icon
	
    cast_icon.border = cast_bar:CreateTexture()
	cast_icon.border:SetDrawLayer("OVERLAY", -7)
	core.util.set_outside(cast_icon.border, cast_icon)
	cast_icon.border:SetTexture(core.media.textures.blank)
	cast_icon.border:SetVertexColor(unpack(core.config.frame_border))
	
	local text_color = color or {.9, .9, .9}

	local cast_max = core.util.gen_string(cast_bar, text_size, nil, nil, "RIGHT", "BOTTOM")
	cast_max:SetTextColor(unpack(text_color))
	cast_max:SetPoint("BOTTOMRIGHT", 0, 2)
	cast_bar.Max = cast_max
	
	local cast_time = core.util.gen_string(cast_bar, text_size, nil, nil, "LEFT", "BOTTOM")
	cast_time:SetTextColor(unpack(text_color))
	cast_time:SetPoint("BOTTOMLEFT", 3, 2)
	cast_bar.Time = cast_time
	cast_bar.CustomTimeText = function(self, duration)
	    self.Time:SetText(("%.1f"):format(self.channeling and duration or self.max - duration))
	    self.Max:SetText(("%.2f"):format(self.max))
    end
	
	local cast_name = core.util.gen_string(cast_bar, text_size, nil, nil, "CENTER", "BOTTOM")
	cast_name:SetWordWrap(false)
	cast_name:SetTextColor(unpack(text_color))
	cast_name:SetPoint("BOTTOMLEFT", h, 2)
	cast_name:SetPoint("BOTTOMRIGHT", -h, 2)
	cast_bar.Text = cast_name

	if interrupt then
		cast_bar.PostCastStart = function(self, ...)
			if (self.notInterruptible) then
				self:SetBackdropColor(unpack(cfg.cast_non_interrupt_color))
			else
				self:SetBackdropColor(unpack(cfg.cast_interrupt_color))
			end
		end
		
		cast_bar.PostCastInterruptible = function(self, ...)
			if self.notInterruptible then
				self:SetBackdropColor(unpack(cfg.cast_non_interrupt_color))
			else
				self:SetBackdropColor(unpack(cfg.cast_interrupt_color))
			end
		end
		
		-- cast_bar.PostChannelUpdate = function(self, ...)
		-- 	if (self.notInterruptible) then
		-- 		self:SetBackdropColor(unpack(cfg.cast_non_interrupt_color))
		-- 	else
		-- 		self:SetBackdropColor(unpack(cfg.cast_interrupt_color))
		-- 	end
		-- end
	end

	base.Castbar = cast_bar

	return cast_bar
end

lib.gen_nameplate_cast_bar = function(base, w, h, icon_h, text_size)

    local cast_bar = core.util.gen_statusbar(base, w, h)

    local cast_icon = cast_bar:CreateTexture()
	cast_icon:SetDrawLayer("OVERLAY", -6)
	cast_icon:SetSize(icon_h, icon_h)
	cast_icon:SetPoint("BOTTOMRIGHT", cast_bar, "BOTTOMLEFT", 0, 1)
	cast_icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	cast_bar.Icon = cast_icon
	
    cast_icon.border = cast_bar:CreateTexture()
	cast_icon.border:SetDrawLayer("OVERLAY", -7)
	core.util.set_outside(cast_icon.border, cast_icon)
	cast_icon.border:SetTexture(core.media.textures.blank)
	cast_icon.border:SetVertexColor(unpack(core.config.frame_border))
	
	local cast_name = core.util.gen_string(cast_bar, text_size, nil, nil, "LEFT", "TOP")
	cast_name:SetWordWrap(false)
	cast_name:SetTextColor(unpack(core.config.frame_background))
	cast_name:SetPoint("TOPLEFT", cast_bar, "BOTTOMLEFT")
	cast_bar.Text = cast_name
	
	cast_bar.PostCastStart = function(self, ...)
		if (self.notInterruptible) then
			cast_bar:SetStatusBarColor(unpack(cfg.cast_non_interrupt_color))
			cast_name:SetTextColor(unpack(cfg.cast_non_interrupt_color))
		else
			cast_bar:SetStatusBarColor(unpack(cfg.cast_interrupt_color))
			cast_name:SetTextColor(unpack(cfg.cast_interrupt_color))
		end
	end
	
	cast_bar.PostCastInterruptible = function(self, ...)
		if (self.notInterruptible) then
			cast_bar:SetStatusBarColor(unpack(cfg.cast_non_interrupt_color))
			cast_name:SetTextColor(unpack(cfg.cast_non_interrupt_color))
		else
			cast_bar:SetStatusBarColor(unpack(cfg.cast_interrupt_color))
			cast_name:SetTextColor(unpack(cfg.cast_interrupt_color))
		end
	end
	
	-- cast_bar.PostChannelUpdate = function(self, ...)
	-- 	if (self.notInterruptible) then
	-- 		cast_bar:SetStatusBarColor(unpack(cfg.cast_non_interrupt_color))
	-- 		cast_name:SetTextColor(unpack(cfg.cast_non_interrupt_color))
	-- 	else
	-- 		cast_bar:SetStatusBarColor(unpack(cfg.cast_interrupt_color))
	-- 		cast_name:SetTextColor(unpack(cfg.cast_interrupt_color))
	-- 	end
	-- end

	return cast_bar
end

lib.gen_classpower = function(base, w, h)

	local max = 10

	local classpower = CreateFrame("Frame", nil, base)
	classpower:SetSize(w, h)
	
	local icon_w = w / max
	
	for i = 1, max do
	
		local icon = core.util.gen_statusbar(classpower, icon_w, h)
		
		if i == 1 then
			icon:SetPoint("TOPLEFT")
		else
			icon:SetPoint("TOPLEFT", classpower[i - 1], "TOPRIGHT", -1, 0)
		end

        classpower[i] = icon
	end
	
	classpower.PostUpdate = function(classpower, _, max, max_changed)
		if max_changed then
			local icon_w = classpower:GetWidth() / max
		
			for i = 1, max do
				local icon = classpower[i]
				icon:SetSize(icon_w, classpower:GetHeight())
			end
		end
	end
	base.ClassPower = classpower

    return classpower
end

lib.gen_rune_bar = function(base, w, h)
	
    local max = 6

	local runes = CreateFrame("Frame", nil, base)
	runes:SetSize(w, h)
	
	local rune_w = (w - max - 1) / max
	
	for i = 1, max do
        local rune = core.util.gen_statusbar(runes, rune_w, h)
		rune:SetStatusBarTexture(core.media.textures.blank)
		
		runes[i] = rune
	
		if i == 1 then
			rune:SetPoint("TOPLEFT")
		else
			rune:SetPoint("TOPLEFT", runes[i - 1], "TOPRIGHT", 1, 0)
		end
	end
	
	base.Runes = runes
	
	return runes
end

lib.gen_resource_bar = function(class, base, w, h)
	local class_resources = {
		["DEATHKNIGHT"] = lib.gen_rune_bar,
		["PALADIN"] = lib.gen_classpower,
		["ROGUE"] = lib.gen_classpower,
		["MONK"] = lib.gen_classpower,
		["DRUID"] = lib.gen_classpower,
	}
	local gen = class_resources[class]
	if gen then
		return gen(base, w, h)
	else
		return nil
	end
end

-- [1] = spellId, [2] = color, [3] = "state/cd/count", [4] = castByPlayer, [5] = size
local gen_indicator = function(cfg, parent, h_justify, v_justify, x_offset, y_offset)

	local indicator = CreateFrame("Frame", nil, parent)
	indicator:SetPoint(v_justify..h_justify, parent, h_justify, x_offset, y_offset)
	indicator.spellID = cfg[1]
	indicator:SetSize(cfg[5], cfg[5])

	if not cfg[4] then
		indicator.anyUnit = true
	end

	if cfg[3] == "state" then
		core.util.gen_backdrop(indicator, unpack(cfg[2]))
	elseif cfg[3] == "cd" then
		local cd = CreateFrame("Cooldown", nil, indicator)
		cd:SetAllPoints(indicator)
		cd:SetHideCountdownNumbers(false)
		core.util.fix_string(cd:GetRegions(), cfg[5])
		cd:GetRegions():SetTextColor(unpack(cfg[2]))
		cd:GetRegions():SetJustifyH(h_justify)
		cd:GetRegions():SetJustifyV(v_justify)
		cd:GetRegions():SetPoint(v_justify..h_justify, indicator, v_justify..h_justify, 1, 0)
		indicator.cd = cd
	elseif cfg[3] == "count" then
		local count = core.util.gen_string(indicator, cfg[5], nil, nil, h_justify, v_justify)
		count:SetAllPoints(indicator)
		count:SetTextColor(unpack(cfg[2]))
		indicator.count = count
	end

	return indicator
end

lib.gen_indicators = function(base, cfg)

	if not cfg then return nil end

	local indicators = {}
	indicators.onlyShowPresent = true
	indicators.customIcons = true

	indicators.icons = {}

	if cfg.tl then
		indicators.icons["tl"] = gen_indicator(cfg.tl, base.Health, "LEFT", "BOTTOM", 1, 1)
	end

	if cfg.bl then
		indicators.icons["bl"] = gen_indicator(cfg.bl, base.Health, "LEFT", "TOP", 1, -1)
	end

	if cfg.tr then
		indicators.icons["tr"] = gen_indicator(cfg.tr, base.Health, "RIGHT", "BOTTOM", -1, 1)
	end

	if cfg.br then
		indicators.icons["br"] = gen_indicator(cfg.br, base.Health, "RIGHT", "TOP", -1, -1)
	end

	return indicators
end

lib.gen_ready_check = function(base)
	local ready = base.Health:CreateTexture(nil, 'OVERLAY')
	ready:SetSize(15, 15)
    ready:SetPoint('CENTER')

	base.ReadyCheckIndicator = ready
end

lib.gen_summon = function(base)
	local summon = base.Health:CreateTexture(nil, "OVERLAY")
	summon:SetSize(35, 35)
	summon:SetPoint("CENTER")

	base.SummonIndicator = summon
end

local aura_filter = function(element, _, _, _, _, _, debuffType, _, _, caster, _, _, spellID)
	if element.sources and not element.sources[caster] then
		return false
	end

	local spells = element.whitelist or element.blacklist

	if spells then
		local found = spells[spellID]
		if element.whitelist then
			return found
		else
			return not found
		end
	end

	return true
end

lib.apply_whitelist_to = function(element, spells, units)
	element.whitelist = spells
	element.sources = units
	element.CustomFilter = aura_filter
end

lib.apply_blacklist_to = function(element, spells, units)
	element.blacklist = spells
	element.sources = units
	element.CustomFilter = aura_filter
end

local post_create_aura = function(buffs, button)

	button.cd:SetReverse(true)
	button.cd:SetFrameLevel(button:GetFrameLevel())
	button.cd:SetHideCountdownNumbers(false)
	button.cd:SetDrawEdge(false)
	core.util.fix_string(button.cd:GetRegions(), buffs.cdsize)
	
	if buffs.squashed then
		button.icon:SetTexCoord(0.1, 0.9, 0.3, 0.7)
	else
		button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	core.util.set_inside(button.cd, button)
	core.util.set_inside(button.icon, button)

	local y, x = strsplit("_", buffs.cdposition)

	local timer = button.cd:GetRegions()
	timer:ClearAllPoints()

	if x then
		if x == "BEFORE" then
			timer:SetPoint("RIGHT", button, "LEFT")
		elseif x == "LEFT" then
			timer:SetPoint("LEFT", button, "LEFT")
		elseif x == "CENTER" then
			timer:SetPoint("CENTER", button, "CENTER")
		elseif x == "RIGHT" then
			timer:SetPoint("RIGHT", button, "RIGHT")
		elseif x == "AFTER" then
			timer:SetPoint("LEFT", button, "RIGHT")
		end
	end

	if y then
		if y == "ABOVE" then
			timer:SetPoint("BOTTOM", button, "TOP")
		elseif y == "TOP" then
			timer:SetPoint("TOP", button, "TOP")
		elseif y == "CENTER" then
			timer:SetPoint("CENTER", button, "CENTER")
		elseif y == "BOTTOM" then
			timer:SetPoint("BOTTOM", button, "BOTTOM")
		elseif y == "BELOW" then
			timer:SetPoint("TOP", button, "BOTTOM")
		end
	end
	
	button.overlay:SetDrawLayer("BACKGROUND")
	button.overlay:SetTexture(core.media.textures.blank)
	button.overlay:SetPoint("TOPLEFT")
    button.overlay:SetPoint("BOTTOMRIGHT")
	button.overlay:SetTexCoord(0, 1, 0, 1)

	button.overlay.oldHide = button.overlay.Hide
	button.overlay.Hide = function(self) self:SetVertexColor(0, 0, 0) end

	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	button.count:SetJustifyH("RIGHT")
	button.count:SetJustifyV("TOP")
	button.count:SetFont(core.config.default_font, buffs.countsize, core.config.font_flags)
end

local post_update_aura = function(self, unit, button, _, _, _, _, debuffType)
	
	button:SetMouseClickEnabled(false)
	if (not button.isDebuff or string.find(unit, "nameplate")) and debuffType == nil then
		button.overlay:Hide()
	end
	if button.isDebuff and unit == "target" then
		button.icon:SetDesaturated(not button.isPlayer)
	end
	if self.squashed then button:SetHeight(button:GetWidth() / 2) end
end

-- [1] = size, [2] = rows, [3] = anchor, [4] = x-direction, [5] = y-direction, [6] = rowlimit, [7] = countsize, [8] = cdsize, [9] = squashed
lib.gen_auras = function(base, w, cfg, name)

	local auras = CreateFrame("Frame", base:GetName()..name, base.Health)
	
	auras.size = cfg[1]
	auras.initialAnchor = cfg[3]
	auras["growth-x"] = cfg[4]
	auras["growth-y"] = cfg[5]
	auras.countsize = cfg[7]
	auras.cdsize = cfg[8]
	auras.cdposition = cfg[9]
	auras.squashed = cfg[10]
	auras.showType = true
	auras.spacing = 1

	local num_per_row = cfg[6] or math.ceil(w / auras.size)
	auras.num = cfg[2] * num_per_row
	
	local aura_h = auras.size
	if auras.squashed then
		aura_h = auras.size / 2
		auras["spacing-y"] = -aura_h + 1
	end
	auras:SetSize(num_per_row * (auras.size + 1) - 1, cfg[2] * (aura_h + 1) - 1)
	
	auras.PostCreateIcon = post_create_aura
	auras.PostUpdateIcon = post_update_aura

	return auras
end
