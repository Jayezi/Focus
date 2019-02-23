local addon, cuf = ...
local cfg = cuf.cfg
local lib = cuf.lib
local cui = CityUi

local function create_player_style(base)

	local player_cfg = cfg.frames.player
	base:SetWidth(player_cfg.size.w)
	lib.enable_mouse(base)

	-- cast
	base.Castbar = lib.gen_cast_bar(base, player_cfg.cast.size.w, player_cfg.cast.size.h, cui.config.font_size_med, true, false, cui.player.color)
	base.Castbar:SetPoint(cui.util.to_tl_anchor(base.Castbar, player_cfg.cast.pos))
	
	local power_standalone, power_invert, power_tag = unpack(player_cfg.power.cfg)
	local power_w = power_standalone and player_cfg.cast.size.w or player_cfg.size.w
	local power_h = power_standalone or player_cfg.power.h
	
	-- power
	base.Power = cui.util.gen_statusbar(base, power_w, power_h)
	base.Power.frequentUpdates = true
	base.Power.colorClass = true
	if power_invert then
		base.Power.PostUpdate = lib.invert_color
	end

	-- classbar
	local resource_bar = lib.gen_resource_bar(cui.player.class, base, power_w, power_h)
	if (resource_bar) then
		if (power_standalone) then
			resource_bar:SetPoint("TOPLEFT", base.Castbar, "BOTTOMLEFT", 0, 1)
			base.Power:SetPoint("TOPLEFT", resource_bar, "BOTTOMLEFT", 0, 1)
		else
			lib.push_bar(base, resource_bar)
			lib.push_bar(base, base.Power)
		end
	else
		if (power_standalone) then
			base.Power:SetPoint("TOPLEFT", base.Castbar, "BOTTOMLEFT", 0, 1)
		else
			lib.push_bar(base, base.Power)
		end
	end

	-- health
	base.Health = cui.util.gen_statusbar(base, player_cfg.size.w, player_cfg.size.h)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	base.Health.PostUpdate = lib.invert_color
	lib.push_bar(base, base.Health)

	base.HealthPrediction = lib.gen_heal_bar(base.Health)
	base.HealthPrediction.frequentUpdates = true

	-- "druid mana" etc.
	base.AdditionalPower = cui.util.gen_statusbar(base, player_cfg.size.w, player_cfg.power.h)
	base.AdditionalPower:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.AdditionalPower:SetPoint("TOPLEFT", base.Health, "TOPLEFT", 2, -2)
	base.AdditionalPower:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -2, -2)
	base.AdditionalPower.colorPower = true

	-- alternate power
	base.AlternativePower = cui.util.gen_statusbar(base, player_cfg.alt_power.size.w, player_cfg.alt_power.size.h)
	base.AlternativePower:SetPoint(cui.util.to_tl_anchor(base.AlternativePower, player_cfg.alt_power.pos))

	-- experience
	base.Experience = lib.gen_xp_bar(base, player_cfg.alt_power.size.w, player_cfg.alt_power.size.h)
	base.Experience:SetPoint("TOPLEFT", base.AlternativePower, "BOTTOMLEFT", 0, -10)

	base:SetHeight(base.stack_height)

	-- strings
	local hp_string = cui.util.gen_string(base.Health, cui.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 1)
	hp_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	base:Tag(hp_string, "[city:color][city:hplong]")
	
	local altp_string = cui.util.gen_string(base.AlternativePower, cui.config.font_size_med, nil, nil, "BOTTOM", "CENTER")
	altp_string:SetPoint("BOTTOM", 0, 1)
	base:Tag(altp_string, "[city:color][city:altpower]")

	local hp_perc_string = cui.util.gen_string(base.Health, cui.config.font_size_lrg, nil, nil, "LEFT", "TOP")
	hp_perc_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, 10)
	base:Tag(hp_perc_string, "[city:color][perhp]")

	local name_string = cui.util.gen_string(base.Health, cui.config.font_size_lrg, nil, nil, "RIGHT", "TOP")
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, 10)
	name_string:SetPoint("LEFT", hp_perc_string, "RIGHT", 5, 0)
	base:Tag(name_string, "[city:color][city:info][name]")
	
	local power_string
	if (power_standalone) then
		power_string = cui.util.gen_string(base.Power, cui.config.font_size_lrg, nil, nil, "CENTER", "BOTTOM")
		power_string:SetPoint("BOTTOM", 0, -10)
	else
		power_string = cui.util.gen_string(base.Health, cui.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
		power_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	end
	base:Tag(power_string, power_tag)
	
	local xp_string = cui.util.gen_string(base.Experience, cui.config.font_size_med, nil, nil, "BOTTOM", "CENTER")
	xp_string:SetPoint("BOTTOM", 0, 1)
	base:Tag(xp_string, "[experience:cur] / [experience:max] - [experience:per]%")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, player_cfg.size.w, cfg.auras.player, "Debuffs")
	base.Debuffs:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 0, cui.config.font_size_med + 2)

	base.Buffs = lib.gen_auras(base, player_cfg.size.w, cfg.auras.player, "Buffs")
	base.Buffs:SetPoint("BOTTOMRIGHT", base.Debuffs, "TOPRIGHT", 0, 1)
	lib.apply_whitelist_to(base.Buffs, cfg.player_buff_whitelist)
	
	-- mark
	lib.gen_raid_mark(base, cfg.raid_marks.primary)
