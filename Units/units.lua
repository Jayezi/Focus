local _, addon = ...
if not addon.units.enabled then return end
local core = addon.core
local cfg = addon.units.cfg
local lib = addon.units.lib

local oUF = oUF
local CreateFrame = CreateFrame
local C_NamePlate = C_NamePlate
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES
local UIWidgetSetLayoutDirection = Enum.UIWidgetSetLayoutDirection
local UIWidgetLayoutDirection = Enum.UIWidgetLayoutDirection
local UnitGUID = UnitGUID
local strsplit = strsplit

local create_player_style = function(base)

	local player_cfg = cfg.frames.player
	base:SetWidth(player_cfg.size.w)
	lib.enable_mouse(base)

	-- cast
	base.Castbar = lib.gen_cast_bar(base, player_cfg.cast.size.w, player_cfg.cast.size.h, core.config.font_size_med, true, false, core.player.color)
	base.Castbar:SetPoint(core.util.to_tl_anchor(base.Castbar, player_cfg.cast.pos))
	
	local power_standalone, power_invert, power_tag = unpack(player_cfg.power.cfg)
	local power_w = power_standalone and player_cfg.cast.size.w or player_cfg.size.w
	local power_h = power_standalone or player_cfg.power.h
	
	-- power
	base.Power = core.util.gen_statusbar(base, power_w, power_h)
	base.Power.frequentUpdates = true
	base.Power.colorClass = true
	if power_invert then
		base.Power.PostUpdateColor = lib.invert_color
	end

	-- classbar
	local resource_bar = lib.gen_resource_bar(core.player.class, base, power_w, power_h)
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
	base.Health = core.util.gen_statusbar(base, player_cfg.size.w, player_cfg.size.h)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)

	base.HealthPrediction = lib.gen_heal_bar(base.Health)
	base.HealthPrediction.frequentUpdates = true

	-- "druid mana" etc.
	base.AdditionalPower = core.util.gen_statusbar(base, player_cfg.size.w, player_cfg.power.h)
	base.AdditionalPower:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.AdditionalPower:SetPoint("TOPLEFT", base.Health, "TOPLEFT", 2, -2)
	base.AdditionalPower:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -2, -2)
	base.AdditionalPower.colorPower = true

	-- alternate power
	base.AlternativePower = core.util.gen_statusbar(base, player_cfg.alt_power.size.w, player_cfg.alt_power.size.h)
	base.AlternativePower:SetPoint(core.util.to_tl_anchor(base.AlternativePower, player_cfg.alt_power.pos))

	base:SetHeight(base.stack_height)

	-- strings
	local hp_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 1)
	hp_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	base:Tag(hp_string, "[focus:color][focus:hp:curr/max state]")
	
	local altp_string = core.util.gen_string(base.AlternativePower, core.config.font_size_med, nil, nil, "BOTTOM", "CENTER")
	altp_string:SetPoint("BOTTOM", 0, 1)
	base:Tag(altp_string, "[focus:color][focus:altp:perc]")

	local hp_perc_string = core.util.gen_string(base.Health, core.config.font_size_lrg, nil, nil, "LEFT", "TOP")
	hp_perc_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, 10)
	base:Tag(hp_perc_string, "[focus:color][focus:hp:perc.]")

	local name_string = core.util.gen_string(base.Health, core.config.font_size_lrg, nil, nil, "RIGHT", "TOP")
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, 10)
	name_string:SetPoint("LEFT", hp_perc_string, "RIGHT", 5, 0)
	base:Tag(name_string, "[focus:color][focus:status][name]")
	
	local power_string
	if (power_standalone) then
		power_string = core.util.gen_string(base.Power, core.config.font_size_lrg, nil, nil, "CENTER", "BOTTOM")
		power_string:SetPoint("BOTTOM", 0, -10)
	else
		power_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
		power_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	end
	base:Tag(power_string, power_tag)
	
	-- auras
	base.Debuffs = lib.gen_auras(base, player_cfg.size.w, cfg.auras.player, "Debuffs")
	base.Debuffs:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 0, core.config.font_size_med + 2)

	base.Buffs = lib.gen_auras(base, player_cfg.size.w, cfg.auras.player, "Buffs")
	base.Buffs:SetPoint("BOTTOMRIGHT", base.Debuffs, "TOPRIGHT", 0, 1)
	lib.apply_whitelist_to(base.Buffs, cfg.player_buff_whitelist)
	
	-- mark
	lib.gen_raid_mark(base, cfg.raid_marks.primary)
