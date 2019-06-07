local addon, cuf = ...

local cfg = cuf.cfg
local lib = {}
cuf.lib = lib
local cui = CityUi

lib.invert_color = function(self)
	self:SetBackdropColor(self:GetStatusBarColor())
	self:SetStatusBarColor(unpack(cui.config.frame_background))
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
	my_heals:SetStatusBarTexture(cui.media.textures.blank)
	my_heals:SetPoint("LEFT", health:GetStatusBarTexture(), "RIGHT")
	my_heals:SetPoint("TOP")
	my_heals:SetPoint("BOTTOM")
	my_heals:SetWidth(health:GetWidth())
	my_heals:SetStatusBarColor(.25, .75, .50, .75)
	my_heals:SetFrameLevel(health:GetFrameLevel())
	
	local other_heals = CreateFrame("StatusBar", nil, health)
	other_heals:SetStatusBarTexture(cui.media.textures.blank)
	other_heals:SetPoint("LEFT", my_heals:GetStatusBarTexture(), "RIGHT")
	other_heals:SetPoint("TOP")
	other_heals:SetPoint("BOTTOM")
	other_heals:SetWidth(health:GetWidth())
	other_heals:SetStatusBarColor(.75, .75, .25, .75)
	other_heals:SetFrameLevel(health:GetFrameLevel())
	
	local absorbs = CreateFrame("StatusBar", nil, health)
	absorbs:SetStatusBarTexture(cui.media.textures.blank)
	absorbs:SetPoint("LEFT", other_heals:GetStatusBarTexture(), "RIGHT")
	absorbs:SetPoint("TOP")
	absorbs:SetPoint("BOTTOM")
	absorbs:SetWidth(health:GetWidth())
	absorbs:SetStatusBarColor(.75, .75, .75, .75)
	absorbs:SetFrameLevel(health:GetFrameLevel())
	
	-- local heal_absorbs = CreateFrame("StatusBar", nil, health)
	-- heal_absorbs:SetStatusBarTexture(cui.media.textures.blank)
	-- heal_absorbs:SetPoint("LEFT", absorbs:GetStatusBarTexture(), "RIGHT")
	-- heal_absorbs:SetPoint("TOP")
	-- heal_absorbs:SetPoint("BOTTOM")
	-- heal_absorbs:SetWidth(health:GetWidth())
	-- heal_absorbs:SetStatusBarColor(.25, .25, .25, .75)
	-- heal_absorbs:SetFrameLevel(health:GetFrameLevel())
	
	return {
		myBar = my_heals,
		otherBar = other_heals,
		absorbBar = absorbs,
		--healAbsorbBar = heal_absorbs,
		maxOverflow = 1,
	}
end

lib.gen_cast_bar = function(base, w, h, text_size, latency, interrupt, color)

	local cast_bar = cui.util.gen_statusbar(base, w, h, cui.config.frame_background, cui.config.frame_background_light)
	
	if latency then
		cast_bar.SafeZone = cast_bar:CreateTexture(nil, "OVERLAY", nil, -8)
		cast_bar.SafeZone:SetTexture(cui.media.textures.blank)
		cast_bar.SafeZone:SetVertexColor(1, 0, 0, 0.3)
	end
	
	local cast_icon = cast_bar:CreateTexture()
	cast_icon:SetDrawLayer("OVERLAY", -6)
	cast_icon:SetSize(Round(h * 3 / 2), Round(h * 3 / 4))
	cast_icon:SetPoint("LEFT", cast_bar, "TOP", -Round(cast_icon:GetWidth() / 2), 0)
	cast_icon:SetTexCoord(0.1, 0.9, 0.30, 0.70)
	cast_bar.Icon = cast_icon
	
    cast_icon.border = cast_bar:CreateTexture()
	cast_icon.border:SetDrawLayer("OVERLAY", -7)
	cui.util.set_outside(cast_icon.border, cast_icon)
	cast_icon.border:SetTexture(cui.media.textures.blank)
	cast_icon.border:SetVertexColor(unpack(cui.config.frame_border))
	
	local text_color = color or {.9, .9, .9}

	local cast_max = cui.util.gen_string(cast_bar, text_size, nil, nil, "RIGHT", "BOTTOM")
	cast_max:SetTextColor(unpack(text_color))
	cast_max:SetPoint("BOTTOMRIGHT", 0, 2)
	cast_bar.Max = cast_max
	
	local cast_time = cui.util.gen_string(cast_bar, text_size, nil, nil, "LEFT", "BOTTOM")
	cast_time:SetTextColor(unpack(text_color))
	cast_time:SetPoint("BOTTOMLEFT", 3, 2)
	cast_bar.Time = cast_time
	cast_bar.CustomTimeText = function(self, duration)
	    self.Time:SetText(("%.1f"):format(self.channeling and duration or self.max - duration))
	    self.Max:SetText(("%.2f"):format(self.max))
    end
	
	local cast_name = cui.util.gen_string(cast_bar, text_size, nil, nil, "CENTER", "BOTTOM")
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
		
		cast_bar.PostChannelStart = function(self, ...)
			if (self.notInterruptible) then
				self:SetBackdropColor(unpack(cfg.cast_non_interrupt_color))
			else
				self:SetBackdropColor(unpack(cfg.cast_interrupt_color))
			end
		end
		
		cast_bar.PostCastInterruptible = function(self, ...)
			self:SetBackdropColor(unpack(cfg.cast_interrupt_color))
		end
		
		cast_bar.PostCastNotInterruptible = function(self, ...)
			self:SetBackdropColor(unpack(cfg.cast_non_interrupt_color))
		end
		
		cast_bar.PostChannelUpdate = function(self, ...)
			if (self.notInterruptible) then
				self:SetBackdropColor(unpack(cfg.cast_non_interrupt_color))
			else
				self:SetBackdropColor(unpack(cfg.cast_interrupt_color))
			end
		end
	end

	return cast_bar