end

local function create_target_style(base)
	
	local target_cfg = cfg.frames.target
	base:SetWidth(target_cfg.size.w)
	lib.enable_mouse(base)

	-- power
	base.Power = cui.util.gen_statusbar(base, target_cfg.size.w, target_cfg.power.h)
	base.Power.colorReaction = true
	base.Power.colorClass = true
	base.Power.colorDisconnected = true
	base.Power.frequentUpdates = true
	base.Power.colorTapping = true
	lib.push_bar(base, base.Power)
	
	-- health
	base.Health = cui.util.gen_statusbar(base, target_cfg.size.w, target_cfg.size.h)
	base.Health.colorTapping = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	base.Health.PostUpdate = lib.invert_color
	lib.push_bar(base, base.Health)

	-- alternate power
	base.AlternativePower = cui.util.gen_statusbar(base, target_cfg.size.w, target_cfg.power.h)
	base.AlternativePower:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.AlternativePower:SetPoint("TOPLEFT", base.Health, "TOPLEFT", 2, -2)
	base.AlternativePower:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -2, -2)
	
	-- cast
	base.Castbar = lib.gen_cast_bar(base, target_cfg.cast.size.w, target_cfg.cast.size.h, cui.config.font_size_med, false, true)
	base.Castbar:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", target_cfg.cast.offset.x, target_cfg.cast.offset.y)
	
	base:SetHeight(base.stack_height)

	-- strings
	local power_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
	power_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 1, 1)
	base:Tag(power_string, "[city:color][city:pplongfrequent]")

	local hp_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 1)
	hp_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	base:Tag(hp_string, "[city:color][city:hplong]")

	local hp_perc_string = cui.util.gen_string(base.Health, cui.config.font_size_lrg, nil, nil, "RIGHT", "TOP")
	hp_perc_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, 10)
	base:Tag(hp_perc_string, "[city:color][perhp]")

	local name_string = cui.util.gen_string(base.Health, cui.config.font_size_lrg, nil, nil, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, 10)
	name_string:SetPoint("RIGHT", hp_perc_string, "LEFT", -5, 0)
	base:Tag(name_string, "[city:color][city:info][name]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, target_cfg.size.w, cfg.auras.target_debuff, "Debuffs")
	base.Debuffs:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 0, cui.config.font_size_med + 2)

	base.Buffs = lib.gen_auras(base, target_cfg.size.w, cfg.auras.target_buff, "Buffs")
	base.Buffs:SetPoint("BOTTOMLEFT", base.Debuffs, "TOPLEFT", 0, 1)

	-- mark
	lib.gen_raid_mark(base, cfg.raid_marks.primary)
end

local function create_tot_style(base)

	local tot_cfg = cfg.frames.targettarget
	base:SetWidth(tot_cfg.size.w)
	base:SetPoint("TOPLEFT", _G["oUF_CityTarget"], "BOTTOMLEFT", 0, -20)
	lib.enable_mouse(base)
	
	-- health
	base.Health = cui.util.gen_statusbar(base, tot_cfg.size.w, tot_cfg.size.h)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdate = lib.invert_color
	lib.push_bar(base, base.Health)
	
	base:SetHeight(base.stack_height)

	-- strings
	local name_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, -1)
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, -1)
	base:Tag(name_string, "[city:color][name]")
	name_string:SetMaxLines(2)
end