end

local create_target_style = function(base)
	
	local target_cfg = cfg.frames.target
	base:SetWidth(target_cfg.size.w)
	lib.enable_mouse(base)

	-- power
	base.Power = core.util.gen_statusbar(base, target_cfg.size.w, target_cfg.power.h)
	base.Power.colorReaction = true
	base.Power.colorClass = true
	base.Power.colorDisconnected = true
	base.Power.frequentUpdates = true
	base.Power.colorTapping = true
	lib.push_bar(base, base.Power)
	
	-- health
	base.Health = core.util.gen_statusbar(base, target_cfg.size.w, target_cfg.size.h)
	base.Health.colorTapping = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)

	-- alternate power
	--base.AlternativePower = core.util.gen_statusbar(base, target_cfg.size.w, target_cfg.power.h)
	--base.AlternativePower:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	--base.AlternativePower:SetPoint("TOPLEFT", base.Health, "TOPLEFT", 2, -2)
	--base.AlternativePower:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -2, -2)
	
	-- cast
	base.Castbar = lib.gen_cast_bar(base, target_cfg.cast.size.w, target_cfg.cast.size.h, core.config.font_size_med, false, true)
	base.Castbar:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", target_cfg.cast.offset.x, target_cfg.cast.offset.y)
	
	base:SetHeight(base.stack_height)

	-- strings
	local power_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
	power_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 1, 1)
	base:Tag(power_string, "[focus:color][focus:pp:curr-perc]")

	local hp_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 1)
	hp_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	base:Tag(hp_string, "[focus:color][focus:hp:curr/max state]")

	local hp_perc_string = core.util.gen_string(base.Health, core.config.font_size_lrg, nil, nil, "RIGHT", "TOP")
	hp_perc_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, 10)
	base:Tag(hp_perc_string, "[focus:color][focus:hp:perc.]")

	local name_string = core.util.gen_string(base.Health, core.config.font_size_lrg, nil, nil, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, 10)
	name_string:SetPoint("RIGHT", hp_perc_string, "LEFT", -5, 0)
	base:Tag(name_string, "[focus:color][focus:status][name]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, target_cfg.size.w, cfg.auras.target_debuff, "Debuffs")
	base.Debuffs:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 0, core.config.font_size_med + 2)

	base.Buffs = lib.gen_auras(base, target_cfg.size.w, cfg.auras.target_buff, "Buffs")
	base.Buffs:SetPoint("BOTTOMLEFT", base.Debuffs, "TOPLEFT", 0, 1)

	-- mark
	lib.gen_raid_mark(base, cfg.raid_marks.primary)
end

local create_tot_style = function(base)

	local tot_cfg = cfg.frames.targettarget
	base:SetWidth(tot_cfg.size.w)
	base:SetPoint("TOPLEFT", _G["oUF_FocusUnitsTarget"], "BOTTOMLEFT", 0, -20)
	lib.enable_mouse(base)
	
	-- health
	base.Health = core.util.gen_statusbar(base, tot_cfg.size.w, tot_cfg.size.h)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)
	
	base:SetHeight(base.stack_height)

	-- strings
	local name_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, -1)
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, -1)
	base:Tag(name_string, "[focus:color][name]")
	name_string:SetMaxLines(2)
end

