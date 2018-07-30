local addon, ns = ...

local cfg = ns.config
local lib = {}
ns.lib = lib
local CityUi = CityUi

lib.common_init = function(base, frame_anchor, parent_anchor, x, y, w, parent)

    base.stack_bottom = -1
    base:SetWidth(w + 2)
    base:SetFrameStrata("BACKGROUND")

    if frame_anchor then base:SetPoint(frame_anchor, parent or UIParent, parent_anchor, x, y) end

    base:RegisterForClicks("AnyDown")
	base:SetScript("OnEnter", UnitFrame_OnEnter)
	base:SetScript("OnLeave", UnitFrame_OnLeave)
end

lib.push_bar = function(base, bar)
    bar:SetPoint("TOP", base, "TOP", 0, base.stack_bottom)
    base.stack_bottom = base.stack_bottom - bar:GetHeight() - 1
end

lib.gen_hp_bar = function(base, w, h, flip, prediction)
	
	base.Health = CityUi.util.gen_statusbar(base, w, h)

    if prediction then
        lib.gen_heal_bar(base, w)
    end
	
    if flip then
		base.Health.PostUpdate = function(self, unit, min, max)
	        self.backdrop:SetVertexColor(self:GetStatusBarColor())
	        self:SetStatusBarColor(unpack(CityUi.config.frame_background))
        end
	end
end

lib.gen_heal_bar = function(base, w)
	
	local my_heals = CreateFrame("StatusBar", nil, base.Health)
	my_heals:SetStatusBarTexture(CityUi.media.textures.blank)
	my_heals:SetPoint("LEFT", base.Health:GetStatusBarTexture(), "RIGHT")
	my_heals:SetPoint("TOP")
	my_heals:SetPoint("BOTTOM")
	my_heals:SetWidth(w)
	my_heals:SetStatusBarColor(.25, .75, .50, .75)
	my_heals:SetFrameLevel(base.Health:GetFrameLevel())
	
	local other_heals = CreateFrame("StatusBar", nil, base.Health)
	other_heals:SetStatusBarTexture(CityUi.media.textures.blank)
	other_heals:SetPoint("LEFT", my_heals:GetStatusBarTexture(), "RIGHT")
	other_heals:SetPoint("TOP")
	other_heals:SetPoint("BOTTOM")
	other_heals:SetWidth(w)
	other_heals:SetStatusBarColor(.75, .75, .25, .75)
	other_heals:SetFrameLevel(base.Health:GetFrameLevel())
	
	local absorbs = CreateFrame("StatusBar", nil, base.Health)
	absorbs:SetStatusBarTexture(CityUi.media.textures.blank)
	absorbs:SetPoint("LEFT", other_heals:GetStatusBarTexture(), "RIGHT")
	absorbs:SetPoint("TOP")
	absorbs:SetPoint("BOTTOM")
	absorbs:SetWidth(w)
	absorbs:SetStatusBarColor(.75, .75, .75, .75)
	absorbs:SetFrameLevel(base.Health:GetFrameLevel())
	
	-- local heal_absorbs = CreateFrame("StatusBar", nil, base.Health)
	-- heal_absorbs:SetStatusBarTexture(CityUi.media.textures.blank)
	-- heal_absorbs:SetPoint("LEFT", absorbs:GetStatusBarTexture(), "RIGHT")
	-- heal_absorbs:SetPoint("TOP")
	-- heal_absorbs:SetPoint("BOTTOM")
	-- heal_absorbs:SetWidth(w)
	-- heal_absorbs:SetStatusBarColor(.25, .25, .25, .75)
	-- heal_absorbs:SetFrameLevel(base.Health:GetFrameLevel())
	
	base.HealthPrediction = {
		myBar = my_heals,
		otherBar = other_heals,
		absorbBar = absorbs,
		--healAbsorbBar = heal_absorbs,
		maxOverflow = 1,
	}
end

lib.gen_power_bar = function(base, w, h, flip)

    base.Power = CityUi.util.gen_statusbar(base, w, h)
	
	if (flip) then
		base.Power.PostUpdate =  function(self, unit, cur, max, min)
	        self.backdrop:SetVertexColor(self:GetStatusBarColor())
	        self:SetStatusBarColor(unpack(CityUi.config.frame_background))
        end
	end