local function create_pet_style(base)

	local pet_cfg = cfg.frames.pet
	base:SetWidth(pet_cfg.size.w)
	base:SetPoint("TOPRIGHT", _G["oUF_CityPlayer"], "BOTTOMRIGHT", 0, -20)
	lib.enable_mouse(base)
	
	-- health
	base.Health = cui.util.gen_statusbar(base, pet_cfg.size.w, pet_cfg.size.h)
	base.Health.colorDisconnected = true
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	base.Health.PostUpdate = lib.invert_color
	lib.push_bar(base, base.Health)
	
	-- power
	base.Power = cui.util.gen_statusbar(base, pet_cfg.size.w, pet_cfg.power.h)
	base.Power.colorReaction = true
	base.Power.frequentUpdates = true
	lib.push_bar(base, base.Power)

	base:SetHeight(base.stack_height)
	
	-- strings
	local name_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "RIGHT", "TOP")
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -1)
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 0, -1)
	base:Tag(name_string, "[city:color][name]")
	name_string:SetWordWrap(false)

	local hp_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "RIGHT", "TOP")
	hp_string:SetPoint("TOPRIGHT", base, "TOPLEFT", 0, -1)
	base:Tag(hp_string, "[city:color][city:currhp]")

	local power_string = cui.util.gen_string(base.Health, cui.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
	power_string:SetPoint("BOTTOMRIGHT", base, "BOTTOMLEFT", 0, 1)
	base:Tag(power_string, "[city:color][city:shortppfrequent]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, pet_cfg.size.w, cfg.auras.pet, "Debuffs")
	base.Debuffs:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -(cui.config.font_size_med + 2))
	
	base.Buffs = lib.gen_auras(base, pet_cfg.size.w, cfg.auras.pet, "Buffs")
	base.Buffs:SetPoint("TOPRIGHT", base.Debuffs, "BOTTOMRIGHT", 0, -1)
	lib.apply_whitelist_to(base.Buffs, cfg.pet_buff_whitelist)
end

local function create_nameplate_style(base)

	local nameplate_cfg = cfg.frames.nameplate
	local w, h = nameplate_cfg.size.w, nameplate_cfg.size.h
	base:SetAllPoints()
	
	-- health
	base.Health = cui.util.gen_statusbar(base, w, h, false)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.colorTapping = true
	base.Health.frequentUpdates = true
	base.Health:SetPoint("BOTTOMLEFT", base, "LEFT")
	
	-- power
	base.Power = CreateFrame("StatusBar", nil, base.Health)
	base.Power:SetStatusBarTexture(cui.media.textures.blank)
	base.Power:SetSize(w / 2, h / 3)
	base.Power:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.Power:SetPoint("BOTTOMRIGHT", -1, 1)
	base.Power.colorClass = true
	base.Power.colorDisconnected = true
	base.Power.frequentUpdates = true
	base.Power.colorTapping = true
	base.Power.colorPower = true
	
	-- strings
	local name_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	base:Tag(name_string, "[city:color][name]")
	name_string:SetPoint("BOTTOMLEFT", base.Health, "TOPLEFT", 1, 1)

	local hp_string = cui.util.gen_string(base.Health, cui.config.font_size_lrg, nil, nil, "RIGHT", "TOP")
	base:Tag(hp_string, "[city:color][perhp]")
	hp_string:SetPoint("RIGHT", base.Health, "BOTTOMRIGHT", -1, 0)

	-- cast
	base.Castbar = lib.gen_nameplate_cast_bar(base, w, h, cui.config.font_size_med)
	base.Castbar:SetPoint("TOPLEFT", base.Health, "BOTTOMLEFT", 0, 1)

	-- auras
	base.Debuffs = lib.gen_auras(base, w, cfg.auras.nameplate_debuff, "Debuffs")
	base.Debuffs:SetPoint("TOPLEFT", base.Health, "TOPRIGHT", 1, 0)
	base.Debuffs.disableMouse = false
	lib.apply_whitelist_to(base.Debuffs, nil, {player = true, pet = true})
	
	base.Buffs = lib.gen_auras(base, w, cfg.auras.nameplate_buff, "Buffs")
	base.Buffs:SetPoint("TOPRIGHT", base.Castbar.Icon, "TOPLEFT", -2, 1)
	base.Buffs.CustomFilter = function(element, _, _, _, _, _, debuffType, _, _, caster, _, _, spellID)
		if debuffType == "" or debuffType == "Magic" then
			return true
		end

		if cfg.nameplate_buff_whitelist[spellID] then
			return true
		end
	
		return false
	end
	
	-- mark
	lib.gen_raid_mark(base, cfg.raid_marks.nameplate)
end

local function create_focus_style(base)

	local focus_cfg = cfg.frames.focus
	base:SetWidth(focus_cfg.size.w)
	lib.enable_mouse(base)
	
	-- health
	base.Health = cui.util.gen_statusbar(base, focus_cfg.size.w, focus_cfg.size.h)
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdate = lib.invert_color
	lib.push_bar(base, base.Health)

	base:SetHeight(base.stack_height)

	-- strings
	local name_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "RIGHT", "TOP")
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 1, 1)
	base:Tag(name_string, "[city:color][name]")

	-- auras
	base.Debuffs = lib.gen_auras(base, focus_cfg.size.w, cfg.auras.focus, "Debuffs")
	lib.apply_blacklist_to(base.Debuffs, cfg.debuff_blacklist)
	base.Debuffs:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 0, 1)
	
	-- cast
	base.Castbar = lib.gen_cast_bar(base, focus_cfg.size.w, focus_cfg.cast.h, cui.config.font_size_med)
	base.Castbar:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -(cui.config.font_size_med + 2))
	
	-- mark
	lib.gen_raid_mark(base, cfg.raid_marks.focus)