local create_pet_style = function(base)

	local pet_cfg = cfg.frames.pet
	base:SetWidth(pet_cfg.size.w)
	base:SetPoint("TOPRIGHT", _G["oUF_FocusUnitsPlayer"], "BOTTOMRIGHT", 0, -20)
	lib.enable_mouse(base)
	
	-- health
	base.Health = core.util.gen_statusbar(base, pet_cfg.size.w, pet_cfg.size.h)
	base.Health.colorDisconnected = true
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)
	
	-- power
	base.Power = core.util.gen_statusbar(base, pet_cfg.size.w, pet_cfg.power.h)
	base.Power.colorReaction = true
	base.Power.frequentUpdates = true
	lib.push_bar(base, base.Power)

	base:SetHeight(base.stack_height)
	
	-- strings
	local name_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "RIGHT", "TOP")
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -1)
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 0, -1)
	base:Tag(name_string, "[focus:color][name]")
	name_string:SetWordWrap(false)

	local hp_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "RIGHT", "TOP")
	hp_string:SetPoint("TOPRIGHT", base, "TOPLEFT", 0, -1)
	base:Tag(hp_string, "[focus:color][focus:hp:curr]")

	local power_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
	power_string:SetPoint("BOTTOMRIGHT", base, "BOTTOMLEFT", 0, 1)
	base:Tag(power_string, "[focus:color][focus:pp:curr]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, pet_cfg.size.w, cfg.auras.pet, "Debuffs")
	base.Debuffs:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -(core.config.font_size_med + 2))
	
	base.Buffs = lib.gen_auras(base, pet_cfg.size.w, cfg.auras.pet, "Buffs")
	base.Buffs:SetPoint("TOPRIGHT", base.Debuffs, "BOTTOMRIGHT", 0, -1)
	lib.apply_whitelist_to(base.Buffs, cfg.pet_buff_whitelist)
end

local create_nameplate_style = function(base)

	base:SetAllPoints()

	local nameplate_cfg = cfg.frames.nameplate
	local w, h = nameplate_cfg.size.w, nameplate_cfg.size.h

	-- Widgets
	base.WidgetContainer = CreateFrame('Frame', nil, base, 'UIWidgetContainerNoResizeTemplate')
	base.WidgetContainer:SetPoint('BOTTOM', base, 'TOP', 0, 10)
	base.WidgetContainer:Hide()
	base.WidgetContainer.showAndHideOnWidgetSetRegistration = false
	
	-- health
	base.Health = core.util.gen_statusbar(base, w, h, false)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.colorTapping = true
	base.Health.frequentUpdates = true
	base.Health:SetPoint("BOTTOMLEFT", base, "BOTTOMLEFT", 0, 20)

	base.Health.PostUpdateColor = function(self, unit)
		local guid = UnitGUID(unit)
		local _, _, _, _, _, npc_id, _ = strsplit("-", guid)
    	if cfg.nameplate_colors[tonumber(npc_id)] then
			self:SetStatusBarColor(unpack(cfg.nameplate_colors[tonumber(npc_id)]))
		end
	end
	
	-- power
	base.Power = CreateFrame("StatusBar", nil, base.Health)
	base.Power:SetStatusBarTexture(core.media.textures.blank)
	base.Power:SetSize(w - 2, nameplate_cfg.power.h)
	base.Power:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.Power:SetPoint("TOPLEFT", 1, -1)
	base.Power.colorClass = true
	base.Power.colorDisconnected = true
	base.Power.frequentUpdates = true
	base.Power.colorTapping = true
	base.Power.colorPower = true
	
	-- strings
	local name_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	base:Tag(name_string, "[focus:color][name]")
	name_string:SetPoint("BOTTOMLEFT", base.Health, "TOPLEFT", 1, 1)

	local hp_string = core.util.gen_string(base.Health, core.config.font_size_lrg, nil, nil, "RIGHT", "TOP")
	base:Tag(hp_string, "[focus:color][focus:hp:perc]")
	hp_string:SetPoint("RIGHT", base.Health, "BOTTOMRIGHT", -1, 0)

	-- cast
	base.Castbar = lib.gen_nameplate_cast_bar(base, w, nameplate_cfg.cast.h, nameplate_cfg.cast.h + h - 3, core.config.font_size_med)
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