end

lib.gen_cast_bar = function(base, w, h, text_size, latency, interrupt, color)

	local text_color = color or {.9, .9, .9}
	
	local cast_bar = CityUi.util.gen_statusbar(base, w, h, CityUi.config.frame_background, CityUi.config.frame_background_light)
    base.Castbar = cast_bar
	
	if latency then
		cast_bar.SafeZone = cast_bar:CreateTexture(nil, "OVERLAY", nil, -8)
		cast_bar.SafeZone:SetTexture(CityUi.media.textures.blank)
		cast_bar.SafeZone:SetVertexColor(1, 0, 0, 0.3)
	end
	
	local cast_icon = cast_bar:CreateTexture()
	cast_icon:SetDrawLayer("OVERLAY", -6)
	cast_icon:SetSize(h * 3 / 2, h * 3 / 4)
	cast_icon:SetPoint("CENTER", cast_bar, "TOP", 0, 0)
	cast_icon:SetTexCoord(0.1, 0.9, 0.25, 0.75)
	cast_bar.Icon = cast_icon
	
    cast_icon.border = cast_bar:CreateTexture()
	cast_icon.border:SetDrawLayer("OVERLAY", -7)
	cast_icon.border:SetPoint("TOPLEFT", cast_icon, "TOPLEFT", -1, 1)
	cast_icon.border:SetPoint("BOTTOMRIGHT", cast_icon, "BOTTOMRIGHT", 1, -1)
	cast_icon.border:SetTexture(CityUi.media.textures.blank)
	cast_icon.border:SetVertexColor(unpack(CityUi.config.frame_border))
	
	local cast_max = CityUi.util.gen_string(cast_bar, text_size, nil, nil, "RIGHT", "BOTTOM")
	cast_max:SetTextColor(unpack(text_color))
	cast_max:SetPoint("BOTTOMRIGHT", 0, 2)
	cast_bar.Max = cast_max
	
	local cast_time = CityUi.util.gen_string(cast_bar, text_size, nil, nil, "LEFT", "BOTTOM")
	cast_time:SetTextColor(unpack(text_color))
	cast_time:SetPoint("BOTTOMLEFT", 3, 2)
	cast_bar.Time = cast_time
	cast_bar.CustomTimeText = function(self, duration)
	    self.Time:SetText(("%.1f"):format(self.channeling and duration or self.max - duration))
	    self.Max:SetText(("%.2f"):format(self.max))
    end
	
	local cast_name = CityUi.util.gen_string(cast_bar, text_size, nil, nil, "CENTER", "BOTTOM")
	cast_name:SetWordWrap(false)
	cast_name:SetTextColor(unpack(text_color))
	cast_name:SetPoint("BOTTOMLEFT", h, 2)
	cast_name:SetPoint("BOTTOMRIGHT", -h, 2)
	cast_bar.Text = cast_name

	if interrupt then
		cast_bar.PostCastStart = function(self, ...)
			if (self.notInterruptible) then
				self.backdrop:SetVertexColor(unpack(cfg.cast_non_interrupt_color))
			else
				self.backdrop:SetVertexColor(unpack(cfg.cast_interrupt_color))
			end
		end
		
		cast_bar.PostChannelStart = function(self, ...)
			if (self.notInterruptible) then
				self.backdrop:SetVertexColor(unpack(cfg.cast_non_interrupt_color))
			else
				self.backdrop:SetVertexColor(unpack(cfg.cast_interrupt_color))
			end
		end
		
		cast_bar.PostCastInterruptible = function(self, ...)
			self.backdrop:SetVertexColor(unpack(cfg.cast_interrupt_color))
		end
		
		cast_bar.PostCastNotInterruptible = function(self, ...)
			self.backdrop:SetVertexColor(unpack(cfg.cast_non_interrupt_color))
		end
		
		cast_bar.PostChannelUpdate = function(self, ...)
			if (self.notInterruptible) then
				self.backdrop:SetVertexColor(unpack(cfg.cast_non_interrupt_color))
			else
				self.backdrop:SetVertexColor(unpack(cfg.cast_interrupt_color))
			end
		end
	end