end

local function create_boss_style(base)

	local boss_cfg = cfg.frames.boss
	base:SetWidth(boss_cfg.size.w)
	lib.enable_mouse(base)
	
	-- health
	base.Health = cui.util.gen_statusbar(base, boss_cfg.size.w, boss_cfg.size.h)
	base.Health.colorReaction = true
	base.Health.PostUpdate = lib.invert_color
	lib.push_bar(base, base.Health)
	
	-- cast
	base.Castbar = lib.gen_cast_bar(base, boss_cfg.size.w, boss_cfg.cast.h, cui.config.font_size_med)
	base.Castbar:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -(cui.config.font_size_med + 2))
	
	-- power
	base.Power = cui.util.gen_statusbar(base, boss_cfg.size.w, boss_cfg.power.h)
	base.Power.colorReaction = true
	base.Power.colorPower = true
	lib.push_bar(base, base.Power)

	-- alt power
	base.AlternativePower = cui.util.gen_statusbar(base, boss_cfg.size.w, boss_cfg.power.h)
	base.AlternativePower:SetPoint("TOPLEFT", base.Health, "TOPLEFT", 2, -2)
	base.AlternativePower:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -2, -2)
	
	base:SetHeight(base.stack_height)

	-- strings
	local hp_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 1)
	base:Tag(hp_string, "[city:color][perhp]%")
	
	local power_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
	power_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 1, 1)
	base:Tag(power_string, "[city:color][perpp]%")
	
	local altp_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "RIGHT", "TOP")
	altp_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, -1)
	base:Tag(altp_string, "[city:color][city:altpower]")
	
	local name_string = cui.util.gen_string(base, cui.config.font_size_med, nil, nil, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, -1)
	name_string:SetPoint("RIGHT", altp_string, "LEFT", -5, 0)
	base:Tag(name_string, "[city:color][name]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, boss_cfg.size.w , cfg.auras.boss, "Debuffs")
	base.Debuffs:SetPoint("TOPRIGHT", base, "TOPLEFT", -1, 0)
	base.Debuffs.onlyShowPlayer = true
	
	-- mark
	lib.gen_raid_mark(base, cfg.raid_marks.boss)
end

local function create_tank_style(base)

	local tank_cfg = cfg.frames.tank
	lib.enable_mouse(base)
	
	-- health
	base.Health = cui.util.gen_statusbar(base, tank_cfg.size.w, tank_cfg.size.h)
	base.Health.frequentUpdates = true
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.PostUpdate = lib.invert_color
	lib.push_bar(base, base.Health)
	
	-- power
	base.Power = cui.util.gen_statusbar(base, tank_cfg.size.w, tank_cfg.power.h)
	base.Power.colorClass = true
	base.Power.frequentUpdates = true
	base.Power.colorDisconnected = true
	lib.push_bar(base, base.Power)

	-- strings
	local name_string = cui.util.gen_string(base.Health, cui.config.font_size_med, nil, nil, "CENTER", "TOP")
	name_string:SetPoint("TOPLEFT")
	name_string:SetPoint("TOPRIGHT")
	base:Tag(name_string, "[city:color][name]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, tank_cfg.size.w, cfg.auras.tank, "Debuffs")
	base.Debuffs:SetPoint("BOTTOM", base.Health, "BOTTOM", 0, -5)
	lib.apply_blacklist_to(base.Debuffs, cfg.debuff_blacklist)
	
	-- misc
	lib.gen_raid_mark(base, cfg.raid_marks.party)
	lib.gen_raid_role(base)
	lib.gen_ready_check(base)
	
	base.Range = {
		insideAlpha = 1,
		outsideAlpha = cfg.range_alpha,
	}
end

local function create_party_style(base)

	local party_cfg = cfg.frames.party
	lib.enable_mouse(base)
	
	-- health
	base.Health = cui.util.gen_statusbar(base, party_cfg.size.w, party_cfg.size.h)
	base.Health.frequentUpdates = true
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdate = lib.invert_color
	lib.push_bar(base, base.Health)

	base.HealthPrediction = lib.gen_heal_bar(base.Health)
	base.HealthPrediction.frequentUpdates = true

	-- power
	base.Power = cui.util.gen_statusbar(base, party_cfg.size.w, party_cfg.power.h)
	base.Power.frequentUpdates = true
	base.Power.colorPower = true
	base.Power.colorDisconnected = true
	lib.push_bar(base, base.Power)

	-- strings
	local name_string = cui.util.gen_string(base.Health, cui.config.font_size_med, nil, nil, "CENTER", "TOP")
	name_string:SetPoint("TOPLEFT")
	name_string:SetPoint("TOPRIGHT")
	base:Tag(name_string, "[city:color][name]")
	
	local hp_string = cui.util.gen_string(base.Health, cui.config.font_size_med, nil, nil, "CENTER", "TOP")
	hp_string:SetPoint("TOPLEFT", name_string, "BOTTOMLEFT")
	hp_string:SetPoint("TOPRIGHT", name_string, "BOTTOMRIGHT")
	base:Tag(hp_string, "[city:color][city:info][city:hpraid]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, party_cfg.size.w, cfg.auras.party, "Debuffs")
	base.Debuffs:SetPoint("BOTTOM", base.Health, "BOTTOM", 0, -5)
	lib.apply_blacklist_to(base.Debuffs, cfg.debuff_blacklist)
	
	-- misc
	base.AuraWatch = lib.gen_indicators(base, party_cfg.indicators)
	
	lib.gen_raid_mark(base, cfg.raid_marks.party)
	lib.gen_raid_role(base)
	lib.gen_ready_check(base)
	
	base.Range = {
		insideAlpha = 1,
		outsideAlpha = cfg.range_alpha,
	}
end

local function create_raid_style(role)

	if role == "dps" then
	
		return function(base)
		
			local raid_cfg = cfg.frames.raid
			lib.enable_mouse(base)
			
			-- health
			base.Health = cui.util.gen_statusbar(base, raid_cfg.size.dps.w, raid_cfg.size.dps.h)
			base.Health.frequentUpdates = true
			base.Health.colorDisconnected = true
			base.Health.colorClass = true
			base.Health.colorReaction = true
			base.Health.PostUpdate = lib.invert_color
			lib.push_bar(base, base.Health)

			-- power
			base.Power = cui.util.gen_statusbar(base, raid_cfg.size.dps.w, raid_cfg.power.h)
			base.Power.colorPower = true
			lib.push_bar(base, base.Power)
	
			-- strings
			local name_string = cui.util.gen_string(base.Health, cui.config.font_size_med, nil, nil, "CENTER", "TOP")
			name_string:SetPoint("TOPLEFT")
			name_string:SetPoint("TOPRIGHT")
			base:Tag(name_string, "[city:color][name]")
			
			-- auras
			base.Debuffs = lib.gen_auras(base, raid_cfg.size.dps.w, cfg.auras.dps, "Debuffs")
			base.Debuffs:SetPoint("BOTTOM", base.Health, "BOTTOM", 0, -5)
			lib.apply_blacklist_to(base.Debuffs, cfg.debuff_blacklist)
			
			-- misc
			base.AuraWatch = lib.gen_indicators(base, raid_cfg.indicators)
			
			lib.gen_raid_mark(base, cfg.raid_marks.raid)
			lib.gen_raid_role(base)
			lib.gen_ready_check(base)
			
			base.Range = {
				insideAlpha = 1,
				outsideAlpha = cfg.range_alpha,
			}
		end
	else
	
		return function(base)

			local raid_cfg = cfg.frames.raid
			lib.enable_mouse(base)
			
			-- health
			base.Health = cui.util.gen_statusbar(base, raid_cfg.size.healer.w, raid_cfg.size.healer.h)
			base.Health.frequentUpdates = true
			base.Health.colorDisconnected = true
			base.Health.colorClass = true
			base.Health.colorReaction = true
			base.Health.PostUpdate = lib.invert_color
			lib.push_bar(base, base.Health)
			
			base.HealthPrediction = lib.gen_heal_bar(base.Health)
			base.HealthPrediction.frequentUpdates = true

			-- power
			base.Power = cui.util.gen_statusbar(base, raid_cfg.size.healer.w, raid_cfg.power.h)
			base.Power.colorPower = true
			base.Power.colorDisconnected = true
			lib.push_bar(base, base.Power)
	
			-- strings
			local name_string = cui.util.gen_string(base.Health, cui.config.font_size_med, nil, nil, "CENTER", "TOP")
			name_string:SetPoint("TOPLEFT")
			name_string:SetPoint("TOPRIGHT")
			base:Tag(name_string, "[city:color][name]")
			
			local hp_string = cui.util.gen_string(base.Health, cui.config.font_size_med, nil, nil, "CENTER", "TOP")
			hp_string:SetPoint("TOPLEFT", name_string, "BOTTOMLEFT")
			hp_string:SetPoint("TOPRIGHT", name_string, "BOTTOMRIGHT")
			base:Tag(hp_string, "[city:color][city:info][city:hpraid]")
			
			-- auras
			base.Debuffs = lib.gen_auras(base, raid_cfg.size.healer.w, cfg.auras.healer, "Debuffs")
			base.Debuffs:SetPoint("BOTTOM", base.Health, "BOTTOM", 0, -5)
			lib.apply_blacklist_to(base.Debuffs, cfg.debuff_blacklist)
			
			-- misc
			base.AuraWatch = lib.gen_indicators(base, raid_cfg.indicators)
			
			lib.gen_raid_mark(base, cfg.raid_marks.raid)
			lib.gen_raid_role(base)
			lib.gen_ready_check(base)
			
			base.Range = {
				insideAlpha = 1,
				outsideAlpha = cfg.range_alpha,
			}
		end
	end
end

oUF:Factory(function(self)
	
	if cfg.enabled.nameplates then
		C_NamePlate.SetNamePlateEnemySize(cfg.frames.nameplate.size.w, cfg.frames.nameplate.size.h * 4)
		C_NamePlate.SetNamePlateFriendlySize(cfg.frames.nameplate.size.w, cfg.frames.nameplate.size.h * 4)
		oUF:RegisterStyle("CityNameplate", create_nameplate_style)
		oUF:SpawnNamePlates("City", nil, cfg.nameplate_config)
	end

	if cfg.enabled.player then
		local mover = cui.util.get_mover_frame("Player", cfg.frames.player.pos)

		oUF:RegisterStyle("CityPlayer", create_player_style)
		oUF:SetActiveStyle("CityPlayer")
		oUF:Spawn("player"):SetPoint("TOPRIGHT", mover)
	end

	if cfg.enabled.pet then
		oUF:RegisterStyle("CityPet", create_pet_style)
		oUF:SetActiveStyle("CityPet")
		oUF:Spawn("pet")
	end

	if cfg.enabled.target then
		local mover = cui.util.get_mover_frame("Target", cfg.frames.target.pos)

		oUF:RegisterStyle("CityTarget", create_target_style)
		oUF:SetActiveStyle("CityTarget")
		oUF:Spawn("target"):SetPoint("TOPLEFT", mover)
	end

	if cfg.enabled.targettarget then
		oUF:RegisterStyle("CityTargetTarget", create_tot_style)
		oUF:SetActiveStyle("CityTargetTarget")
		oUF:Spawn("targettarget")
	end

	if cfg.enabled.focus then
		local mover = cui.util.get_mover_frame("Focus", cfg.frames.focus.pos)

		oUF:RegisterStyle("CityFocus", create_focus_style)
		oUF:SetActiveStyle("CityFocus")
		oUF:Spawn("focus"):SetPoint("TOPLEFT", mover)
	end

	if cfg.enabled.boss then
		oUF:RegisterStyle("CityBoss", create_boss_style)
		oUF:SetActiveStyle("CityBoss")

		local boss = {}
		local mover = cui.util.get_mover_frame("Boss", cfg.frames.boss.pos)

		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn("boss"..i, "oUF_CityBoss"..i)

			if i == 1 then
				boss[i]:SetPoint("TOPLEFT", mover)
			else
				boss[i]:SetPoint("TOPRIGHT", boss[i - 1], "BOTTOMRIGHT", 0, -(20 + cfg.frames.boss.cast.h + 2 * cui.config.font_size_med))
			end
		end
	end

	if cfg.enabled.party then

		local w = cfg.frames.party.size.w
		local h = cfg.frames.party.size.h + cfg.frames.party.power.h - 1
		local mover = cui.util.get_mover_frame("Party", cfg.frames.party.pos)
		mover:SetSize(w * 5 - 4, h)

		oUF:RegisterStyle("CityParty", create_party_style)
		oUF:SetActiveStyle("CityParty")
   
		local party = oUF:SpawnHeader(
			"oUF_CityParty", nil,
			"custom [@raid1,exists] hide; [group:party,nogroup:raid] show; hide",
			"showPlayer",         true,
			"showSolo",           true,
			"showParty",          true,
			"point",              "LEFT",
			"yoffset",            0,
			"xoffset",            -1,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(w, h)
		)
		party:SetPoint("TOPLEFT", mover)
	end

	if cfg.enabled.tank then

		local w = cfg.frames.tank.size.w
		local h = cfg.frames.tank.size.h + cfg.frames.tank.power.h - 1
		local mover = cui.util.get_mover_frame("Tank", cfg.frames.tank.pos)
		mover:SetSize(w, h * 2 - 1)

		oUF:RegisterStyle("CityTank", create_tank_style)
		oUF:SetActiveStyle("CityTank")
		local tank = oUF:SpawnHeader(
			"oUF_CityTank", 	nil,
			'raid, party, solo',
			'showRaid', 		true,
			"groupFilter", 		"MAINTANK",
			'yoffset', 			1,
			'xoffset', 			0,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(w, h)
		)
		tank:SetPoint("TOPLEFT", mover)
	end
 
	if cfg.enabled.raid then

		local role = _G["CityFrameRole"][cui.player.realm][cui.player.name]
		local w = cfg.frames.raid.size[role].w
		local h = cfg.frames.raid.size[role].h + cfg.frames.raid.power.h - 1
		local mover = cui.util.get_mover_frame("Raid", cfg.frames.raid.pos)
		mover:SetSize(w * 5 - 4, h * 6 - 5)

		oUF:RegisterStyle("CityRaid", create_raid_style(role))
		oUF:SetActiveStyle("CityRaid")
   
		local raid = oUF:SpawnHeader(
			"oUF_CityRaid", nil,
			"custom [@raid1,exists] show; hide",
			"showPlayer",         true,
			"showSolo",           true,
			"showRaid",           true,
			"point",              "LEFT",
			"yoffset",            0,
			"xoffset",            -1,
			"columnSpacing",      -1,
			"columnAnchorPoint",  "BOTTOM",
			"groupFilter",        "1,2,3,4,5,6",
			"groupBy",            "GROUP",
			"groupingOrder",      "1,2,3,4,5,6",
			"sortMethod",         "INDEX",
			"maxColumns",         8,
			"unitsPerColumn",     5,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(w, h)
		)
		raid:SetPoint("BOTTOMLEFT", mover)
	end
end)

SlashCmdList["TESTBOSS"] = function()
	oUF_CityBoss1:Show(); oUF_CityBoss1.Hide = function() end oUF_CityBoss1.unit = "target"
	oUF_CityBoss2:Show(); oUF_CityBoss2.Hide = function() end oUF_CityBoss2.unit = "player"
	oUF_CityBoss3:Show(); oUF_CityBoss3.Hide = function() end oUF_CityBoss3.unit = "player"
	oUF_CityBoss4:Show(); oUF_CityBoss4.Hide = function() end oUF_CityBoss4.unit = "player"
	oUF_CityBoss5:Show(); oUF_CityBoss5.Hide = function() end oUF_CityBoss5.unit = "player"
end
SLASH_TESTBOSS1 = "/testboss"