local create_focus_style = function(base)

	local focus_cfg = cfg.frames.focus
	base:SetWidth(focus_cfg.size.w)
	lib.enable_mouse(base)
	
	-- health
	base.Health = core.util.gen_statusbar(base, focus_cfg.size.w, focus_cfg.size.h)
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)

	base:SetHeight(base.stack_height)

	-- strings
	local name_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, -1)
	base:Tag(name_string, "[focus:color][name]")

	-- auras
	base.Debuffs = lib.gen_auras(base, focus_cfg.size.w, cfg.auras.focus, "Debuffs")
	lib.apply_blacklist_to(base.Debuffs, cfg.debuff_blacklist)
	base.Debuffs:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 0, 1)
	
	-- cast
	base.Castbar = lib.gen_cast_bar(base, focus_cfg.size.w, focus_cfg.cast.h, core.config.font_size_med)
	base.Castbar:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -(core.config.font_size_med + 2))
	
	-- mark
	lib.gen_raid_mark(base, cfg.raid_marks.focus)
end

local create_boss_style = function(base)

	local boss_cfg = cfg.frames.boss
	base:SetWidth(boss_cfg.size.w)
	lib.enable_mouse(base)
	
	-- power
	base.Power = core.util.gen_statusbar(base, boss_cfg.size.w, boss_cfg.power.h)
	base.Power.colorReaction = true
	base.Power.colorPower = true
	lib.push_bar(base, base.Power)

	-- health
	base.Health = core.util.gen_statusbar(base, boss_cfg.size.w, boss_cfg.size.h)
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)

	-- alt power
	base.AlternativePower = core.util.gen_statusbar(base, boss_cfg.size.w, boss_cfg.power.h)
	base.AlternativePower:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.AlternativePower:SetPoint("TOPLEFT", base.Health, "TOPLEFT", 2, -2)
	base.AlternativePower:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -2, -2)
	
	base:SetHeight(base.stack_height)
	
	-- cast
	base.Castbar = lib.gen_cast_bar(base, boss_cfg.size.w, boss_cfg.cast.h, core.config.font_size_med)
	base.Castbar:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 0, 1)

	-- strings
	local altp_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
	altp_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	base:Tag(altp_string, "[focus:color][focus:altp:perc]")
	
	local name_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "LEFT", "TOP")
	name_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 1)
	name_string:SetPoint("RIGHT", altp_string, "LEFT", -5, 0)
	base:Tag(name_string, "[focus:color][name]")

	local hp_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "LEFT", "TOP")
	hp_string:SetPoint("TOPLEFT", base, "TOPRIGHT", 1, -1)
	base:Tag(hp_string, "[focus:color][focus:hp:curr-perc]")
	
	local power_string = core.util.gen_string(base, core.config.font_size_med, nil, nil, "LEFT", "TOP")
	power_string:SetPoint("BOTTOMLEFT", base, "BOTTOMRIGHT", 1, 1)
	base:Tag(power_string, "[focus:color][focus:pp:curr-perc]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, boss_cfg.size.w , cfg.auras.boss, "Debuffs")
	base.Debuffs:SetPoint("TOPRIGHT", base, "TOPLEFT", -1, 0)
	base.Debuffs.onlyShowPlayer = true
	
	-- mark
	lib.gen_raid_mark(base, cfg.raid_marks.boss)
end

local create_tank_style = function(base)

	local tank_cfg = cfg.frames.tank
	lib.enable_mouse(base)
	
	-- health
	base.Health = core.util.gen_statusbar(base, tank_cfg.size.w, tank_cfg.size.h)
	base.Health.frequentUpdates = true
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)
	
	-- power
	base.Power = core.util.gen_statusbar(base, tank_cfg.size.w, tank_cfg.power.h)
	base.Power.colorClass = true
	base.Power.frequentUpdates = true
	base.Power.colorDisconnected = true
	lib.push_bar(base, base.Power)

	-- strings
	local name_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, nil, "CENTER", "TOP")
	name_string:SetPoint("TOPLEFT")
	name_string:SetPoint("TOPRIGHT")
	base:Tag(name_string, "[focus:color][name]")
	
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