end

lib.gen_nameplate_cast_bar = function(base, w, h, text_size)

    local cast_bar = CityUi.util.gen_statusbar(base, w, h)
    base.Castbar = cast_bar

    local cast_icon = cast_bar:CreateTexture()
	cast_icon:SetDrawLayer("OVERLAY", -6)
	cast_icon:SetSize(h * 2 + 1, h * 2 + 1)
	cast_icon:SetPoint("BOTTOMRIGHT", cast_bar, "BOTTOMLEFT", -1, 0)
	cast_icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	cast_bar.Icon = cast_icon
	
    cast_icon.border = cast_bar:CreateTexture()
	cast_icon.border:SetDrawLayer("OVERLAY", -7)
	cast_icon.border:SetPoint("TOPLEFT", cast_icon, "TOPLEFT", -1, 1)
	cast_icon.border:SetPoint("BOTTOMRIGHT", cast_icon, "BOTTOMRIGHT", 1, -1)
	cast_icon.border:SetTexture(CityUi.media.textures.blank)
	cast_icon.border:SetVertexColor(unpack(CityUi.config.frame_border))
	
	local cast_name = CityUi.util.gen_string(cast_bar, text_size, nil, nil, "LEFT", "TOP")
	cast_name:SetWordWrap(false)
	cast_name:SetTextColor(unpack(CityUi.config.frame_background))
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
end

lib.gen_xp_bar = function(base, w, h)

    local xp_bar = CreateFrame("StatusBar", nil, base)
	xp_bar:SetStatusBarTexture(CityUi.media.textures.blank)
	xp_bar:SetSize(w, h)
	
    -- Give this the backdrop since the module forces it behind the xp bar.
	local rested_bar = CityUi.util.gen_statusbar(xp_bar, w, h)
	rested_bar:SetAllPoints()

    base.Experience = xp_bar
	base.Experience.Rested = rested_bar
end

lib.gen_addp_bar = function(base, w, h)
    base.AdditionalPower = CityUi.util.gen_statusbar(base, w, h)
end

lib.gen_altp_bar = function(base, w, h)
    base.AlternativePower = CityUi.util.gen_statusbar(base, w, h)
end

-- config:
-- ["pos"] = {spellId, {color}, "state/cd/count", castByPlayer, size}
local gen_indicator = function(cfg, parent, h_justify, v_justify, x_offset, y_offset)

	local indicator = CreateFrame("Frame", nil, parent)
	indicator:SetPoint(v_justify..h_justify, parent, h_justify, x_offset, y_offset)
	indicator.spellID = cfg[1]
	indicator:SetSize(cfg[5], cfg[5])

	if not cfg[4] then
		indicator.anyUnit = true
	end

	if cfg[3] == "state" then
		CityUi.util.gen_backdrop(indicator, unpack(cfg[2]))
	elseif cfg[3] == "cd" then
		local cd = CreateFrame("Cooldown", nil, indicator)
		cd:SetAllPoints(indicator)
		cd:SetHideCountdownNumbers(false)
		cd:GetRegions():SetFont(CityUi.media.fonts.pixel_10, cfg[5], "MONOCHROMETHINOUTLINE")
		cd:GetRegions():SetShadowOffset(0, 0)
		cd:GetRegions():SetTextColor(unpack(cfg[2]))
		cd:GetRegions():SetJustifyH(h_justify)
		cd:GetRegions():SetJustifyV(v_justify)
		cd:GetRegions():SetPoint(v_justify..h_justify, indicator, v_justify..h_justify, 1, 0)
		indicator.cd = cd
	elseif cfg[3] == "count" then
		local count = CityUi.util.gen_string(indicator, cfg[5], nil, nil, h_justify, v_justify)
		count:SetAllPoints(indicator)
		count:SetTextColor(unpack(cfg[2]))
		indicator.count = count
	end

	return indicator
end