end

lib.gen_nameplate_cast_bar = function(base, w, h, text_size)

    local cast_bar = cui.util.gen_statusbar(base, w, h)

    local cast_icon = cast_bar:CreateTexture()
	cast_icon:SetDrawLayer("OVERLAY", -6)
	cast_icon:SetSize(h * 2 - 3, h * 2 - 3)
	cast_icon:SetPoint("BOTTOMRIGHT", cast_bar, "BOTTOMLEFT", 0, 1)
	cast_icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	cast_bar.Icon = cast_icon
	
    cast_icon.border = cast_bar:CreateTexture()
	cast_icon.border:SetDrawLayer("OVERLAY", -7)
	cui.util.set_outside(cast_icon.border, cast_icon)
	cast_icon.border:SetTexture(cui.media.textures.blank)
	cast_icon.border:SetVertexColor(unpack(cui.config.frame_border))
	
	local cast_name = cui.util.gen_string(cast_bar, text_size, nil, nil, "LEFT", "TOP")
	cast_name:SetWordWrap(false)
	cast_name:SetTextColor(unpack(cui.config.frame_background))
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
	
	cast_bar.PostChannelStart = function(self, ...)
		if (self.notInterruptible) then
			cast_bar:SetStatusBarColor(unpack(cfg.cast_non_interrupt_color))
			cast_name:SetTextColor(unpack(cfg.cast_non_interrupt_color))
		else
			cast_bar:SetStatusBarColor(unpack(cfg.cast_interrupt_color))
			cast_name:SetTextColor(unpack(cfg.cast_interrupt_color))
		end
	end
	
	cast_bar.PostCastInterruptible = function(self, ...)
		cast_bar:SetStatusBarColor(unpack(cfg.cast_interrupt_color))
		cast_name:SetTextColor(unpack(cfg.cast_interrupt_color))
	end
	
	cast_bar.PostCastNotInterruptible = function(self, ...)
		cast_bar:SetStatusBarColor(unpack(cfg.cast_non_interrupt_color))
		cast_name:SetTextColor(unpack(cfg.cast_non_interrupt_color))
	end
	
	cast_bar.PostChannelUpdate = function(self, ...)
		if (self.notInterruptible) then
			cast_bar:SetStatusBarColor(unpack(cfg.cast_non_interrupt_color))
			cast_name:SetTextColor(unpack(cfg.cast_non_interrupt_color))
		else
			cast_bar:SetStatusBarColor(unpack(cfg.cast_interrupt_color))
			cast_name:SetTextColor(unpack(cfg.cast_interrupt_color))
		end
	end

	return cast_bar
end

lib.gen_xp_bar = function(base, w, h)

    local xp_bar = CreateFrame("StatusBar", nil, base)
	xp_bar:SetStatusBarTexture(cui.media.textures.blank)
	xp_bar:SetSize(w, h)
	
    -- give this the backdrop since the module forces it behind the xp bar
	local rested_bar = cui.util.gen_statusbar(xp_bar, w + 2, h + 2)
	rested_bar:SetPoint("TOPLEFT", xp_bar, "TOPLEFT", -1, 1)

    xp_bar.Rested = rested_bar
	return xp_bar