local create_party_style = function(base)

	local party_cfg = cfg.frames.party
	lib.enable_mouse(base)
	
	-- health
	base.Health = core.util.gen_statusbar(base, party_cfg.size.w, party_cfg.size.h)
	base.Health.frequentUpdates = true
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)

	base.HealthPrediction = lib.gen_heal_bar(base.Health)
	base.HealthPrediction.frequentUpdates = true

	-- power
	base.Power = core.util.gen_statusbar(base, party_cfg.size.w, party_cfg.power.h)
	base.Power.frequentUpdates = true
	base.Power.colorPower = true
	base.Power.colorDisconnected = true
	lib.push_bar(base, base.Power)

	-- strings
	local name_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, nil, "CENTER", "TOP")
	name_string:SetPoint("TOPLEFT")
	name_string:SetPoint("TOPRIGHT")
	base:Tag(name_string, "[focus:color][name]")
	
	local hp_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, nil, "CENTER", "TOP")
	hp_string:SetPoint("TOPLEFT", name_string, "BOTTOMLEFT")
	hp_string:SetPoint("TOPRIGHT", name_string, "BOTTOMRIGHT")
	base:Tag(hp_string, "[focus:color][focus:hp:group]")
	
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

local create_raid_style = function(role)

	if role == "dps" then
	
		return function(base)
		
			local raid_cfg = cfg.frames.raid
			lib.enable_mouse(base)
			
			-- health
			base.Health = core.util.gen_statusbar(base, raid_cfg.size.dps.w, raid_cfg.size.dps.h)
			base.Health.frequentUpdates = true
			base.Health.colorDisconnected = true
			base.Health.colorClass = true
			base.Health.colorReaction = true
			base.Health.PostUpdateColor = lib.invert_color
			lib.push_bar(base, base.Health)

			-- power
			base.Power = core.util.gen_statusbar(base, raid_cfg.size.dps.w, raid_cfg.power.h)
			base.Power.colorPower = true
			lib.push_bar(base, base.Power)
	
			-- strings
			local name_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, nil, "CENTER", "TOP")
			name_string:SetPoint("TOPLEFT")
			name_string:SetPoint("TOPRIGHT")
			base:Tag(name_string, "[focus:color][name]")
			
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
			base.Health = core.util.gen_statusbar(base, raid_cfg.size.healer.w, raid_cfg.size.healer.h)
			base.Health.frequentUpdates = true
			base.Health.colorDisconnected = true
			base.Health.colorClass = true
			base.Health.colorReaction = true
			base.Health.PostUpdateColor = lib.invert_color
			lib.push_bar(base, base.Health)
			
			base.HealthPrediction = lib.gen_heal_bar(base.Health)
			base.HealthPrediction.frequentUpdates = true

			-- power
			base.Power = core.util.gen_statusbar(base, raid_cfg.size.healer.w, raid_cfg.power.h)
			base.Power.colorPower = true
			base.Power.colorDisconnected = true
			lib.push_bar(base, base.Power)
	
			-- strings
			local name_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, nil, "CENTER", "TOP")
			name_string:SetPoint("TOPLEFT")
			name_string:SetPoint("TOPRIGHT")
			base:Tag(name_string, "[focus:color][name]")
			
			local hp_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, nil, "CENTER", "TOP")
			hp_string:SetPoint("TOPLEFT", name_string, "BOTTOMLEFT")
			hp_string:SetPoint("TOPRIGHT", name_string, "BOTTOMRIGHT")
			base:Tag(hp_string, "[focus:color][focus:hp:group]")
			
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