lib.gen_indicators = function(base)

	local indicators = {}
	indicators.onlyShowPresent = true
	indicators.customIcons = true

	indicators.icons = {}

	if cfg.indicators.tl then
		indicators.icons["tl"] = gen_indicator(cfg.indicators.tl, base.Health, "LEFT", "BOTTOM", 1, 1)
	end

	if cfg.indicators.bl then
		indicators.icons["bl"] = gen_indicator(cfg.indicators.bl, base.Health, "LEFT", "TOP", 1, -1)
	end

	if cfg.indicators.tr then
		indicators.icons["tr"] = gen_indicator(cfg.indicators.tr, base.Health, "RIGHT", "BOTTOM", -1, 1)
	end

	if cfg.indicators.br then
		indicators.icons["br"] = gen_indicator(cfg.indicators.br, base.Health, "RIGHT", "TOP", -1, -1)
	end

	base.AuraWatch = indicators
end

lib.post_update_classpower = function(classpower, curr, max, max_changed, power_type)
	if max_changed then
		local icon_w = (classpower:GetWidth() - max - 1) / max
	
		for i = 1, max do
			local icon = classpower[i]
			icon:SetSize(icon_w, classpower:GetHeight())
		end
	end
end

lib.gen_classpower = function(base, w, h)

	local max = 10

	local classpower = CreateFrame("Frame", nil, base)
	classpower:SetSize(w, h)
	
	local icon_w = (w - max - 1) / max
	
	for i = 1, max do
	
		local icon = CityUi.util.gen_statusbar(classpower, icon_w, h)
		
		if i == 1 then
			icon:SetPoint("TOPLEFT")
		else
			icon:SetPoint("TOPLEFT", classpower[i - 1], "TOPRIGHT", 1, 0)
		end

        classpower[i] = icon
	end
	
	classpower.PostUpdate = lib.post_update_classpower
	base.ClassPower = classpower

    return classpower
end

lib.gen_rune_bar = function(base, w, h)
	
    local max = 6

	local runes = CreateFrame("Frame", nil, base)
	runes:SetSize(w, h)
	
	local rune_w = (w - max - 1) / max
	
	for i = 1, max do
        local rune = CityUi.util.gen_statusbar(runes, rune_w, h)
		rune:SetStatusBarTexture(CityUi.media.textures.blank)
		
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

lib.resource_gens = {
	["DEATHKNIGHT"] = lib.gen_rune_bar,
	["PALADIN"] = lib.gen_classpower,
	["ROGUE"] = lib.gen_classpower,
	["MONK"] = lib.gen_classpower,
	["DRUID"] = lib.gen_classpower,
}

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
	local role = CityUi.util.gen_string(base.Health, cfg.raid_role[4], nil, CityUi.media.fonts.role_symbols)
	role:SetPoint("CENTER", base, cfg.raid_role[1], cfg.raid_role[2], cfg.raid_role[3])
	base:Tag(role, '[city:role]')
end

lib.gen_ready_check = function(base)
	local ready = base.Health:CreateTexture(nil, 'OVERLAY')
	ready:SetSize(15, 15)
    ready:SetPoint('CENTER')
	base.ReadyCheckIndicator = ready
end

-- element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, 
-- nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3

lib.custom_whitelist = function(_, _, _, _, _, _, _, _, _, _, _, _, spellID)
	if cfg.debuff_whitelist[spellID] then
		return true
	else
		return false
	end
end

lib.custom_pet_whitelist = function(_, _, _, _, _, _, _, _, _, _, _, _, spellID)
	if cfg.buff_whitelist_pet[spellID] then
		return true
	else
		return false
	end
end

lib.custom_blacklist = function(_, _, _, _, _, _, _, _, _, _, _, _, spellID)
	if cfg.debuff_blacklist[spellID] then
		return false
	else
		return true
	end
end

lib.custom_buff_whitelist = function(_, _, _, _, _, _, _, _, _, _, _, _, spellID)
	if cfg.buff_whitelist[spellID] then
		return true
	else
		return false
	end
end

lib.player_only_whitelist = function(_, _, icon)
	return icon.isPlayer
end