end

lib.gen_classpower = function(base, w, h)

	local max = 10

	local classpower = CreateFrame("Frame", nil, base)
	classpower:SetSize(w, h)
	
	local icon_w = w / max
	
	for i = 1, max do
	
		local icon = cui.util.gen_statusbar(classpower, icon_w, h)
		
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
        local rune = cui.util.gen_statusbar(runes, rune_w, h)
		rune:SetStatusBarTexture(cui.media.textures.blank)
		
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
		cui.util.gen_backdrop(indicator, unpack(cfg[2]))
	elseif cfg[3] == "cd" then
		local cd = CreateFrame("Cooldown", nil, indicator)
		cd:SetAllPoints(indicator)
		cd:SetHideCountdownNumbers(false)
		cui.util.fix_string(cd:GetRegions(), cfg[5])
		cd:GetRegions():SetTextColor(unpack(cfg[2]))
		cd:GetRegions():SetJustifyH(h_justify)
		cd:GetRegions():SetJustifyV(v_justify)
		cd:GetRegions():SetPoint(v_justify..h_justify, indicator, v_justify..h_justify, 1, 0)
		indicator.cd = cd
	elseif cfg[3] == "count" then
		local count = cui.util.gen_string(indicator, cfg[5], nil, nil, h_justify, v_justify)
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
		indicators.icons["tl"] = gen_indicator(cfg.indicators.tl, base.Health, "LEFT", "BOTTOM", 1, 1)
	end

	if cfg.bl then
		indicators.icons["bl"] = gen_indicator(cfg.indicators.bl, base.Health, "LEFT", "TOP", 1, -1)
	end

	if cfg.tr then
		indicators.icons["tr"] = gen_indicator(cfg.indicators.tr, base.Health, "RIGHT", "BOTTOM", -1, 1)
	end

	if cfg.br then
		indicators.icons["br"] = gen_indicator(cfg.indicators.br, base.Health, "RIGHT", "TOP", -1, -1)
	end

	return indicators
end

lib.update_raid_mark = function(base, position)
	base.RaidIcon:ClearAllPoints()
	base.RaidIcon:SetPoint("CENTER", base, position[1], position[2], position[3])
	base.RaidIcon:SetSize(position[4], position[4])
end

lib.gen_raid_mark = function(base, position)
	local mark = base.Health:CreateTexture(nil, "OVERLAY")
	mark:SetPoint("CENTER", base.Health, position[1], position[2], position[3])
	mark:SetSize(position[4], position[4])
	
	base.RaidTargetIndicator = mark
end

lib.gen_raid_role = function(base)
	local role = cui.util.gen_string(base.Health, cfg.raid_role.size, nil, cui.media.fonts.role_symbols)
	role:SetPoint("CENTER", base, cfg.raid_role.point, cfg.raid_role.x, cfg.raid_role.y)
	base:Tag(role, '[city:role]')
end

lib.gen_ready_check = function(base)
	local ready = base.Health:CreateTexture(nil, 'OVERLAY')
	ready:SetSize(15, 15)
    ready:SetPoint('CENTER')
	base.ReadyCheckIndicator = ready
end
--[[
	element, unit, button, name, texture, count, debuffType, duration, 
	expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, 
	isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3
]]
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
	cui.util.fix_string(button.cd:GetRegions(), buffs.cdsize)
	button.cd:SetDrawEdge(false)
	
	if buffs.squashed then
		button.icon:SetTexCoord(0.1, 0.9, 0.3, 0.7)
	else
		button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	cui.util.set_inside(button.icon, button)
	
	button.overlay:SetDrawLayer("BACKGROUND")
	button.overlay:SetTexture(cui.media.textures.blank)
	button.overlay:SetPoint("TOPLEFT")
    button.overlay:SetPoint("BOTTOMRIGHT")
	button.overlay:SetTexCoord(0, 1, 0, 1)

	button.overlay.oldHide = button.overlay.Hide
	button.overlay.Hide = function(self) self:SetVertexColor(0, 0, 0) end
	
	button.count:SetPoint("TOPRIGHT", button, 3, 3)
	button.count:SetJustifyH("RIGHT")
	button.count:SetJustifyV("TOP")
	button.count:SetFont(cui.config.default_font, buffs.countsize, cui.config.font_flags)
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
	auras.squashed = cfg[9]
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