local widgetLayout = function(widgetContainerFrame, sortedWidgets)
	local horizontalRowContainer = nil
	local horizontalRowHeight = 0
	local horizontalRowWidth = 0
	local totalWidth = 0
	local totalHeight = 0

	widgetContainerFrame.horizontalRowContainerPool:ReleaseAll()

	for index, widgetFrame in ipairs(sortedWidgets) do
		widgetFrame:ClearAllPoints()

		-- if widgetFrame.Bar and not widgetFrame.Bar.backdrop then
		-- 	widgetFrame.Bar:CreateBackdrop('Transparent')
		-- end

		local widgetSetUsesVertical = widgetContainerFrame.widgetSetLayoutDirection == UIWidgetSetLayoutDirection.Vertical
		local widgetUsesVertical = widgetFrame.layoutDirection == UIWidgetLayoutDirection.Vertical

		local useOverlapLayout = widgetFrame.layoutDirection == UIWidgetLayoutDirection.Overlap
		local useVerticalLayout = widgetUsesVertical or (widgetFrame.layoutDirection == UIWidgetLayoutDirection.Default and widgetSetUsesVertical)

		if useOverlapLayout then
			-- This widget uses overlap layout

			if index == 1 then
				if widgetSetUsesVertical then
					widgetFrame:Point(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame)
				else
					widgetFrame:Point(widgetContainerFrame.horizontalAnchorPoint, widgetContainerFrame)
				end
			else
				local relative = sortedWidgets[index - 1]
				if widgetSetUsesVertical then
					widgetFrame:Point(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalAnchorPoint, 0, 0)
				else
					widgetFrame:Point(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalAnchorPoint, 0, 0)
				end
			end

			local width, height = widgetFrame:GetSize()
			if width > totalWidth then
				totalWidth = width
			end
			if height > totalHeight then
				totalHeight = height
			end

			widgetFrame:SetParent(widgetContainerFrame)
		elseif useVerticalLayout then
			if index == 1 then
				widgetFrame:Point(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame)
			else
				local relative = horizontalRowContainer or sortedWidgets[index - 1]
				widgetFrame:Point(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset)

				if horizontalRowContainer then
					horizontalRowContainer:Size(horizontalRowWidth, horizontalRowHeight)
					totalWidth = totalWidth + horizontalRowWidth
					totalHeight = totalHeight + horizontalRowHeight
					horizontalRowHeight = 0
					horizontalRowWidth = 0
					horizontalRowContainer = nil
				end

				totalHeight = totalHeight + widgetContainerFrame.verticalAnchorYOffset
			end

			widgetFrame:SetParent(widgetContainerFrame)

			local width, height = widgetFrame:GetSize()
			if width > totalWidth then
				totalWidth = width
			end
			totalHeight = totalHeight + height
		else
			local forceNewRow = widgetFrame.layoutDirection == UIWidgetLayoutDirection.HorizontalForceNewRow
			local needNewRowContainer = not horizontalRowContainer or forceNewRow
			if needNewRowContainer then
				if horizontalRowContainer then
					--horizontalRowContainer:Layout()
					horizontalRowContainer:Size(horizontalRowWidth, horizontalRowHeight)
					totalWidth = totalWidth + horizontalRowWidth
					totalHeight = totalHeight + horizontalRowHeight
					horizontalRowHeight = 0
					horizontalRowWidth = 0
				end

				local newHorizontalRowContainer = widgetContainerFrame.horizontalRowContainerPool:Acquire()
				newHorizontalRowContainer:Show()

				if index == 1 then
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame, widgetContainerFrame.verticalAnchorPoint)
				else
					local relative = horizontalRowContainer or sortedWidgets[index - 1]
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset)

					totalHeight = totalHeight + widgetContainerFrame.verticalAnchorYOffset
				end
				widgetFrame:SetPoint('TOPLEFT', newHorizontalRowContainer)
				widgetFrame:SetParent(newHorizontalRowContainer)

				horizontalRowWidth = horizontalRowWidth + widgetFrame:GetWidth()
				horizontalRowContainer = newHorizontalRowContainer
			else
				local relative = sortedWidgets[index - 1]
				widgetFrame:SetParent(horizontalRowContainer)
				widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalRelativePoint, widgetContainerFrame.horizontalAnchorXOffset, 0)

				horizontalRowWidth = horizontalRowWidth + widgetFrame:GetWidth() + widgetContainerFrame.horizontalAnchorXOffset
			end

			local widgetHeight = widgetFrame:GetHeight()
			if widgetHeight > horizontalRowHeight then
				horizontalRowHeight = widgetHeight
			end
		end
	end

	if horizontalRowContainer then
		horizontalRowContainer:SetSize(horizontalRowWidth, horizontalRowHeight)
		totalWidth = totalWidth + horizontalRowWidth
		totalHeight = totalHeight + horizontalRowHeight
	end

	widgetContainerFrame:SetSize(totalWidth, totalHeight)
	widgetContainerFrame:Show()