lib.post_create_icon = function(buffs, button)

	button.cd:SetReverse(true)
	button.cd:SetFrameLevel(button:GetFrameLevel())
	button.cd:SetHideCountdownNumbers(false)
	button.cd:GetRegions():SetFont(CityUi.media.fonts.pixel_10, buffs.cdsize, "MONOCHROMETHINOUTLINE")
	button.cd:GetRegions():SetShadowOffset(0, 0)
	button.cd:SetDrawEdge(false)
	
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	
	button.overlay:SetDrawLayer("BACKGROUND")
	button.overlay:SetTexture(CityUi.media.textures.blank)
	button.overlay:SetPoint("TOPLEFT")
    button.overlay:SetPoint("BOTTOMRIGHT")
	button.overlay:SetTexCoord(0, 1, 0, 1)
	button.overlay.Hide = function(self) self:SetVertexColor(.3, .3, .3) end
	button.count:SetPoint("BOTTOMRIGHT", button, 3, 0)
	button.count:SetJustifyH("RIGHT")
	button.count:SetJustifyV("BOTTOM")
	button.count:SetFont(CityUi.media.fonts.pixel_10, buffs.countsize, "MONOCHROMETHINOUTLINE")
end

lib.post_create_nameplate_icon = function(buffs, button)

	button.cd:SetReverse(true)
	button.cd:SetFrameLevel(button:GetFrameLevel())
	button.cd:SetHideCountdownNumbers(false)
	button.cd:GetRegions():SetFont(CityUi.media.fonts.pixel_10, buffs.cdsize, "MONOCHROMETHINOUTLINE")
	button.cd:GetRegions():SetShadowOffset(0, 0)
	button.cd:SetDrawEdge(false)
	
	button.icon:SetTexCoord(0.1, 0.9, 0.3, 0.7)
	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	
	button.overlay:SetDrawLayer("BACKGROUND")
	button.overlay:SetTexture(CityUi.media.textures.blank)
	button.overlay:SetPoint("TOPLEFT")
    button.overlay:SetPoint("BOTTOMRIGHT")
	button.overlay:SetTexCoord(0, 1, 0, 1)
	button.overlay.Hide = function(self) self:SetVertexColor(0, 0, 0) end
	button.count:SetPoint("BOTTOMRIGHT", button, 3, -3)
	button.count:SetJustifyH("RIGHT")
	button.count:SetJustifyV("BOTTOM")
	button.count:SetFont(CityUi.media.fonts.pixel_10, buffs.countsize, "MONOCHROMETHINOUTLINE")
end

lib.post_update_icon = function(self, unit, icon, index, offset)
	icon.icon:SetDesaturated(not icon.isPlayer)
end

lib.post_update_nameplate_icon = function(self, unit, icon, index, offset)
	icon:SetHeight(icon:GetWidth() / 2)
	icon.overlay:SetVertexColor(0, 0, 0)
end

lib.gen_buffs = function(base, w, config)

	local buffs = CreateFrame("Frame", base:GetName().."Buffs", base.Health)
	
	buffs.size = config[1]
	buffs.spacing = 1
	local num_per_row = math.floor(w / (buffs.size + buffs.spacing))
	buffs.num = config[2] * num_per_row
	
    buffs:SetSize(num_per_row * (buffs.size + 1) - 1, buffs.size * config[2] + config[2] - 1)
	
    buffs.initialAnchor = config[3]
	buffs["growth-x"] = config[4]
	buffs["growth-y"] = config[5]
	buffs.countsize = config[7]
	buffs.cdsize = config[8]
	
    buffs.PostCreateIcon = lib.post_create_icon
	
	local bg = buffs:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(buffs)
	bg:SetTexture(CityUi.media.textures.blank)
	bg:SetVertexColor(0, 0, 0)
	bg:Hide()
	buffs.bg = bg

    base.Buffs = buffs
end

lib.gen_pet_debuffs = function(base, w, config)

	local buffs = CreateFrame("Frame", base:GetName().."Debuffs", base)
	
	buffs.size = config[1]
	buffs.spacing = 1
	local num_per_row = math.floor(w / (buffs.size + buffs.spacing))
	buffs.num = config[2] * num_per_row
	
	buffs:SetSize(num_per_row * (buffs.size + 1) - 1, buffs.size / 2 * config[2] + config[2] - 1)
	
	buffs.initialAnchor = config[3]
	buffs["growth-x"] = config[4]
	buffs["growth-y"] = config[5]
	buffs.countsize = config[7]
	buffs.cdsize = config[8]
	
	buffs.PostCreateIcon = lib.post_create_nameplate_icon
	buffs.PostUpdateIcon = lib.post_update_nameplate_icon
	
	base.Debuffs = buffs
end

lib.gen_pet_buffs = function(base, w, config)

	local buffs = CreateFrame("Frame", base:GetName().."Buffs", base)
	
	buffs.size = config[1]
	buffs.spacing = 1
	local num_per_row = math.floor(w / (buffs.size + buffs.spacing))
	buffs.num = config[2] * num_per_row
	
	buffs:SetSize(num_per_row * (buffs.size + 1) - 1, buffs.size / 2 * config[2] + config[2] - 1)
	
	buffs.initialAnchor = config[3]
	buffs["growth-x"] = config[4]
	buffs["growth-y"] = config[5]
	buffs.countsize = config[7]
	buffs.cdsize = config[8]
	
	buffs.PostCreateIcon = lib.post_create_nameplate_icon
	buffs.PostUpdateIcon = lib.post_update_nameplate_icon
	
	base.Buffs = buffs
end

lib.gen_nameplate_debuffs = function(base, config)

	local debuffs = CreateFrame("Frame", base:GetName().."Debuffs", base)
	
	debuffs.size = config[1]
	debuffs.spacing = 1
	debuffs.countsize = config[7]
	debuffs.cdsize = config[8]
	
	local num_per_row = config[6]
	
	debuffs.num = config[2] * num_per_row
	
	debuffs:SetSize(num_per_row * debuffs.size + num_per_row - 1, debuffs.size / 2 * config[2] + config[2] - 1)
	
	debuffs.initialAnchor = config[3]
	debuffs["growth-x"] = config[4]
	debuffs["growth-y"] = config[5]
	
	debuffs["spacing-y"] = -debuffs.size / 2 + 1
	debuffs.showDebuffType = true
	
	debuffs.PostCreateIcon = lib.post_create_nameplate_icon
	debuffs.PostUpdateIcon = lib.post_update_nameplate_icon
	
	base.Debuffs = debuffs
end

lib.gen_debuffs = function(base, w, config)

	local debuffs = CreateFrame("Frame", base:GetName().."Debuffs", base.Health)
	
	debuffs.size = config[1]
	debuffs.spacing = 1
	debuffs.countsize = config[7]
	debuffs.cdsize = config[8]
	
	local num_per_row
	
	if (config[6]) then
		num_per_row = config[6]
	else
		num_per_row = math.floor(w / (debuffs.size + debuffs.spacing))
		if (num_per_row * (debuffs.size + 1) + debuffs.size <= w) then
			num_per_row = num_per_row + 1
		end
	end
	
	debuffs.num = config[2] * num_per_row
	
	debuffs:SetSize(num_per_row * (debuffs.size + 1) - 1, debuffs.size * config[2] + config[2] - 1)
	
	debuffs.initialAnchor = config[3]
	debuffs["growth-x"] = config[4]
	debuffs["growth-y"] = config[5]
	debuffs.showDebuffType = true
	
	debuffs.PostCreateIcon = lib.post_create_icon
	
	local bg = debuffs:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(debuffs)
	bg:SetTexture(CityUi.media.textures.blank)
	bg:SetVertexColor(0, 0, 0)
	bg:Hide()
	debuffs.bg = bg
	
	base.Debuffs = debuffs
end

lib.enable_test = function(base)
	base.test_frame = function(on)
		if on then
			if base.Buffs then base.Buffs.bg:Show() end
			if base.Debuffs then base.Debuffs.bg:Show() end
		else
			if base.Buffs then base.Buffs.bg:Hide() end
			if base.Debuffs then base.Debuffs.bg:Hide() end
		end
	end
end