end

oUF:Factory(function(self)

	if cfg.enabled.nameplates then
		oUF:RegisterStyle("FocusUnitsNameplate", create_nameplate_style)
		oUF:SpawnNamePlates("FocusUnits", function(nameplate, event, unit)
			if event == "NAME_PLATE_UNIT_ADDED" then
				nameplate.WidgetContainer:UnregisterForWidgetSet()
				local widgetSet = UnitWidgetSet(unit)
				if widgetSet and ((playerControlled and UnitIsOwnerOrControllerOfUnit('player', unit)) or not playerControlled) then
					nameplate.WidgetContainer:RegisterForWidgetSet(widgetSet, widgetLayout, nil, unit)
					nameplate.WidgetContainer:ProcessAllWidgets()
				end
			elseif event == "NAME_PLATE_UNIT_REMOVED" then
				nameplate.WidgetContainer:UnregisterForWidgetSet()
			end
		end, cfg.nameplate_cfg)
	end

	if cfg.enabled.player then
		local mover = core.util.get_mover_frame("Player", cfg.frames.player.pos)

		oUF:RegisterStyle("FocusUnitsPlayer", create_player_style)
		oUF:SetActiveStyle("FocusUnitsPlayer")
		oUF:Spawn("player"):SetPoint("TOPRIGHT", mover)
	end

	if cfg.enabled.pet then
		oUF:RegisterStyle("FocusUnitsPet", create_pet_style)
		oUF:SetActiveStyle("FocusUnitsPet")
		oUF:Spawn("pet")
	end

	if cfg.enabled.target then
		local mover = core.util.get_mover_frame("Target", cfg.frames.target.pos)

		oUF:RegisterStyle("FocusUnitsTarget", create_target_style)
		oUF:SetActiveStyle("FocusUnitsTarget")
		oUF:Spawn("target"):SetPoint("TOPLEFT", mover)
	end

	if cfg.enabled.targettarget then
		oUF:RegisterStyle("FocusUnitsTargetTarget", create_tot_style)
		oUF:SetActiveStyle("FocusUnitsTargetTarget")
		oUF:Spawn("targettarget")
	end

	if cfg.enabled.focus then
		local mover = core.util.get_mover_frame("Focus", cfg.frames.focus.pos)

		oUF:RegisterStyle("FocusUnitsFocus", create_focus_style)
		oUF:SetActiveStyle("FocusUnitsFocus")
		oUF:Spawn("focus"):SetPoint("TOPLEFT", mover)
	end

	if cfg.enabled.boss then
		oUF:RegisterStyle("FocusUnitsBoss", create_boss_style)
		oUF:SetActiveStyle("FocusUnitsBoss")

		local boss = {}
		local mover = core.util.get_mover_frame("Boss", cfg.frames.boss.pos)

		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn("boss"..i, "oUF_FocusUnitsBoss"..i)

			if i == 1 then
				boss[i]:SetPoint("TOPLEFT", mover)
			else
				boss[i]:SetPoint("TOPRIGHT", boss[i - 1], "BOTTOMRIGHT", 0, -(20 + cfg.frames.boss.cast.h + 2 * core.config.font_size_med))
			end
		end
	end

	if cfg.enabled.party then

		local w = cfg.frames.party.size.w
		local h = cfg.frames.party.size.h + cfg.frames.party.power.h - 1
		local mover = core.util.get_mover_frame("Party", cfg.frames.party.pos)
		mover:SetSize(w, h * 5 - 4)

		oUF:RegisterStyle("FocusUnitsParty", create_party_style)
		oUF:SetActiveStyle("FocusUnitsParty")
   
		local party = oUF:SpawnHeader(
			"oUF_FocusUnitsParty", nil,
			"custom [@raid1,exists] hide; [group:party,nogroup:raid] show; hide",
			"showPlayer",         true,
			"showSolo",           true,
			"showParty",          true,
			"point",              "BOTTOM",
			"yoffset",            -1,
			"xoffset",            0,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(w, h)
		)
		party:SetPoint("BOTTOMLEFT", mover)
	end

	if cfg.enabled.tank then

		local w = cfg.frames.tank.size.w
		local h = cfg.frames.tank.size.h + cfg.frames.tank.power.h - 1
		local mover = core.util.get_mover_frame("Tank", cfg.frames.tank.pos)
		mover:SetSize(w, h * 2 - 1)

		oUF:RegisterStyle("FocusUnitsTank", create_tank_style)
		oUF:SetActiveStyle("FocusUnitsTank")
		local tank = oUF:SpawnHeader(
			"oUF_FocusUnitsTank", 	nil,
			'raid',
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

		local role = _G["FocusFrameRoles"][core.player.realm][core.player.name]
		local w = cfg.frames.raid.size[role].w
		local h = cfg.frames.raid.size[role].h + cfg.frames.raid.power.h - 1
		local mover_small = core.util.get_mover_frame("RaidSmall", cfg.frames.raid.pos)
		mover_small:SetSize(w * 5 - 4, h * 4 - 3)

		oUF:RegisterStyle("FocusUnitsRaid", create_raid_style(role))
		oUF:SetActiveStyle("FocusUnitsRaid")
   
		local raid_small = oUF:SpawnHeader(
			"oUF_FocusUnitsRaidSmall", nil,
			"custom [@raid21,exists] hide; [@raid1,exists] show; hide",
			"showPlayer",         true,
			"showSolo",           true,
			"showRaid",           true,
			"point",              "LEFT",
			"yoffset",            0,
			"xoffset",            -1,
			"columnSpacing",      -1,
			"columnAnchorPoint",  "TOP",
			"groupFilter",        "1,2,3,4",
			"groupBy",            "GROUP",
			"groupingOrder",      "1,2,3,4",
			"sortMethod",         "INDEX",
			"maxColumns",         4,
			"unitsPerColumn",     5,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(w, h)
		)
		raid_small:SetPoint("TOPLEFT", mover_small)

		local mover_big = core.util.get_mover_frame("RaidBig", cfg.frames.raid.pos)
		mover_big:SetSize(w * 5 - 4, h * 8 - 7)
		local raid_big = oUF:SpawnHeader(
			"oUF_FocusUnitsRaidBig", nil,
			"custom [@raid21,exists] show; hide",
			"showPlayer",         true,
			"showSolo",           true,
			"showRaid",           true,
			"point",              "LEFT",
			"yoffset",            0,
			"xoffset",            -1,
			"columnSpacing",      -1,
			"columnAnchorPoint",  "TOP",
			"groupFilter",        "1,2,3,4,5,6,7,8",
			"groupBy",            "GROUP",
			"groupingOrder",      "1,2,3,4,5,6,7,8",
			"sortMethod",         "INDEX",
			"maxColumns",         8,
			"unitsPerColumn",     5,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(w, h)
		)
		raid_big:SetPoint("TOPLEFT", mover_big)
	end
end)

core.settings:add_action("Test Boss", function()
	oUF_FocusUnitsBoss1:Show(); oUF_FocusUnitsBoss1.Hide = function() end oUF_FocusUnitsBoss1.unit = "target"
	oUF_FocusUnitsBoss2:Show(); oUF_FocusUnitsBoss2.Hide = function() end oUF_FocusUnitsBoss2.unit = "player"
	oUF_FocusUnitsBoss3:Show(); oUF_FocusUnitsBoss3.Hide = function() end oUF_FocusUnitsBoss3.unit = "player"
	oUF_FocusUnitsBoss4:Show(); oUF_FocusUnitsBoss4.Hide = function() end oUF_FocusUnitsBoss4.unit = "player"
	oUF_FocusUnitsBoss5:Show(); oUF_FocusUnitsBoss5.Hide = function() end oUF_FocusUnitsBoss5.unit = "player"
end)
